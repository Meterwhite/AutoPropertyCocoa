//
//  apc-objc-private.cpp
//  Test123123
//
//  Created by MDLK on 2019/5/5.
//  Copyright © 2019 MDLK. All rights reserved.
//

#include "apc-objc-private.h"
#include "apc-objc-config.h"

/// A pointer to the function of a method implementation.
#if !OBJC_OLD_DISPATCH_PROTOTYPES
typedef void (*IMP)(void /* id, SEL, ... */ );
#else
typedef id (*IMP)(id, SEL, ...);
#endif

#ifndef nil
# if __has_feature(cxx_nullptr)
#   define nil nullptr
# else
#   define nil __DARWIN_NULL
# endif
#endif

#if !(__OBJC2__  &&  __LP64__)
#   define SUPPORT_TAGGED_POINTERS 0
#else
#   define SUPPORT_TAGGED_POINTERS 1
#endif

/*
 ---------------------------------
 ---------------------------------
 ---------------------------------
 */
#pragma mark - objc-private.h
#import <libkern/OSAtomic.h>
#include <malloc/malloc.h>
#include <pthread.h>
#include <stdint.h>
#include <assert.h>
#include <iterator>
#include <cstddef>

struct apc_objc_class;
struct apc_objc_object;

typedef struct apc_objc_class *APCClass;
typedef struct apc_objc_object *id;

namespace {
    struct SideTable;
};

union apc_isa_t
{
    apc_isa_t() { }
    apc_isa_t(uintptr_t value) : bits(value) { }
    
    APCClass cls;
    uintptr_t bits;
    
    #if SUPPORT_NONPOINTER_ISA
#   define ISA_MASK        0x0000000ffffffff8ULL
#   define ISA_MAGIC_MASK  0x000003f000000001ULL
#   define ISA_MAGIC_VALUE 0x000001a000000001ULL
    struct {
        uintptr_t indexed           : 1;
        uintptr_t has_assoc         : 1;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t shiftcls          : 33; // MACH_VM_MAX_ADDRESS 0x1000000000
        uintptr_t magic             : 6;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating      : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc          : 19;
#       define RC_ONE   (1ULL<<45)
#       define RC_HALF  (1ULL<<18)
    };
    
    # elif __x86_64__
#   define ISA_MASK        0x00007ffffffffff8ULL
#   define ISA_MAGIC_MASK  0x001f800000000001ULL
#   define ISA_MAGIC_VALUE 0x001d800000000001ULL
    struct {
        uintptr_t indexed           : 1;
        uintptr_t has_assoc         : 1;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t shiftcls          : 44; // MACH_VM_MAX_ADDRESS 0x7fffffe00000
        uintptr_t magic             : 6;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating      : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc          : 8;
#       define RC_ONE   (1ULL<<56)
#       define RC_HALF  (1ULL<<7)
    };
    
    # else
    // Available bits in isa field are architecture-specific.
#   error unknown architecture
    
    // SUPPORT_NONPOINTER_ISA
    #endif
};


struct apc_objc_object {
    
private:
    apc_isa_t isa;
    
public:
    
    bool isTaggedPointer();
};

// Define SUPPORT_MSB_TAGGED_POINTERS to use the MSB
// as the tagged pointer marker instead of the LSB.
// Be sure to edit tagged pointer SPI in objc-internal.h as well.
#if !SUPPORT_TAGGED_POINTERS  ||  !TARGET_OS_IPHONE
#   define SUPPORT_MSB_TAGGED_POINTERS 0
#else
#   define SUPPORT_MSB_TAGGED_POINTERS 1
#endif

#if SUPPORT_MSB_TAGGED_POINTERS
#   define TAG_MASK (1ULL<<63)
//#   define TAG_SLOT_SHIFT 60
//#   define TAG_PAYLOAD_LSHIFT 4
//#   define TAG_PAYLOAD_RSHIFT 4
#else
#   define TAG_MASK 1
//#   define TAG_SLOT_SHIFT 0
//#   define TAG_PAYLOAD_LSHIFT 0
//#   define TAG_PAYLOAD_RSHIFT 4
#endif
inline bool
apc_objc_object::isTaggedPointer()
{
    return ((uintptr_t)this & TAG_MASK);
}


struct apc_method_t {
    SEL name;
    const char *types;
    IMP imp;
    
    struct SortBySELAddress :
    public std::binary_function<const apc_method_t&,
    const apc_method_t&, bool>
    {
        bool operator() (const apc_method_t& lhs,
                         const apc_method_t& rhs)
        { return lhs.name < rhs.name; }
    };
};

struct apc_property_t {
    const char *name;
    const char *attributes;
};

struct apc_ivar_t {
#if __x86_64__
    // *offset was originally 64-bit on some x86_64 platforms.
    // We read and write only 32 bits of it.
    // Some metadata provides all 64 bits. This is harmless for unsigned
    // little-endian values.
    // Some code uses all 64 bits. class_addIvar() over-allocates the
    // offset for their benefit.
#endif
    int32_t *offset;
    const char *name;
    const char *type;
    // alignment is sometimes -1; use alignment() instead
    uint32_t alignment_raw;
    uint32_t size;
    
#ifdef __LP64__
#   define WORD_SHIFT 3UL
#else
#   define WORD_SHIFT 2UL
#endif
    uint32_t alignment() const {
        if (alignment_raw == ~(uint32_t)0) return 1U << WORD_SHIFT;
        return 1 << alignment_raw;
    }
};

static inline void *
memdup(const void *mem, size_t len)
{
    void *dup = malloc(len);
    memcpy(dup, mem, len);
    return dup;
}

typedef uintptr_t apc_protocol_ref_t;  // protocol_t *, but unremapped
typedef apc_protocol_ref_t* iterator;
typedef const apc_protocol_ref_t* const_iterator;
struct apc_protocol_list_t {
    // count is 64-bit by accident.
    uintptr_t count;
    apc_protocol_ref_t list[0]; // variable-size
    
    size_t byteSize() const {
        return sizeof(*this) + count*sizeof(list[0]);
    }
    
    apc_protocol_list_t *duplicate() const {
        return (apc_protocol_list_t *)memdup(this, this->byteSize());
    }
};

typedef struct apc_method_t *APCMethod;
typedef struct apc_ivar_t *APCIvar;
typedef struct apc_category_t *APCCategory;
typedef struct apc_property_t *apc_objc_property_t;

#if __LP64__
typedef uint32_t apc_mask_t;  // x86_64 & arm64 asm are less efficient with 16-bits
#else
typedef uint16_t apc_mask_t;
#endif

typedef uintptr_t apc_cache_key_t;

struct apc_bucket_t {
private:
    apc_cache_key_t _key;
    IMP _imp;
};

struct apc_cache_t {
    struct apc_bucket_t *_buckets;
    apc_mask_t _mask;
    apc_mask_t _occupied;
};

template <typename Element, typename List, uint32_t FlagMask>
struct apc_entsize_list_tt {
    uint32_t entsizeAndFlags;
    uint32_t count;
    Element first;
    
    void deleteElement(Element* elm) {
        
        Element* item;
        uint32_t idx = UINT32_MAX;
        for(uint32_t i = 0 ; i < count ; i++){
            
            item = (Element *)((uint8_t *)&first + i);
            if(item == elm){
                
                idx = i;
                break;
            }
        }
        
        if(idx == UINT32_MAX){
            
            return;
        }
        
        char** pre  = NULL;
        char** next = NULL;
        size_t size = sizeof(Element);
        for(uint32_t i = 0 , j = i ; i < count ; i++){
            
            if(i < idx) {
                
                continue;
            }
            
            pre  = ((char**)&first);
            if(idx == count -1) {
                
                memset(pre, 0, size);
            }else{
                
                next = ((char**)&first + i*size);
                memcpy(pre, next, sizeof(Element));
            }
            
            j++;
        }
        count --;
    }
    
    uint32_t entsize() const {
        return entsizeAndFlags & ~FlagMask;
    }
    uint32_t flags() const {
        return entsizeAndFlags & FlagMask;
    }
    
    Element& getOrEnd(uint32_t i) const {
        assert(i <= count);
        return *(Element *)((uint8_t *)&first + i*entsize());
    }
    Element& get(uint32_t i) const {
        assert(i < count);
        return getOrEnd(i);
    }
    
    size_t byteSize() const {
        return sizeof(*this) + (count-1)*entsize();
    }
    
    List *duplicate() const {
        return (List *)memdup(this, this->byteSize());
    }
    
    struct iterator;
    const iterator begin() const {
        return iterator(*static_cast<const List*>(this), 0);
    }
    iterator begin() {
        return iterator(*static_cast<const List*>(this), 0);
    }
    const iterator end() const {
        return iterator(*static_cast<const List*>(this), count);
    }
    iterator end() {
        return iterator(*static_cast<const List*>(this), count);
    }
    
    struct iterator {
        uint32_t entsize;
        uint32_t index;  // keeping track of this saves a divide in operator-
        Element* element;

        typedef std::random_access_iterator_tag iterator_category;
        typedef Element value_type;
        typedef ptrdiff_t difference_type;
        typedef Element* pointer;
        typedef Element& reference;
        
        iterator() { }
        
        iterator(const List& list, uint32_t start = 0)
        : entsize(list.entsize())
        , index(start)
        , element(&list.getOrEnd(start))
        { }
        
        const iterator& operator += (ptrdiff_t delta) {
            element = (Element*)((uint8_t *)element + delta*entsize);
            index += (int32_t)delta;
            return *this;
        }
        const iterator& operator -= (ptrdiff_t delta) {
            element = (Element*)((uint8_t *)element - delta*entsize);
            index -= (int32_t)delta;
            return *this;
        }
        const iterator operator + (ptrdiff_t delta) const {
            return iterator(*this) += delta;
        }
        const iterator operator - (ptrdiff_t delta) const {
            return iterator(*this) -= delta;
        }
        
        iterator& operator ++ () { *this += 1; return *this; }
        iterator& operator -- () { *this -= 1; return *this; }
        iterator operator ++ (int) {
            iterator result(*this); *this += 1; return result;
        }
        iterator operator -- (int) {
            iterator result(*this); *this -= 1; return result;
        }
        
        ptrdiff_t operator - (const iterator& rhs) const {
            return (ptrdiff_t)this->index - (ptrdiff_t)rhs.index;
        }
        
        Element& operator * () const { return *element; }
        Element* operator -> () const { return element; }
        
        operator Element& () const { return *element; }
        
        bool operator == (const iterator& rhs) const {
            return this->element == rhs.element;
        }
        bool operator != (const iterator& rhs) const {
            return this->element != rhs.element;
        }
        
        bool operator < (const iterator& rhs) const {
            return this->element < rhs.element;
        }
        bool operator > (const iterator& rhs) const {
            return this->element > rhs.element;
        }
    };
};


struct apc_ivar_list_t : apc_entsize_list_tt<apc_ivar_t, apc_ivar_list_t, 0> {
};

struct apc_property_list_t : apc_entsize_list_tt<apc_property_t, apc_property_list_t, 0> {
};


// Two bits of entsize are used for fixup markers.
struct apc_method_list_t : apc_entsize_list_tt<apc_method_t, apc_method_list_t, 0x3> {
    bool isFixedUp() const;
    void setFixedUp();
    
    uint32_t indexOfMethod(const apc_method_t *meth) const {
        uint32_t i =
        (uint32_t)(((uintptr_t)meth - (uintptr_t)this) / entsize());
        assert(i < count);
        return i;
    }
};

static uint32_t apc_fixed_up_method_list = 3;

bool apc_method_list_t::isFixedUp() const {
    return flags() == apc_fixed_up_method_list;
}

void apc_method_list_t::setFixedUp() {
//    runtimeLock.assertWriting();
    assert(!isFixedUp());
    entsizeAndFlags = entsize() | apc_fixed_up_method_list;
}

struct apc_class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
#ifdef __LP64__
    uint32_t reserved;
#endif
    
    const uint8_t * ivarLayout;
    
    const char * name;
    apc_method_list_t * baseMethodList;
    apc_protocol_list_t * baseProtocols;
    const apc_ivar_list_t * ivars;
    
    const uint8_t * weakIvarLayout;
    apc_property_list_t *baseProperties;
    
    apc_method_list_t *baseMethods() const {
        return baseMethodList;
    }
};

static void try_free(const void *p)
{
    if (p && malloc_size(p)) free((void *)p);
}

template <typename Element, typename List>
class apc_list_array_tt {
    struct array_t {
        uint32_t count;
        List* lists[0];
        
        static size_t byteSize(uint32_t count) {
            return sizeof(array_t) + count*sizeof(lists[0]);
        }
        size_t byteSize() {
            return byteSize(count);
        }
    };
    
protected:
    class iterator {
        List **lists;
        List **listsEnd;
        typename List::iterator m, mEnd;
        
    public:
        iterator(List **begin, List **end)
        : lists(begin), listsEnd(end)
        {
            if (begin != end) {
                m = (*begin)->begin();
                mEnd = (*begin)->end();
            }
        }
        
        const Element& operator * () const {
            return *m;
        }
        Element& operator * () {
            return *m;
        }
        
        bool operator != (const iterator& rhs) const {
            if (lists != rhs.lists) return true;
            if (lists == listsEnd) return false;  // m is undefined
            if (m != rhs.m) return true;
            return false;
        }
        
        const iterator& operator ++ () {
            assert(m != mEnd);
            m++;
            if (m == mEnd) {
                assert(lists != listsEnd);
                lists++;
                if (lists != listsEnd) {
                    m = (*lists)->begin();
                    mEnd = (*lists)->end();
                }
            }
            return *this;
        }
    };
    
private:
    union {
        List* list;
        uintptr_t arrayAndFlag;
    };
    
    bool hasArray() const {
        return arrayAndFlag & 1;
    }
    
    array_t *array() {
        return (array_t *)(arrayAndFlag & ~1);
    }
    
    void setArray(array_t *array) {
        arrayAndFlag = (uintptr_t)array | 1;
    }
    
public:
    
    uint32_t count() {
        uint32_t result = 0;
        for (auto lists = beginLists(), end = endLists();
             lists != end;
             ++lists)
        {
            result += (*lists)->count;
        }
        return result;
    }
    
    iterator begin() {
        return iterator(beginLists(), endLists());
    }
    
    iterator end() {
        List **e = endLists();
        return iterator(e, e);
    }
    
    
    uint32_t countLists() {
        if (hasArray()) {
            return array()->count;
        } else if (list) {
            return 1;
        } else {
            return 0;
        }
    }
    
    List** beginLists() {
        if (hasArray()) {
            return array()->lists;
        } else {
            return &list;
        }
    }
    
    List** endLists() {
        if (hasArray()) {
            return array()->lists + array()->count;
        } else if (list) {
            return &list + 1;
        } else {
            return &list;
        }
    }
    
    void attachLists(List* const * addedLists, uint32_t addedCount) {
        if (addedCount == 0) return;
        
        if (hasArray()) {
            // many lists -> many lists
            uint32_t oldCount = array()->count;
            uint32_t newCount = oldCount + addedCount;
            setArray((array_t *)realloc(array(), array_t::byteSize(newCount)));
            array()->count = newCount;
            memmove(array()->lists + addedCount, array()->lists,
                    oldCount * sizeof(array()->lists[0]));
            memcpy(array()->lists, addedLists,
                   addedCount * sizeof(array()->lists[0]));
        }
        else if (!list  &&  addedCount == 1) {
            // 0 lists -> 1 list
            list = addedLists[0];
        }
        else {
            // 1 list -> many lists
            List* oldList = list;
            uint32_t oldCount = oldList ? 1 : 0;
            uint32_t newCount = oldCount + addedCount;
            setArray((array_t *)malloc(array_t::byteSize(newCount)));
            array()->count = newCount;
            if (oldList) array()->lists[addedCount] = oldList;
            memcpy(array()->lists, addedLists,
                   addedCount * sizeof(array()->lists[0]));
        }
    }
    
    void deleteElement(Element* elm) {
        
        List* i_free = NULL;
        if(hasArray()) {
            
            array_t* a = array();
            for (uint32_t i = 0; i < a->count; i++) {
                
                List* j_list = a->lists[i];//apc_method_list
                for (uint32_t j = 0; j < j_list->count; j++) {
                    
                    j_list->deleteElement(elm);
                }
            }
        } else if (list) {
            
            list->deleteElement(elm);
        }
    }
    
    void tryFree() {
        if (hasArray()) {
            for (uint32_t i = 0; i < array()->count; i++) {
                try_free(array()->lists[i]);
            }
            try_free(array());
        }
        else if (list) {
            try_free(list);
        }
    }
    
    template<typename Result>
    Result duplicate() {
        Result result;
        
        if (hasArray()) {
            array_t *a = array();
            result.setArray((array_t *)memdup(a, a->byteSize()));
            for (uint32_t i = 0; i < a->count; i++) {
                result.array()->lists[i] = a->lists[i]->duplicate();
            }
        } else if (list) {
            result.list = list->duplicate();
        } else {
            result.list = nil;
        }
        
        return result;
    }
};

class apc_method_array_t :
public apc_list_array_tt<apc_method_t, apc_method_list_t>
{
    typedef apc_list_array_tt<apc_method_t, apc_method_list_t> Super;
    
public:
    apc_method_list_t **beginCategoryMethodLists() {
        return beginLists();
    }
    
    apc_method_list_t **endCategoryMethodLists(Class cls);
    
    apc_method_array_t duplicate() {
        return Super::duplicate<apc_method_array_t>();
    }
};

class apc_property_array_t :
public apc_list_array_tt<apc_property_t, apc_property_list_t>
{
    typedef apc_list_array_tt<apc_property_t, apc_property_list_t> Super;
    
public:
    apc_property_array_t duplicate() {
        return Super::duplicate<apc_property_array_t>();
    }
};

class apc_protocol_array_t :
public apc_list_array_tt<apc_protocol_ref_t, apc_protocol_list_t>
{
    typedef apc_list_array_tt<apc_protocol_ref_t, apc_protocol_list_t> Super;
    
public:
    apc_protocol_array_t duplicate() {
        return Super::duplicate<apc_protocol_array_t>();
    }
};


struct apc_class_rw_t {
    uint32_t flags;
    uint32_t version;
    
    const apc_class_ro_t *ro;
    
    apc_method_array_t methods;
    apc_property_array_t properties;
    apc_protocol_array_t protocols;
    
    Class firstSubclass;
    Class nextSiblingClass;
    
    char *demangledName;
    
    void setFlags(uint32_t set)
    {
        OSAtomicOr32Barrier(set, &flags);
    }
    
    void clearFlags(uint32_t clear)
    {
        OSAtomicXor32Barrier(clear, &flags);
    }
    
    // set and clear must not overlap
    void changeFlags(uint32_t set, uint32_t clear)
    {
        assert((set & clear) == 0);
        
        uint32_t oldf, newf;
        do {
            oldf = flags;
            newf = (oldf | set) & ~clear;
        } while (!OSAtomicCompareAndSwap32Barrier(oldf, newf, (volatile int32_t *)&flags));
    }
};

struct apc_class_data_bits_t {
    
    // Values are the FAST_ flags above.
    uintptr_t bits;
public:
    
    apc_class_rw_t* data() {
#if !__LP64__
#define FAST_DATA_MASK        0xfffffffcUL
#elif 1
#define FAST_DATA_MASK          0x00007ffffffffff8UL
#else
#define FAST_DATA_MASK          0x00007ffffffffff8UL
#endif
        return (apc_class_rw_t *)(bits & FAST_DATA_MASK);
    }
};

struct apc_objc_class : apc_objc_object {
    // Class ISA;
    APCClass superclass;
    apc_cache_t cache;             // formerly cache pointer and vtable
    apc_class_data_bits_t bits;    // apc_class_rw_t * plus custom rr/alloc flags
    
    apc_class_rw_t *data() {
        return bits.data();
    }
    
    // Locking: To prevent concurrent realization, hold runtimeLock.
    bool isRealized() {
#define RW_REALIZED           (1<<31)
        return data()->flags & RW_REALIZED;
    }
};




/*
 ---------------------------------
 ---------------------------------
 ---------------------------------
 */
#pragma mark - objc-object.h


#if SUPPORT_TAGGED_POINTERS

#define TAG_COUNT 8
#define TAG_SLOT_MASK 0xf

#if SUPPORT_MSB_TAGGED_POINTERS
#   define TAG_MASK (1ULL<<63)
#   define TAG_SLOT_SHIFT 60
#   define TAG_PAYLOAD_LSHIFT 4
#   define TAG_PAYLOAD_RSHIFT 4
#else
#   define TAG_MASK 1
#   define TAG_SLOT_SHIFT 0
#   define TAG_PAYLOAD_LSHIFT 0
#   define TAG_PAYLOAD_RSHIFT 4
#endif

#endif

// Mix-in for classes that must not be copied.
class nocopy_t {
private:
    nocopy_t(const nocopy_t&) = delete;
    const nocopy_t& operator=(const nocopy_t&) = delete;
protected:
    nocopy_t() { }
    ~nocopy_t() { }
};

template <bool Debug>
class rwlock_tt : nocopy_t {
    pthread_rwlock_t mLock;
    
public:
    rwlock_tt() : mLock(PTHREAD_RWLOCK_INITIALIZER) { }

    
    void write()
    {
//        lockdebug_rwlock_write(this);
//
//        qosStartOverride();
//        int err = pthread_rwlock_wrlock(&mLock);
//        if (err) _objc_fatal("pthread_rwlock_wrlock failed (%d)", err);
    }
    
    void unlockWrite()
    {
//        lockdebug_rwlock_unlock_write(this);
//
//        int err = pthread_rwlock_unlock(&mLock);
//        if (err) _objc_fatal("pthread_rwlock_unlock failed (%d)", err);
//        qosEndOverride();
    }
};
using rwlock_t = rwlock_tt<DEBUG>;
//#if __OBJC2__
//extern rwlock_t runtimeLock;
//#else
//extern mutex_t classLock;
//extern mutex_t methodListLock;
//#endif

class rwlock_writer_t : nocopy_t {
    rwlock_t& lock;
public:
    rwlock_writer_t(rwlock_t& newLock) : lock(newLock) { lock.write(); }
    ~rwlock_writer_t() { lock.unlockWrite(); }
};


void apc_objc_removeMethod(Class cls, SEL name)
{
//    rwlock_t* ise = &runtimeLock;
    apc_objc_class* clazz = (__bridge apc_objc_class*)(cls);
    
    unsigned int count;
    apc_method_t** methods = (apc_method_t**)(class_copyMethodList(cls, &count));
    apc_method_t* method;
    while (count--) {
        
        if(((method = (apc_method_t*)methods[count])->name) == name){
            
            clazz->data()->methods.deleteElement(method);
            _objc_flush_caches(cls);
            break;
        }
    }
}

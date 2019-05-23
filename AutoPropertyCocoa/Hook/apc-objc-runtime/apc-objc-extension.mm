//
//  apc-objc-private.cpp
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/5.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "apc-objc-runtimelock.h"
#include "apc-objc-extension.h"
#include "apc-objc-config.h"

/*
 ---------------------------------
 ---------------------------------
 ---------------------------------
 */
#pragma mark - objc-private.h
//#include <stdint.h>
//#include <assert.h>
//#include <cstddef>
#include <pthread.h>
#include <iterator>

struct apc_objc_class;
struct apc_objc_object;

typedef struct apc_objc_class *APCClass;
typedef struct apc_objc_object *id;

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
    apc_isa_t isa;
};

struct apc_method_t {
    SEL name;
    const char *types;
    IMP imp;
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

typedef uintptr_t apc_protocol_ref_t;  // protocol_t *, but unremapped
typedef apc_protocol_ref_t* iterator;
typedef const apc_protocol_ref_t* const_iterator;
struct apc_protocol_list_t {
    // count is 64-bit by accident.
    uintptr_t count;
    apc_protocol_ref_t list[0]; // variable-size
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
    
    bool deleteElement(Element* elm) {
        
        Element*    item;
        size_t      size = sizeof(Element);
        uint32_t    idx = UINT32_MAX;
        for(uint32_t i = 0 ; i < count ; i++){
            
            item = (Element *)((char*)&first + i*size);
            if(item == elm){
                
                idx = i;
                break;
            }
        }
        
        if(idx == UINT32_MAX){
            
            return false;
        }
        
        Element* pre  = NULL;
        Element* next = NULL;
        for(uint32_t i = 0 , j = i ; i < count ; i++){
            
            if(i < idx) {
                
                continue;
            }
            
            pre  = (Element*)((char*)&first + i*size);
            if(i == count -1) {
                
                memset(pre, 0, size);
            } else {
                
                next = (Element*)((char*)&first + (i + 1)*size);
                memcpy(pre, next, sizeof(Element));
            }
            
            j++;
        }
        count --;
        return true;
    }
    
    uint32_t entsize() const {
        return entsizeAndFlags & ~FlagMask;
    }
    uint32_t flags() const {
        return entsizeAndFlags & FlagMask;
    }
    
    size_t byteSize() const {
        return sizeof(*this) + (count-1)*entsize();
    }
    
    struct iterator;
    struct iterator {
        uint32_t entsize;
        uint32_t index;  // keeping track of this saves a divide in operator-
        Element* element;
    };
};

struct apc_ivar_list_t : apc_entsize_list_tt<apc_ivar_t, apc_ivar_list_t, 0> {
};

struct apc_property_list_t : apc_entsize_list_tt<apc_property_t, apc_property_list_t, 0> {
};

struct apc_method_list_t : apc_entsize_list_tt<apc_method_t, apc_method_list_t, 0x3> {
};

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
};

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
    
    
    void deleteElement(Element* elm) {
        
        if(hasArray()) {
            
            array_t* a = array();
            for (uint32_t i = 0; i < a->count; i++) {
                
                //List : apc_method_list
                List* j_list = a->lists[i];
                for (uint32_t j = 0; j < j_list->count; j++) {
                    
                    if(j_list->deleteElement(elm)) {
                        
                        apc_method_list_t* lili;
                        lili->count;
                        /** 空表删掉 */
                        if(j_list->count == 0){
#warning <#message#>
                        }
                        return;
                    }
                }
            }
        } else if (list) {
            
            if(list->deleteElement(elm)) {
                
                return;
            }
        }
        
        return;
        
        ///many -> many new array
        
        ///many -> 1 new array
        
        ///1 -> 0 try_free
        
    }
};

class apc_method_array_t :
public apc_list_array_tt<apc_method_t, apc_method_list_t>
{
    typedef apc_list_array_tt<apc_method_t, apc_method_list_t> Super;
    
public:
    apc_method_list_t **endCategoryMethodLists(Class cls);
};

class apc_property_array_t :
public apc_list_array_tt<apc_property_t, apc_property_list_t>
{
    typedef apc_list_array_tt<apc_property_t, apc_property_list_t> Super;
};

class apc_protocol_array_t :
public apc_list_array_tt<apc_protocol_ref_t, apc_protocol_list_t>
{
    typedef apc_list_array_tt<apc_protocol_ref_t, apc_protocol_list_t> Super;
};


struct apc_class_rw_t {
    uint32_t                flags;
    uint32_t                version;
    
    const apc_class_ro_t *  ro;
    
    apc_method_array_t      methods;
    apc_property_array_t    properties;
    apc_protocol_array_t    protocols;
    
    Class                   firstSubclass;
    Class                   nextSiblingClass;
    
    char *                  demangledName;
};

struct apc_class_data_bits_t {
    
    // Values are the FAST_ flags above.
    uintptr_t bits;
public:
    
    apc_class_rw_t* data() {
#if !__LP64__
#define FAST_DATA_MASK          0xfffffffcUL
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
};

/*
 ---------------------------------
 ---------------------------------
 ---------------------------------
 */
#pragma mark - objc-object.h
void class_removeMethod_APC_OBJC2(Class cls, SEL name)
{
    
#if __OBJC2__
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    static pthread_mutex_t _func_lock
    =
    PTHREAD_MUTEX_INITIALIZER;
    
    pthread_mutex_lock(&_func_lock);
    
    apc_objc_class* clazz = (__bridge apc_objc_class*)(cls);
    unsigned int    count;
    apc_method_t**  methods = (apc_method_t**)(class_copyMethodList(cls, &count));
    apc_method_t*   method;
    
#warning log each ptr address
    
    {
        for (int i =0; i<count; i++) {
            
            NSLog(@"<>_<>:%p",methods[i]);
        }
    }
    
    while (count--) {
        
        if(((method = (apc_method_t*)methods[count])->name) == name){
            
//            @lockruntime({
//
//                clazz->data()->methods.deleteElement(method);
//            });
            
            apc_objcruntimelock_lock(^{
                
                clazz->data()->methods.deleteElement(method);
            });
            
#warning alternative
//            _objc_flush_caches(cls);
//            _objc_flush_caches(nil);
            break;
        }
    }
    free(methods);
    pthread_mutex_unlock(&_func_lock);
#pragma clang diagnostic pop
#endif
}


IMP class_itMethodImplementation_APC(Class cls, SEL name)
{
    unsigned int    count;
    apc_method_t**  methods = (apc_method_t**)(class_copyMethodList(cls, &count));
    apc_method_t*   method;
    while (count--) {
        
        if(((method = (apc_method_t*)methods[count])->name) == name){
            
            return method->imp;
        }
    }
    return NULL;
}

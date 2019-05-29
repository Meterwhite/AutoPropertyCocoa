//
//  APCRuntime.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#include "APCStringStringDictionary.h"
#include "APCProxyInstanceDisposer.h"
#include "NSString+APCExtension.h"
#include "apc-objc-runtimelock.h"
#include "APCPropertyHook.h"
#include "APCClassMapper.h"
#include <objc/message.h>
#include "apc-objc-os.h"
#include "APCRuntime.h"
#include "APCScope.h"

#pragma mark - Private
static SEL _apc_sel_unhook = @selector(unhook);

#pragma mark - For lock - private
/** This lock is used for Class. */
static pthread_rwlock_t apc_runtimelock = PTHREAD_RWLOCK_INITIALIZER;

#pragma mark - For class - private

/** { Instance : { Property : Hook } } */
const static char           _keyForAPCInstanceBoundMapper = '\0';

/** Class : { sKey : Hook -> [Property] } */
static NSMapTable<Class,APCStringStringDictionary<__kindof APCMethodHook*>*>*
_apc_runtime_property_classmapper;

/** Inherited relationship mapping for registered classes. */
static APCClassMapper*      _apc_runtime_inherit_map;
/** Quickly detect registered instance objects. */
static NSMapTable*          _apc_runtime_proxyinstances;

/**
 { Class : { sKey : Hook -> [Property] } }
 */
static NSMapTable<Class,APCStringStringDictionary<__kindof APCMethodHook*>*>*
apc_runtime_property_classmapper()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _apc_runtime_property_classmapper = [NSMapTable strongToStrongObjectsMapTable];
    });
    return _apc_runtime_property_classmapper;
}

NS_INLINE APCPropertyHook* _Nonnull
apc_runtime_propertyhook(Class __unsafe_unretained _Nonnull clazz, NSString* _Nonnull property)
{
    return [[apc_runtime_property_classmapper() objectForKey:clazz] objectForKey:property];
}

static APCClassMapper* apc_runtime_inherit_map()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _apc_runtime_inherit_map = [[APCClassMapper alloc] init];
    });
    return _apc_runtime_inherit_map;
}

static void apc_runtime_inherit_register(Class cls)
{
    APCClassMapper* map = apc_runtime_inherit_map();
    
    if(![map containsClass:cls])
        
        [map addClass:cls];
}

static void apc_runtime_inherit_dispose(Class cls)
{
    APCClassMapper* map = apc_runtime_inherit_map();
    
    if([map containsClass:cls])
        
        [map removeClass:cls];
}

/**
 {(weak)instance : (strong)disposer}
 The map of weakToStrong type can be delayed release.
 Manager memory by objc runtime ,Do not delete objects manually!
 */
static NSMapTable* apc_runtime_proxyinstances()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apc_runtime_proxyinstances = [NSMapTable weakToStrongObjectsMapTable];
    });
    return _apc_runtime_proxyinstances;
}

NS_INLINE APCPropertyHook* apc_getPropertyhook_nolock(Class clazz, NSString* property)
{
    if(clazz == nil){
        
        return (APCPropertyHook*)0;
    }
    return apc_runtime_propertyhook(clazz, property);
}

NS_INLINE void apc_runtime_proxyinstanceRegister(APCProxyInstance* instance, Class cls)
{
    [apc_runtime_proxyinstances() setObject:[[APCProxyInstanceDisposer alloc] initWithClass:cls]
                                     forKey:instance];
}

NS_INLINE void apc_propertyhook_dispose_nolock(APCPropertyHook* hook)
{
    NSMapTable*         c_map   = apc_runtime_property_classmapper();
    ///Update super hook
    for (Class iCls in c_map) {
        
        if(apc_class_getSuperclass(iCls) == hook.hookclass){
            
            ///key - hook
            for (APCPropertyHook* iHook in [[c_map objectForKey:iCls] objectEnumerator]) {
                
                iHook->_superhook = hook->_superhook;
            }
        }
    }
    ///Remova all.
    [[c_map objectForKey:hook.hookclass] removeObjectForKey:hook.propertyName];
    
    ///Update class inheritence list
    if(0 == [[c_map objectForKey:hook.hookclass] count]){
        
        apc_runtime_inherit_dispose(hook.hookclass);
    }
}

#pragma mark - For hook - public
void apc_unhook_allClass(void)
{
    apc_runtimelock_writer_t writting(apc_runtimelock);
    
    NSMapTable*         c_map   = apc_runtime_property_classmapper();
    
    if([c_map count] == 0) return;
    
    for (APCStringStringDictionary* dictionary in [c_map objectEnumerator]) {
        
        for (__kindof APCMethodHook* hook in [dictionary objectEnumerator]) {
            
            ///Ensure that - unhook is without runtimelock.
            ((void(*)(id,SEL))objc_msgSend)(hook, _apc_sel_unhook);
        }
    }
    ///Clean cached and inhertitance data at once.
    [c_map removeAllObjects];
    [apc_runtime_inherit_map() removeAllClasses];
}

void apc_unhook_allInstance(void)
{
    ///Copy to prevent mutations when enumerating.
    NSArray* allInstances = [apc_runtime_proxyinstances() objectEnumerator].allObjects;
    for (APCProxyInstance* item in allInstances) {
        
        apc_instance_unhookFromProxyClass(item);
    }
}

void apc_unhook_all(void)
{
    apc_unhook_allInstance();
    apc_unhook_allClass();
}

APCPropertyHook* apc_lookup_propertyhook(Class clazz, NSString* property)
{
    
    if(clazz == nil){
        
        return (APCPropertyHook*)0;
    }
    
    apc_runtimelock_reader_t reading(apc_runtimelock);
    APCPropertyHook* ret = nil;
    do {
        
        if(nil != (ret = apc_runtime_propertyhook(clazz, property)))
            
            break;
    } while (nil != (clazz = class_getSuperclass(clazz)));
    
    return ret;
}

APCPropertyHook* apc_getPropertyhook(Class clazz, NSString* property)
{
    if(clazz == nil){
        
        return (APCPropertyHook*)0;
    }
    
    apc_runtimelock_reader_t reading(apc_runtimelock);
    
    return apc_runtime_propertyhook(clazz, property);
}

APCPropertyHook* apc_lookup_superPropertyhook_inRange(Class from, Class to, NSString* property)
{
    apc_runtimelock_reader_t reading(apc_runtimelock);
    
    APCPropertyHook* ret;
    while ([(from = apc_class_getSuperclass(from)) isSubclassOfClass:to]) {
        
        if(nil != (ret = apc_runtime_propertyhook(from, property)))
            
            return ret;
    }
    return (APCPropertyHook*)0;
}

APCPropertyHook* apc_lookup_sourcePropertyhook_inRange(Class from, Class to, NSString* property)
{
    apc_runtimelock_reader_t reading(apc_runtimelock);
    
    if([from isSubclassOfClass:to]){
        
        APCPropertyHook* ret;
        do {
            
            if(nil != (ret = apc_runtime_propertyhook(from, property)) &&
               ret->_old_implementation)
                
                return ret;
            
        } while ([(from = apc_class_getSuperclass(from)) isSubclassOfClass:to]);
    }
    return (APCPropertyHook*)0;
}

__kindof APCHookProperty* apc_lookup_property(Class cls, NSString* property, SEL outlet)
{
    apc_runtimelock_reader_t reading(apc_runtimelock);
    
    APCPropertyHook* hook = apc_getPropertyhook_nolock(cls, property);
    return ((__kindof APCHookProperty*(*)(id,SEL))objc_msgSend)(hook, outlet);
}

APCPropertyHook* apc_propertyhook_rootHook(APCPropertyHook* hook)
{
    apc_runtimelock_reader_t reading(apc_runtimelock);
    
    APCPropertyHook* root = hook;
    do {
        
        if(root.superhook == nil)
            break;
        
        root = root.superhook;
    } while (1);
    
    return root;
}

__kindof APCHookProperty* apc_propertyhook_lookupSuperProperty(APCPropertyHook* hook, const char* ivarname)
{
    APCPropertyOwnerKind owner = hook.kindOfOwner;//Symmetric locking.
    if(owner == APCPropertyOwnerKindOfClass){
        
        pthread_rwlock_rdlock(&apc_runtimelock);
    }
    
    __kindof APCHookProperty* ret;
    Ivar  ivar = class_getInstanceVariable(object_getClass(hook), ivarname);
    do {
        
        
        if((ret = object_getIvar(hook, ivar))){
            
            break;
        }
    } while (nil != (hook = hook->_superhook));
    
    if(owner == APCPropertyOwnerKindOfClass){
        
        pthread_rwlock_unlock(&apc_runtimelock);
    }
    
    return ret;
}

#pragma mark - For class - public

Class apc_class_getSuperclass(Class cls)
{
    return [apc_runtime_inherit_map() superclassOfClass:cls];
}

void apc_class_unhook(Class cls)
{
    apc_runtimelock_writer_t writting(apc_runtimelock);
    
    APCStringStringDictionary* dictionary
    =
    [apc_runtime_property_classmapper() objectForKey:cls];
    
    if(dictionary == nil) return;
    
    for (APCPropertyHook* iHook in dictionary.objectEnumerator) {
        
        ((void(*)(id,SEL))objc_msgSend)(iHook, _apc_sel_unhook);
    }
}

void apc_registerProperty(APCHookProperty* p)
{
    apc_runtimelock_writer_t writting(apc_runtimelock);
    
    APCStringStringDictionary* dictionary
    =
    [apc_runtime_property_classmapper() objectForKey:p->_des_class];
    
    APCPropertyHook*    itHook;
    APCPropertyHook*    hook;
    if(dictionary == nil) {
        
        dictionary = [APCStringStringDictionary dictionary];
        [apc_runtime_property_classmapper() setObject:dictionary forKey:p->_des_class];
        apc_runtime_inherit_register(p->_des_class);
    }
    
    hook = [dictionary objectForKey:p->_hooked_name];
    
    if(hook != nil){
        
        ((void(*)(id,SEL,id))objc_msgSend)(hook, p.inlet, p);
        return;
    }
    
    ///Creat new hook
    hook = [APCPropertyHook hookWithProperty:p];
    [dictionary setObject:hook forKey:p.mappingKeyString];
    
    ///Update superhook
    hook->_superhook = apc_getPropertyhook_nolock(apc_class_getSuperclass(p->_des_class), p->_hooked_name);
    
    ///Subhook
    for (Class iCls in apc_runtime_property_classmapper()) {

        if(apc_class_getSuperclass(iCls) ==  p->_des_class){
            
            if(nil != (itHook = apc_getPropertyhook_nolock(iCls, p->_hooked_name))){
                
                itHook->_superhook = hook;
            }
        }
    }
}

void apc_disposeProperty(APCHookProperty* _Nonnull p)
{
    if(!p.associatedHook) return;
    
    apc_runtimelock_writer_t writting(apc_runtimelock);
    
    [p.associatedHook unbindProperty:p];
    
    if([p.associatedHook isEmpty]){
        
        [[apc_runtime_property_classmapper() objectForKey:p->_des_class]
         
         removeObjectsForKey:p->_hooked_name];
        apc_propertyhook_dispose_nolock(p.associatedHook);
    }else{
        
        [[apc_runtime_property_classmapper() objectForKey:p->_des_class]
         
         removeObjectForKey:p->_hooked_name];
    }
}

__kindof APCHookProperty* apc_property_getSuperProperty(APCHookProperty* p)
{
    apc_runtimelock_reader_t reading(apc_runtimelock);
    
    APCPropertyHook* hook;
    if(p.kindOfOwner == APCPropertyOwnerKindOfInstance){
        
        Class cls = p->_des_class;
        
        do {
            
            if(nil != (hook = apc_runtime_propertyhook(cls, p->_hooked_name))){
                break;
            }
        } while (nil != (cls = class_getSuperclass(cls)));
    } else {
        
        hook = [apc_runtime_propertyhook(p->_des_class, p->_hooked_name) superhook];
    }
    
    if(hook != nil) {
        
        APCHookProperty* item;
        do {
            
            if(nil != (item = ((id(*)(id,SEL))objc_msgSend)(hook, p.outlet))){
                
                return item;
            }
        }while (nil != (hook = [hook superhook]));
    }

    return (APCHookProperty*)0;
}

#pragma mark - For instance - private

/**
 (string)property : hook
 */
static APCStringStringDictionary<__kindof APCMethodHook*>* apc_boundInstanceMapper(APCProxyInstance* instance)
{
    APCStringStringDictionary* dictionary;
    
    if(nil == (dictionary = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundMapper))){
        
        @synchronized (instance) {
            
            if(nil == (dictionary = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundMapper))){
                
                dictionary = [APCStringStringDictionary dictionary];
                objc_setAssociatedObject(instance
                                         , &_keyForAPCInstanceBoundMapper
                                         , dictionary
                                         , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    return dictionary;
}

NS_INLINE void apc_removeBoundInstanceMapper(APCProxyInstance* instance)
{
    @synchronized (instance) {
        
        objc_setAssociatedObject(instance
                                 , &_keyForAPCInstanceBoundMapper
                                 , nil
                                 , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

NS_INLINE APCPropertyHook*
apc_instance_propertyhook(APCProxyInstance* instance, NSString* property)
{
    return [apc_boundInstanceMapper(instance) objectForKey:property];
}

__kindof APCHookProperty* apc_lookup_instanceProperty(APCProxyInstance* instance, NSString* property, SEL outlet)
{
    if(!apc_object_isProxyInstance(instance)) return (APCHookProperty*)0;
    
    @synchronized (instance) {
        
        APCPropertyHook* hook = apc_instance_propertyhook(instance, property);
        return ((__kindof APCHookProperty*(*)(id,SEL))objc_msgSend)(hook, outlet);
    }
}

APCPropertyHook* apc_lookup_instancePropertyhook(APCProxyInstance* instance, NSString* property)
{
    return apc_object_isProxyInstance(instance)
    
    ?   apc_instance_propertyhook(instance, property)
    :   nil;
}


#pragma mark - For instance - public
void apc_instance_setAssociatedProperty(APCProxyInstance* instance, APCHookProperty* p)
{
    if(!apc_object_isProxyInstance(instance)) return;
    
    @synchronized (instance) {
        
        APCPropertyHook* hook = [apc_boundInstanceMapper(instance) objectForKey:p->_hooked_name];
        
        if(hook == nil){
            
            hook = [APCPropertyHook hookWithProperty:p];
            [apc_boundInstanceMapper(instance) setObject:hook forKey:p.mappingKeyString];
        }else{
            
            [hook bindProperty:p];
        }
    }
}

void apc_instance_removeAssociatedProperty(APCProxyInstance* instance, APCHookProperty* p)
{
    if(!apc_object_isProxyInstance(instance) || p.associatedHook == nil) return;
    
    
    @synchronized (instance) {
        
        APCStringStringDictionary* dictionary = apc_boundInstanceMapper(instance);
        [p.associatedHook unbindProperty:p];
        if([p.associatedHook isEmpty]){
            
            [dictionary removeObjectsForKey:p->_hooked_name];
        }else{
            
            [dictionary removeObjectForKey:p->_hooked_name];
        }
        if([dictionary count] == 0){
            
            apc_instance_unhookFromProxyClass(instance);
        }
    }
}

#pragma mark - Proxy class - private
static const char* _apcProxyClassID = "<APCProxyClass>:";
/** free! */
NS_INLINE char* apc_instanceProxyClassName(id instance)
{
    const char* cname = class_getName(object_getClass(instance));
    char h_str[2*sizeof(uintptr_t)] = {0};
    sprintf(h_str,"%lX",[instance hash]);
    char* buf = (char*)malloc(strlen(cname) + strlen(_apcProxyClassID) + strlen(h_str) + 1);
    buf[0] = '\0';
    strcat(buf, cname);
    strcat(buf, _apcProxyClassID);
    strcat(buf, h_str);
    return buf;
}

#pragma mark - Proxy class - public
BOOL apc_class_conformsProxyClass(Class cls)
{
    return (NULL != strstr(class_getName(cls), _apcProxyClassID));
}

Class apc_class_unproxyClass(APCProxyClass cls)
{
    const char* cname = class_getName(cls);
    const char* loc = strstr(cname, _apcProxyClassID);
    if(loc != NULL){
        
        char* name = (char*)malloc(1 + loc - cname);
        strncpy(name, cname, loc - cname);
        name[loc - cname] = '\0';
        cls = objc_getClass(name);
        free(name);
    }
    return (Class)cls;
}

Class apc_object_unproxyClass(id obj)
{
    Class ret = object_getClass(obj);
    if(apc_object_isProxyInstance(obj)){
        
        ret = apc_class_unproxyClass(ret);
    }
    return (Class)ret;
}

BOOL apc_object_isProxyInstance(id instance)
{
    return ([apc_runtime_proxyinstances() objectForKey:instance] != nil);
}

APCProxyClass apc_instance_getProxyClass(APCProxyInstance* instance)
{
    char* name = apc_instanceProxyClassName(instance);
    Class cls = objc_getClass(name);
    free(name);
    return (APCProxyClass)cls;
}

APCProxyClass apc_object_hookWithProxyClass(id _Nonnull instance)
{
    @synchronized (instance) {
        
        if(nil != [apc_runtime_proxyinstances() objectForKey:instance]) {
            
            return object_getClass(instance);
        }
        
        char*           name = apc_instanceProxyClassName(instance);
        APCProxyClass   cls  = objc_allocateClassPair(object_getClass(instance), name, 0);
        if(cls != nil){
            
            apc_runtime_proxyinstanceRegister(instance, cls);
            objc_registerClassPair(cls);
            object_setClass(instance, cls);
        }else if (nil == (cls = objc_getClass(name))){
            
            fprintf(stderr, "APC: Can not register class '%s' in runtime.",name);
        }
        free(name);
        return (APCProxyClass)cls;
    }
}

void apc_instance_unhookFromProxyClass(APCProxyInstance* instance)
{
    if(!apc_object_isProxyInstance(instance)) return;
    
    @synchronized (instance) {
        
        object_setClass(instance
                        , apc_class_unproxyClass(object_getClass(instance)));
        
        apc_removeBoundInstanceMapper(instance);
        
        /**
         Unlike the object that is auto released , the 'ProxyClass' will be dispose immediately.
         */
        [apc_runtime_proxyinstances() removeObjectForKey:instance];
    }
}

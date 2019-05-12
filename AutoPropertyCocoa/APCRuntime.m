//
//  APCRuntime.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyHook.h"
#import "APCClassMapper.h"
#import <objc/message.h>
#import "APCRuntime.h"
#import "APCScope.h"

NS_INLINE APCPropertyHook* apc_instance_propertyhook(id instance, NSString* property);

#pragma mark - For class - private

#define APC_RUNTIME_LOCK \
\
dispatch_semaphore_wait(_apc_runtime_map_lock, DISPATCH_TIME_FOREVER)

#define APC_RUNTIME_UNLOCK \
\
dispatch_semaphore_signal(_apc_runtime_map_lock)

/** Instance : Property : Hook */
const static char           _keyForAPCInstanceBoundMapper = '\0';
/** Class : Property_key : Hook(:Properties) */
static NSMapTable*          _apc_runtime_property_classmapper;
/** (weak)ThreadID : (weak)Instance : (strong)CMDs*/
static NSMapTable*          _apc_object_hookRecursiveMapper;
static APCClassMapper*      _apc_runtime_inherit_map;
static dispatch_semaphore_t _apc_runtime_map_lock;
static NSHashTable*         _apc_runtime_proxyinstances;


static NSMapTable* apc_runtime_property_classmapper()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apc_runtime_map_lock = dispatch_semaphore_create(1);
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
    ///Forest
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _apc_runtime_inherit_map = [[APCClassMapper alloc] init];
    });
    return _apc_runtime_inherit_map;
}

static void apc_runtime_inherit_register(Class cls)
{
    APCClassMapper* map = apc_runtime_inherit_map();
    
    if(NO == [map containsClass:cls])
        
        [map addClass:cls];
}

static void apc_runtime_inherit_dispose(Class cls)
{
    APCClassMapper* map = apc_runtime_inherit_map();
    
    if(YES == [map containsClass:cls])
        
        [map removeClass:cls];
}

static NSHashTable* apc_runtime_proxyinstances()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apc_runtime_proxyinstances = [NSHashTable weakObjectsHashTable];
    });
    return _apc_runtime_proxyinstances;
}

#pragma mark - For hook - export
APCPropertyHook* apc_lookups_propertyhook(Class clazz, NSString* property)
{
    if(clazz == nil){
        
        return (APCPropertyHook*)0;
    }
    
    APCPropertyHook* ret = nil;
    do {
        
        if(nil != (ret = apc_runtime_propertyhook(clazz, property)))
            
            break;
    } while (nil != (clazz = apc_class_getSuperclass(clazz)));
    
    return ret;
}

APCPropertyHook* apc_lookup_propertyhook(Class clazz, NSString* property)
{
    if(clazz == nil){
        
        return (APCPropertyHook*)0;
    }
    return apc_runtime_propertyhook(clazz, property);
}

APCPropertyHook* apc_lookup_superPropertyhook_inRange(Class from, Class to, NSString* property)
{
    APCPropertyHook* ret;
    while (YES == [(from = apc_class_getSuperclass(from)) isSubclassOfClass:to]) {
        
        if(nil != (ret = apc_runtime_propertyhook(from, property)))
            
            return ret;
    }
    return (APCPropertyHook*)0;
}

APCPropertyHook* apc_lookup_implementationPropertyhook_inRange(Class from, Class to, NSString* property)
{
    if(YES == [from isSubclassOfClass:to]){
        
        APCPropertyHook*ret;
        do {
            
            if(nil != ((void)(ret = apc_runtime_propertyhook(from, property)), ret->_old_implementation))
                
                return ret;
            
        } while (YES == [(from = apc_class_getSuperclass(from)) isSubclassOfClass:to]);
    }
    return (APCPropertyHook*)0;
}

APCPropertyHook* apc_propertyhook_rootHook(APCPropertyHook* hook)
{
    APCPropertyHook* root = hook;
    
    do {
        
        if(root.superhook == nil)
            break;
        
        root = root.superhook;
    } while (1);
    
    return root;
}

void apc_propertyhook_delete(APCPropertyHook* hook)
{
    APC_RUNTIME_LOCK;
    
    [[apc_runtime_property_classmapper()
      
      objectForKey:hook.hookclass]
     
     removeObjectForKey:hook.hookMethod];
    
    APC_RUNTIME_UNLOCK;
}

APCPropertyHook* apc_lookup_instancePropertyhook(APCProxyInstance* instance, NSString* property)
{
    return apc_instance_propertyhook(instance, property);
}

#pragma mark - For class - export

Class apc_class_getSuperclass(Class cls)
{
    return [apc_runtime_inherit_map() superclassOfClass:cls];
}

void apc_registerProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    NSMutableDictionary*dictionary = [apc_runtime_property_classmapper() objectForKey:p->_des_class];
    APCPropertyHook*    itHook;
    APCPropertyHook*    hook;
    if(dictionary == nil) {
        
        dictionary = [NSMutableDictionary dictionary];
        [apc_runtime_property_classmapper() setObject:dictionary forKey:p->_des_class];
        apc_runtime_inherit_register(p->_des_class);
    }
    
    hook = dictionary[p->_hooked_name];
    
    if(hook != nil){
        
        [hook bindProperty:p];
        APC_RUNTIME_UNLOCK;
        return;
    }
    
    ///Creat new hook
    hook = [APCPropertyHook hookWithProperty:p];
    dictionary[p->_hooked_name] = hook;
    
    ///Update superhook
    hook->_superhook = apc_lookup_propertyhook(apc_class_getSuperclass(p->_des_class), p->_hooked_name);
    
    ///subhook
    
    for (Class itCls in apc_runtime_property_classmapper()) {

        if(apc_class_getSuperclass(itCls) ==  p->_des_class){
            
            if(nil != (itHook = apc_lookup_propertyhook(itCls, p->_hooked_name))){
                
                itHook->_superhook = hook;
            }
        }
    }
    
    APC_RUNTIME_UNLOCK;
}

void apc_disposeProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    NSMapTable*     c_map   = apc_runtime_property_classmapper();
    APCPropertyHook*hook    = apc_runtime_propertyhook(p->_des_class, p->_hooked_name);
    [hook unbindProperty:p];
    
    if(hook.isEmpty){
        
        ///Update super hook
        for (Class iCls in c_map) {
            
            if(apc_class_getSuperclass(iCls) == hook.hookclass){
                
                ///key - hook
                for (APCPropertyHook* iHook in [[c_map objectForKey:iCls] objectEnumerator]) {
                    
                    iHook->_superhook = hook->_superhook;
                }
            }
        }
        
        [[c_map objectForKey:hook.hookclass] removeObjectForKey:hook.hookMethod];
        
        ///Update classInheritenceList
        if(0 == [[c_map objectForKey:hook.hookclass] count]){
            
            apc_runtime_inherit_dispose(hook.hookclass);
        }
    }
    APC_RUNTIME_UNLOCK;
}


__kindof APCHookProperty* apc_property_getSuperProperty(APCHookProperty* p)
{
    APCPropertyHook* hook = apc_runtime_propertyhook(p->_des_class, p->_hooked_name);
    APCHookProperty* item;
    while (nil != (hook = [hook superhook])) {
        
        if(nil != (item = ((id(*)(id,SEL))objc_msgSend)(hook, p.outlet))){
            
            return item;
        }
    }
    
    return (APCHookProperty*)0;
}

NSArray<__kindof APCHookProperty*>*
apc_property_getSuperPropertyList(APCHookProperty* p)
{
    APCPropertyHook* hook = apc_runtime_propertyhook(p->_des_class, p->_hooked_name);
    NSMutableArray*  ret  = [NSMutableArray array];
    APCHookProperty* item;
    do {
        
        if(nil != (item = ((id(*)(id,SEL))objc_msgSend)(hook, p.outlet))){
            
            [ret addObject:item];
        }
    } while (nil != (hook = [hook superhook]));
    
    return [ret copy];
}

#pragma mark - For instance - private
static NSMapTable* apc_instanceBoundMapper(id instance)
{
    NSMapTable*         mapper;
    
    if(nil == (mapper = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundMapper))){
        
        @synchronized (instance) {
            
            if(nil == (mapper = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundMapper))){
                
                mapper = [NSMapTable strongToStrongObjectsMapTable];
                objc_setAssociatedObject(instance
                                         , &_keyForAPCInstanceBoundMapper
                                         , mapper
                                         , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    return mapper;
}

NS_INLINE APCPropertyHook*
apc_instance_propertyhook(id instance, NSString* property)
{
    return [apc_instanceBoundMapper(instance) objectForKey:property];
}
#pragma mark - For instance - export
void apc_instance_setAssociatedProperty(APCProxyInstance* instance, APCHookProperty* p)
{
    
    if(NO == apc_object_isProxyInstance(instance)){
        
        return;
    }
    
    APCPropertyHook* hook = [apc_instanceBoundMapper(instance) objectForKey:p->_hooked_name];
    
    if(hook == nil){
        
        @synchronized (instance) {
            
            if(nil == (hook = [apc_instanceBoundMapper(instance) objectForKey:p->_hooked_name])){
                
                hook = [APCPropertyHook hookWithProperty:p];
                [apc_instanceBoundMapper(instance) setObject:hook forKey:p->_hooked_name];
            }
        }
    }else{
        
        [hook bindProperty:p];
    }
}

void apc_instance_removeAssociatedProperty(APCProxyInstance* instance, APCHookProperty* p)
{
    if(NO == apc_object_isProxyInstance(instance)){
        
        return;
    }
    
    [apc_instance_propertyhook(instance, p->_hooked_name) unbindProperty:p];
}

#pragma mark - Proxy class - private
static const char* _apcProxyClassID = ".APCProxyClass+";
/** free! */
NS_INLINE char* apc_instanceProxyClassName(id instance)
{
    const char* cname = class_getName(object_getClass(instance));
    char h_str[2*sizeof(uintptr_t)] = {0};
    sprintf(h_str,"%lX",[instance hash]);
    char* buf = malloc(strlen(cname) + strlen(_apcProxyClassID) + strlen(h_str) + 1);
    buf[0] = '\0';
    strcat(buf, cname);
    strcat(buf, _apcProxyClassID);
    strcat(buf, h_str);
    return buf;
}

#pragma mark - Proxy class - export
BOOL apc_class_conformsProxyClass(Class cls)
{
    return ('\0' != strstr(class_getName(cls), _apcProxyClassID));
}

Class apc_class_unproxyClass(APCProxyClass cls)
{
    const char* cname = class_getName(cls);
    char* loc = strstr(cname, _apcProxyClassID);
    if(loc != '\0'){
        
        char* name = malloc(1 + loc - cname);
        strncpy(name, cname, loc - cname);
        name[loc - cname] = '\0';
        Class ret = objc_getClass(name);
        free(name);
        return ret;
    }
    return (Class)0;
}

void apc_class_disposeProxyClass(APCProxyClass cls)
{
    if(YES == apc_class_conformsProxyClass(cls)){
        
        objc_disposeClassPair(cls);
    }
}

BOOL apc_object_isProxyInstance(id instance)
{
    return [apc_runtime_proxyinstances() containsObject:instance];
}

APCProxyClass apc_instance_getProxyClass(APCProxyInstance* instance)
{
    char* name = apc_instanceProxyClassName(instance);
    Class cls = objc_getClass(name);
    free(name);
    return cls;
}

APCProxyClass apc_object_hookWithProxyClass(id _Nonnull instance)
{
    @synchronized (instance) {
        
        if(YES == [apc_runtime_proxyinstances() containsObject:instance]){
            
            return object_getClass(instance);
        }
        
        char*           name = apc_instanceProxyClassName(instance);
        APCProxyClass   cls  = objc_allocateClassPair(object_getClass(instance), name, 0);
        if(cls != nil){
            
            objc_registerClassPair(cls);
            object_setClass(instance, cls);
            [apc_runtime_proxyinstances() addObject:instance];
        }else if (nil == (cls = objc_getClass(name))){
            
            fprintf(stderr, "APC: Can not register class '%s' in runtime.",name);
        }
        free(name);
        return cls;
    }
}

APCProxyClass apc_instance_unhookFromProxyClass(APCProxyInstance* instance)
{
    @synchronized (instance) {
        
        if(NO == apc_object_isProxyInstance(instance)){
            
            return (APCProxyClass)0;
        }
        [apc_runtime_proxyinstances() removeObject:instance];
        
        return (APCProxyClass)
        
        object_setClass(instance, apc_class_unproxyClass(object_getClass(instance)));
    }
}

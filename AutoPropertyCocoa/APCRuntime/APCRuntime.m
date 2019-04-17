//
//  APCRuntime.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyHook.h"
#import "APCMethodHook.h"
#import "APCRuntime.h"
#import "APCScope.h"

#pragma mark - For class - private

#define APC_RUNTIME_LOCK \
\
dispatch_semaphore_wait(_apc_runtime_mapperlock, DISPATCH_TIME_FOREVER)

#define APC_RUNTIME_UNLOCK \
\
dispatch_semaphore_signal(_apc_runtime_mapperlock)

static dispatch_semaphore_t _apc_runtime_mapperlock;

///class : key : hook : properties
static NSMapTable*  _apc_runtime_property_classmapper;

static NSMapTable* apc_runtime_property_classmapper()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apc_runtime_mapperlock = dispatch_semaphore_create(1);
        _apc_runtime_property_classmapper = [NSMapTable strongToStrongObjectsMapTable];
    });
    return _apc_runtime_property_classmapper;
}

NS_INLINE APCPropertyHook* _Nonnull
apc_runtime_propertyhook(Class __unsafe_unretained _Nonnull clazz, NSString* _Nonnull property)
{
    return [[apc_runtime_property_classmapper() objectForKey:clazz] objectForKey:property];
}

#pragma mark - For class - export
void apc_registerProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    NSMutableDictionary*dictionary = [apc_runtime_property_classmapper() objectForKey:p->_des_class];
    APCPropertyHook*    hook;
    APCPropertyHook*    item;
    NSEnumerator*       e;
    
    if(dictionary == nil){
        
        dictionary = [NSMutableDictionary dictionary];
        [apc_runtime_property_classmapper() setObject:dictionary forKey:p->_des_class];
    }
    
    hook = dictionary[p->_hooked_name];
    
    if(hook == nil){
        
        hook = [APCPropertyHook hookWithProperty:p];
        dictionary[p->_hooked_name] = hook;
    }else{
        
        [hook bindProperty:p];
    }
    
    ///Reset superhook
    hook->_superhook
    = apc_runtime_propertyhook(class_getSuperclass(p->_des_class), p->_hooked_name);
    
    e = apc_runtime_property_classmapper().objectEnumerator;
    ///Reset subhook's superhook
    while (nil != (item = e.nextObject)) {
        
        if(class_getSuperclass(item.hookclass) == p->_des_class){
            
            item->_superhook = hook;
        }
    }
    
    APC_RUNTIME_UNLOCK;
}

void apc_disposeProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    APCPropertyHook* hook = apc_runtime_propertyhook( p->_des_class, p->_hooked_name);
    [hook unbindProperty:p];
    
    if(hook.isEmpty){
        ///Reset subhook's superhook
        
        APCPropertyHook* item;
        NSEnumerator* e = apc_runtime_property_classmapper().objectEnumerator;
        while (nil != (item = e.nextObject)) {
            
            if(class_getSuperclass(item.hookclass) == p->_des_class){
                
                item->_superhook = hook->_superhook;
            }
        }
        
        [apc_runtime_property_classmapper() removeObjectForKey:p->_hooked_name];
    }
    
    APC_RUNTIME_UNLOCK;
}

NSArray* apc_classBoundProperties(Class cls, NSString* property)
{
    return [apc_runtime_propertyhook(cls , property) boundProperties];
}

APCHookProperty* apc_property_getSuperProperty(APCHookProperty* p)
{
    
    NSEnumerator*   e = [[apc_runtime_propertyhook(p->_des_class, p->_hooked_name)
                          superhook] propertyEnumerator];
    APCHookProperty*item;
    while (nil != (item = e.nextObject)) {
        
        if(p.class == item.class){
            
            return p;
        }
    }
    
    return nil;
}

NSArray<__kindof APCHookProperty*>*
apc_property_getSuperPropertyList(APCHookProperty* p)
{
    NSEnumerator*    e
    = [[apc_runtime_propertyhook(p->_des_class, p->_hooked_name)
                          superhook] propertyEnumerator];
    NSMutableArray*  ret = [NSMutableArray array];
    APCHookProperty* item;

    while (nil != (item = e.nextObject)) {
        
        if(p.class == item.class){
            
            [ret addObject:p];
        }
    }
    
    return [ret copy];
}


#pragma mark - For instance - private
/** Instance : Property : Hook */
const static char _keyForAPCInstanceBoundMapper = '\0';
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
    
    if(NO == apc_class_conformsProxyClass(object_getClass(instance))){
        
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
    if(NO == apc_class_conformsProxyClass(object_getClass(instance))){
        
        return;
    }
    
    [apc_instance_propertyhook(instance, p->_hooked_name) unbindProperty:p];
}

NSArray<__kindof APCHookProperty*>* apc_instance_boundPropertyies(APCProxyInstance* instance, NSString* property)
{
    if(NO == apc_class_conformsProxyClass(object_getClass(instance))){
        
        return nil;
    }
    
    return [apc_instance_propertyhook(instance,property) boundProperties];
}

#pragma mark - Recursive(For instance) private
/**
 (weak)ThreadID : (weak)Instance : (strong)CMDs
 
 */
static NSMapTable* _apc_object_hookRecursiveMapper;
static NSMapTable* apc_object_hookRecursiveMapper()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _apc_object_hookRecursiveMapper = [NSMapTable weakToWeakObjectsMapTable];
    });
    return _apc_object_hookRecursiveMapper;
}

NS_INLINE NSMapTable* apc_object_hookRecursiveCurrentMapper()
{
    return [_apc_object_hookRecursiveMapper objectForKey:APCThreadID];
}

NS_INLINE NSMutableSet* apc_object_hookRecursiveCurrentLoops(id instance)
{
    return [apc_object_hookRecursiveCurrentMapper() objectForKey:instance];
}

#pragma mark - Recursive(For instance) export
BOOL apc_object_hookRecursive_testing(id instance, SEL _Nonnull _CMD)
{
    return
    
    [apc_object_hookRecursiveCurrentLoops(instance) containsObject:NSStringFromSelector(_CMD)];
}

void apc_object_hookRecursive_loop(id instance, SEL _Nonnull _CMD)
{
    NSMutableSet* loops;
    if(nil == (loops = apc_object_hookRecursiveCurrentLoops(instance))){
        
        @synchronized (instance) {
            
            if(nil == (loops = apc_object_hookRecursiveCurrentLoops(instance))){
                
                if(nil == apc_object_hookRecursiveCurrentMapper()){
                    
                    _apc_object_hookRecursiveMapper = [NSMapTable weakToStrongObjectsMapTable];
                    [_apc_object_hookRecursiveMapper setObject:instance forKey:APCThreadID];
                }
                loops = [NSMutableSet set];
                [loops addObject:NSStringFromSelector(_CMD)];
                [apc_object_hookRecursiveCurrentMapper() setObject:loops forKey:instance];
            }
        }
        return;
    }
    [loops addObject:NSStringFromSelector(_CMD)];
}

void apc_object_hookRecursive_break(id instance, SEL _Nonnull _CMD)
{
    [apc_object_hookRecursiveCurrentLoops(instance) removeObject:NSStringFromSelector(_CMD)];
}

#pragma mark - Proxy class - private
static const char* _apcProxyClassSuffix = "+APCProxyClass";
/** free! */
NS_INLINE char* apc_getProxyClassName(Class cls, id instance)
{
    char strhash[20] = {0};
    sprintf(strhash,"%lu",[instance hash]);
    
#error <#message#>
    
    const char* cname = class_getName(cls);
    char* buf = malloc(strlen(cname) + strlen(_apcProxyClassSuffix) + 1);
    buf[0] = '\0';
    strcat(buf, cname);
    strcat(buf, _apcProxyClassSuffix);
    
    
    
    return buf;
}

#pragma mark - Proxy class - export
APCProxyClass apc_class_registerProxyClass(Class cls,id instance)
{
    if(apc_class_conformsProxyClass(cls)){
        
        return cls;
    }
    char* name = apc_getProxyClassName(cls, instance);
    cls =  objc_allocateClassPair(cls, name, 0);
    if(cls != nil){
        
        objc_registerClassPair(cls);
    }else if (nil == (cls = objc_getClass(name))){
        
        fprintf(stderr, "APC: Can not register class '%s' at runtime.",name);
    }
    free(name);
    return cls;
}

BOOL apc_class_conformsProxyClass(Class cls)
{
    const char* cname = class_getName(cls);
    char* str = strstr(cname, _apcProxyClassSuffix);
    if(str != '\0' && (str + strlen(_apcProxyClassSuffix)) == '\0'){
        
        return YES;
    }
    return NO;
}

void apc_class_disposeProxyClass(APCProxyClass cls)
{
    objc_disposeClassPair(cls);
}

Class apc_class_unproxyClass(APCProxyClass cls)
{
    const char* cname = class_getName(cls);
    char* loc = strstr(cname, _apcProxyClassSuffix);
    
    if(loc != '\0' && (loc + strlen(_apcProxyClassSuffix)) == '\0'){
        
        char* name = malloc(1 + loc - cname);
        strncpy(name, cname, loc - cname);
        name[loc - cname] = '\0';
        free(name);
        return objc_getClass(name);
    }
    return (Class)0;
}


APCProxyClass apc_object_hookWithProxyClass(id _Nonnull instance)
{
    if(apc_object_isProxyInstance(instance)){
        
        return object_getClass(instance);
    }
    
    return apc_class_registerProxyClass(object_getClass(instance));
}

BOOL apc_object_isProxyInstance(id instance)
{
    return apc_class_conformsProxyClass([instance class]);
}

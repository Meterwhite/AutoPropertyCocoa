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


#pragma mark - For class

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


void apc_registerProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    NSMutableDictionary* dictionary = [apc_runtime_property_classmapper() objectForKey:p->_des_class];
    APCPropertyHook* hook;
    APCPropertyHook* item;
    
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
    
    
    APCMemoryBarrier;
    
    NSEnumerator* e = apc_runtime_property_classmapper().objectEnumerator;
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


#pragma mark - For instance
NSString *const  APCProxyClassSuffixForHookProperty = @"+APCProxyClass";
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


NSArray<__kindof APCHookProperty*>* apc_instanceBoundPropertyies(id instance, NSString* property)
{
    return nil;
}

APCHookProperty* apc_instanceProperty_getSuperProperty(APCHookProperty* _Nonnull p)
{
    return nil;
}

NSArray<__kindof APCHookProperty*>* apc_instanceProperty_getSuperPropertyList(APCHookProperty* p)
{
    return nil;
}

void apc_instanceSetAssociatedProperty(id instance, APCHookProperty* p)
{
    
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

void apc_instanceRemoveAssociatedProperty(id instance, APCHookProperty* p)
{
    [[apc_instanceBoundMapper(instance) objectForKey:p->_hooked_name] unbindProperty:p];
}

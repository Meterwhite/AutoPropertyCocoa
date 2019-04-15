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

#define APC_RUNTIME_LOCK \
\
dispatch_semaphore_wait(_apc_runtime_mapperlock, DISPATCH_TIME_FOREVER)

#define APC_RUNTIME_UNLOCK \
\
dispatch_semaphore_signal(_apc_runtime_mapperlock)

static dispatch_semaphore_t _apc_runtime_mapperlock;

///class : property : Hook : Properties
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


void apc_addProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    NSMutableDictionary* dictionary = [apc_runtime_property_classmapper() objectForKey:p->_des_class];
    
    APCPropertyHook* hook;
    
    if(dictionary == nil){
        
        dictionary = [NSMutableDictionary dictionary];
        [apc_runtime_property_classmapper() setObject:dictionary forKey:p->_des_class];
    }
    
    hook = dictionary[p->_des_getter_name];
    
    if(hook == nil){
        
        hook = [APCPropertyHook hookWithProperty:p];
        dictionary[p->_des_getter_name] = hook;
        
        APC_RUNTIME_UNLOCK;
        return;
    }
    
    [hook bindProperty:p];
    
    APC_RUNTIME_UNLOCK;
}

void apc_removeProperty(APCHookProperty* p)
{
    [apc_runtime_propertyhook( p->_des_class, p->_des_getter_name) unbindProperty:p];
}

NSArray* apc_classBoundProperties(Class cls, NSString* property)
{
    return [apc_runtime_propertyhook(cls , property) boundProperties];
}

APCHookProperty* apc_property_getSuperProperty(APCHookProperty* p)
{
    Class               clazz = p->_des_class;
    APCHookProperty*   item;
    NSEnumerator*       e;
    while (nil != (clazz = class_getSuperclass(clazz))) {
        
        if(nil != [apc_runtime_property_classmapper() objectForKey:clazz]){
            
            e = apc_runtime_propertyhook(clazz, p->_des_getter_name).propertyEnumerator;
            while (nil != (item = e.nextObject)) {
                
                if([[p class] isEqual: [item class]]){
                    
                    return p;
                }
            }
        }
    }
    
    return nil;
}

NSArray<__kindof APCHookProperty*>*
apc_property_getSuperPropertyList(APCHookProperty* p)
{
    NSMutableArray*     ret     =   [NSMutableArray array];
    Class               clazz   =   p->_des_class;
    APCHookProperty*   item;
    NSEnumerator*       e;
    while (nil != (clazz = class_getSuperclass(clazz))) {
        
        if(nil != [apc_runtime_property_classmapper() objectForKey:clazz]){
            
            e = apc_runtime_propertyhook(clazz, p->_des_getter_name).propertyEnumerator;
            while (nil != (item = e.nextObject)) {
                
                if([[p class] isEqual: [item class]]){
                    
                    [ret addObject:p];
                }
            }
        }
    }
    
    return [ret copy];
}

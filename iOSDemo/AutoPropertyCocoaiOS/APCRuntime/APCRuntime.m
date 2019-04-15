//
//  APCRuntime.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCRuntime.h"
///class : property : boundItems
static NSMapTable*  _apc_runtime_classmapper;
static dispatch_semaphore_t _apc_runtime_lock;

#define APC_RUNTIME_LOCK dispatch_semaphore_wait(_apc_runtime_lock, DISPATCH_TIME_FOREVER)
#define APC_RUNTIME_UNLOCK dispatch_semaphore_signal(_apc_runtime_lock)

static NSMapTable* apc_runtime_classmapper()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apc_runtime_classmapper = [NSMapTable strongToStrongObjectsMapTable];
        _apc_runtime_lock = dispatch_semaphore_create(1);
    });
    return _apc_runtime_classmapper;
}

NS_INLINE NSMutableArray* _Nonnull
apc_runtime_propertymapper(Class __unsafe_unretained _Nonnull clazz, NSString* _Nonnull property)
{
    
    NSMutableDictionary* dictionary = [apc_runtime_classmapper() objectForKey:clazz];
    
    NSMutableArray* items;
    
    if(dictionary == nil){
        
        dictionary = [NSMutableDictionary dictionary];
    }
    
    items = dictionary[property];
    
    if(items == nil){
        
        items = [NSMutableArray array];
        return (dictionary[property] = [NSMutableArray array]);
    }
    
    return dictionary[property];
}




void apc_addProperty(AutoPropertyInfo* p)
{
    APC_RUNTIME_LOCK;
    
    
    NSMutableArray* items = apc_runtime_propertymapper( p->_des_class, p->_des_method_name);
    NSUInteger idx = [items indexOfObject:p];
    if(idx != NSNotFound){
        
        [items removeObject:p];
    }
    [items addObject:p];
    
    APC_RUNTIME_UNLOCK;
}

void apc_removeProperty(AutoPropertyInfo* p)
{
    APC_RUNTIME_LOCK;
    
    NSMutableArray* items = apc_runtime_propertymapper( p->_des_class, p->_des_method_name);
    [items removeObject:p];
    
    APC_RUNTIME_UNLOCK;
}

NSArray* apc_classBoundProperties(Class cls, NSString* property)
{
    return apc_runtime_propertymapper(cls , property);
}

AutoPropertyInfo* apc_property_getSuperProperty(AutoPropertyInfo* p)
{
    Class clazz = p->_des_class;
    NSString* property = p->_des_method_name;
    
    [apc_runtime_classmapper() objectForKey:clazz];
}

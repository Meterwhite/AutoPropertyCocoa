//
//  APCInstancePropertyCacheManager.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCInstancePropertyCacheManager.h"
//#import <libkern/OSAtomic.h>
#import "AutoPropertyInfo.h"
#import <objc/NSObject.h>
#import <objc/runtime.h>
//#import <stdatomic.h>

#pragma mark - Define key
const static char _keyForAPCInstanceBoundCache = '\0';
static dispatch_semaphore_t semaphore;

#pragma mark - Instance cache
static NSMutableDictionary* _Nonnull apc_instanceBoundCache(id instance)
{
    
    NSMutableDictionary* cache;
    NSMapTable*          mapper;
    
    if(nil == (mapper = objc_getAssociatedObject(instance
                                                 , &_keyForAPCInstanceBoundCache))){
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if(nil == (mapper = objc_getAssociatedObject(instance
                                                     , &_keyForAPCInstanceBoundCache))){
            
            
            mapper = [NSMapTable strongToStrongObjectsMapTable];
            objc_setAssociatedObject(instance
                                     , &_keyForAPCInstanceBoundCache
                                     , mapper
                                     , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        
        dispatch_semaphore_signal(semaphore);
    }
    
    
    if(nil == (cache = [mapper objectForKey:[instance class]])){
        
        @synchronized (mapper) {
            
            if(nil == (cache = [mapper objectForKey:[instance class]])){
                
                [mapper setObject:(cache = [NSMutableDictionary dictionary]) forKey:[instance class]];
            }
        }
    }
    return cache;
}


@implementation APCInstancePropertyCacheManager

+ (id)allocWithZone:(struct _NSZone *)zone
{
    NSAssert(NO, @"Instantiation of APCInstancePropertyCacheManager is not allowed!");
    
    return nil;
}

+ (void)initialize
{
    semaphore = dispatch_semaphore_create(1);
}

+ (AutoPropertyInfo*)boundPropertyForInstance:(id)instance cmd:(NSString*)cmd
{
    NSMutableDictionary* map = apc_instanceBoundCache(instance);
    return [map objectForKey:cmd];
}

+ (NSArray<__kindof AutoPropertyInfo*>*)boundAllPropertiesForInstance:(id _Nonnull)instance
{
    return [apc_instanceBoundCache(instance) allValues];
}

+ (void)bindProperty:(AutoPropertyInfo*)property forInstance:(id)instance cmd:(NSString*)cmd
{
    NSMutableDictionary* map = apc_instanceBoundCache(instance);
    @synchronized (map) {
        
        [map setObject:property forKey:cmd];
    }
}

+ (void)boundPropertyRemoveForInstance:(id)instance cmd:(NSString*)cmd
{
    NSMutableDictionary* map = apc_instanceBoundCache(instance);
    @synchronized (map) {
        
        [map removeObjectForKey:cmd];
    }
}

+ (void)boundAllPropertiesRemoveForInstance:(id)instance
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    objc_setAssociatedObject(instance
                             , &_keyForAPCInstanceBoundCache
                             , nil
                             , OBJC_ASSOCIATION_RETAIN);
    
    dispatch_semaphore_signal(semaphore);
}

@end


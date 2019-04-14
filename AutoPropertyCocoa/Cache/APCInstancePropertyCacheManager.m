//
//  APCInstancePropertyCacheManager.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCInstancePropertyCacheManager.h"
#import "AutoPropertyInfo.h"
#import "APCScope.h"


const static char _keyForAPCInstanceBoundCache = '\0';

#pragma mark - Instance cache
static NSMutableDictionary* _Nonnull apc_instanceBoundCache(id instance)
{
    
    NSMutableDictionary* cache;
    NSMapTable*          mapper;
    
    if(nil == (mapper = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundCache))){
        
        @synchronized (instance) {
            
            if(nil == (mapper = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundCache))){
                
                mapper = [NSMapTable strongToStrongObjectsMapTable];
                objc_setAssociatedObject(instance
                                         , &_keyForAPCInstanceBoundCache
                                         , mapper
                                         , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
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

+ (AutoPropertyInfo*)boundPropertyFromInstance:(id)instance cmd:(NSString*)cmd
{
    NSMutableDictionary* map = apc_instanceBoundCache(instance);
    return [map objectForKey:cmd];
}

+ (NSArray<__kindof AutoPropertyInfo*>*)boundAllPropertiesForInstance:(id _Nonnull)instance
{
    return [apc_instanceBoundCache(instance) allValues];
}

+ (void)bindProperty:(AutoPropertyInfo*)property toInstance:(id)instance cmd:(NSString*)cmd
{
    NSMutableDictionary* map = apc_instanceBoundCache(instance);
    @synchronized (map) {
        
        [map setObject:property forKey:cmd];
    }
}

+ (void)boundPropertyRemoveFromInstance:(id)instance cmd:(NSString*)cmd
{
    NSMutableDictionary* map = apc_instanceBoundCache(instance);
    @synchronized (map) {
        
        [map removeObjectForKey:cmd];
    }
}

+ (void)boundAllPropertiesRemoveFromInstance:(id)instance
{
    objc_setAssociatedObject(instance
                             , &_keyForAPCInstanceBoundCache
                             , nil
                             , OBJC_ASSOCIATION_RETAIN);
}

+ (BOOL)boundContainsValidPropertyForInstance:(id _Nonnull)instance
{
    NSMutableDictionary* map = apc_instanceBoundCache(instance);
    
    NSEnumerator* em = map.objectEnumerator;
    
    AutoPropertyInfo* p;
    while (nil != (p = em.nextObject))
        if(p.enable == YES)
            return NO;
    
    
    return YES;
}

@end


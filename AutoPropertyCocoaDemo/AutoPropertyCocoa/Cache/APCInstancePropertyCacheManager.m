//
//  APCInstancePropertyCacheManager.m
//  AutoPropertyCocoaDemo
//
//  Created by NOVO on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCInstancePropertyCacheManager.h"
//#import <libkern/OSAtomic.h>
#import "AutoPropertyInfo.h"
#import <objc/runtime.h>
//#import <stdatomic.h>

@implementation APCInstancePropertyCacheManager
#pragma mark - Define key
const static char _keyForAPCLazyLoadInstanceBindedCache = '\0';
const static char _keyForAPCTriggerInstanceBindedCache = '\0';

#pragma mark - Instance cache
static NSMutableDictionary* _Nonnull apc_instanceBindedCache(id instance, uintptr_t k_ptr)
{
    NSMutableDictionary* map;

    if(nil != (map = objc_getAssociatedObject(instance, (void*)k_ptr))){
        
        return map;
    }

    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if(nil != (map = objc_getAssociatedObject(instance, (void*)k_ptr))){
        
        return map;
    }

    map = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(instance
                             , (void*)k_ptr
                             , map
                             , OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    dispatch_semaphore_signal(semaphore);

    return map;
}


static inline void apc_instanceBindAProperty(id instance, SEL _CMD,id propertyInfo, uintptr_t k_ptr)
{
    NSMutableDictionary* map = apc_instanceBindedCache(instance, k_ptr);
    @synchronized (map) {
        
        [map setObject:propertyInfo forKey:NSStringFromSelector(_CMD)];
    }
}


NS_INLINE AutoPropertyInfo* _Nullable apc_instanceGetBindedProperty(id instance, SEL _CMD,uintptr_t k_ptr)
{
    NSMutableDictionary* map = apc_instanceBindedCache(instance,k_ptr);
    return [map objectForKey:NSStringFromSelector(_CMD)];
}

NS_INLINE void apc_instanceRemoveAllBindedProperies(id instance, uintptr_t k_ptr)
{
    objc_setAssociatedObject(instance
                             , (void*)k_ptr
                             , nil
                             , OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Lazy load cache
+ (void)instanceBindedCache:(id)instance
{
    
}
@end

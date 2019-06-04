//
//  APCObjectLock.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/30.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#include "apc-objc-locker.h"
#include "APCObjectLock.h"
#include "APCScope.h"

@class APCRWLock;

#pragma mark - static var

static NSMapTable<id,NSLock*>*          _objlock_map;
static dispatch_semaphore_t             _objlock_maplock;

static NSMapTable<id,APCRWLock*>*       _rwlock_map;
static dispatch_semaphore_t             _rwlock_maplock;

static NSMapTable<id,NSRecursiveLock*>* _instancelock_map;
static dispatch_semaphore_t             _instancelock_maplock;


#pragma mark - read-writte lock
@interface APCRWLock : NSObject
{
@public
    
    pthread_rwlock_t lock;
}
@end

@implementation APCRWLock

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _rwlock_map
        =
        [NSMapTable mapTableWithKeyOptions:
         NSPointerFunctionsWeakMemory   |
         NSPointerFunctionsOpaquePersonality
                              valueOptions:
         NSPointerFunctionsStrongMemory |
         NSPointerFunctionsObjectPersonality];
        
        _objlock_map
        =
        [NSMapTable mapTableWithKeyOptions:
         NSPointerFunctionsWeakMemory   |
         NSPointerFunctionsOpaquePersonality
                              valueOptions:
         NSPointerFunctionsStrongMemory |
         NSPointerFunctionsObjectPersonality];
        
        _instancelock_map
        =
        [NSMapTable mapTableWithKeyOptions:
         NSPointerFunctionsWeakMemory   |
         NSPointerFunctionsOpaquePersonality
                              valueOptions:
         NSPointerFunctionsStrongMemory |
         NSPointerFunctionsObjectPersonality];
        
        _rwlock_maplock         =   APCSemaphoreLockInit;
        _objlock_maplock        =   APCSemaphoreLockInit;
        _instancelock_maplock   =   APCSemaphoreLockInit;
    });
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        const int err __attribute__((unused))
        =
        pthread_rwlock_init(&lock, 0);
        
        NSCAssert(err == 0, @"pthread_rwlock_init failed (%d)", err);
    }
    return self;
}
- (void)dealloc
{
    pthread_rwlock_destroy(&lock);
}
@end

#pragma mark - API

pthread_rwlock_t* apc_object_get_rwlock(id object)
{
    if(object == nil) return nil;
    
    APCRWLock* lock = [_rwlock_map objectForKey:object];
    if(lock == nil){
        
        APCSemaphoreLockLock(_rwlock_maplock);
        
        lock = [_rwlock_map objectForKey:object];
        
        if(lock == nil){
            
            [_rwlock_map setObject: (lock = [[APCRWLock alloc] init])
                            forKey:object];
        }
        APCSemaphoreUnlockLock(_rwlock_maplock);
    }
    
    return &(lock->lock);
}

void apc_object_rdlock(id object, void(NS_NOESCAPE^block)(void))
{
    if(object == nil || block == nil) return;
    apc_runtimelock_reader_t reading(*apc_object_get_rwlock(object));
    block();
}

void apc_object_wrlock(id object, void(NS_NOESCAPE^block)(void))
{
    if(object == nil || block == nil) return;
    apc_runtimelock_writer_t writing(*apc_object_get_rwlock(object));
    block();
}

NSLock* apc_object_get_lock(id object)
{
    if(object == nil) return nil;
    
    NSLock* lock = [_objlock_map objectForKey:object];
    if(lock == nil){
        
        APCSemaphoreLockLock(_objlock_maplock);
        
        lock = [_objlock_map objectForKey:object];
        if(lock == nil){
            
            [_objlock_map setObject:(lock = [[NSLock alloc] init])
                             forKey:object];
        }
        APCSemaphoreUnlockLock(_objlock_maplock);
    }
    return lock;
}

void apc_object_objlock(id object, void(NS_NOESCAPE^block)(void))
{
    NSLock* lock = apc_object_get_lock(object);
    if(lock != nil)
    {
        [lock lock];
        {
            block();
        }
        [lock unlock];
    }
}

NS_INLINE NSRecursiveLock* apc_object_get_safeinstance_lock(id object)
{
    if(object == nil) return nil;
    
    NSRecursiveLock* lock = [_instancelock_map objectForKey:object];
    if(lock == nil){
        
        APCSemaphoreLockLock(_instancelock_maplock);
        
        lock = [_instancelock_map objectForKey:object];
        if(lock == nil){
            
            [_instancelock_map setObject:(lock = [[NSRecursiveLock alloc] init])
                                  forKey:object];
        }
        APCSemaphoreUnlockLock(_instancelock_maplock);
    }
    return lock;
}

void apc_safe_instance(id object, void(NS_NOESCAPE^ block)(id object))
{
    NSRecursiveLock* lock = apc_object_get_safeinstance_lock(object);
    if(lock != nil)
    {
        [lock lock];
        {
            block(object);
        }
        [lock unlock];
    }
}

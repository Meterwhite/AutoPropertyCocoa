//
//  APCObjectLock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#include "APCObjectLock.h"
#include "apc-objc-os.h"
#include "APCScope.h"

@class APCObjLock;
@class APCRWLock;

#pragma mark - static var

static NSMapTable<id,APCObjLock*>*  _objlock_map;
static dispatch_semaphore_t         _objlock_maplock;
static NSMapTable<id,APCRWLock*>*   _rwlock_map;
static dispatch_semaphore_t         _rwlock_maplock;

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
        
        _rwlock_map     = [NSMapTable weakToStrongObjectsMapTable];
        _rwlock_maplock = APCSemaphoreLockInit;
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

@interface APCObjLock : NSObject
{
@public
    
    NSLock* lock;
}
@end
#pragma mark - object lock
@implementation APCObjLock

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _objlock_map        = [NSMapTable weakToStrongObjectsMapTable];
        _objlock_maplock    = APCSemaphoreLockInit;
    });
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        lock = [[NSLock alloc] init];
    }
    return self;
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
            
            [_rwlock_map setObject:[[APCRWLock alloc] init] forKey:object];
        }
        APCSemaphoreUnlockLock(_rwlock_maplock);
    }
    
    return &(lock->lock);
}

NSLock* apc_object_get_lock(id object)
{
    if(object == nil) return nil;
    
    APCObjLock* lock = [_objlock_map objectForKey:object];
    if(lock == nil){
        
        APCSemaphoreLockLock(_objlock_maplock);
        
        lock = [_objlock_map objectForKey:object];
        if(lock == nil){
            
            [_objlock_map setObject:[[APCObjLock alloc] init] forKey:object];
        }
        APCSemaphoreUnlockLock(_objlock_maplock);
    }
    
    return lock->lock;
}

void apc_object_rdlock(id object, void(NS_NOESCAPE^block)(void))
{
    if(object == nil || block == nil) return;
    apc_runtimelock_reader_t reading(*apc_object_get_rwlock(object));
    block();
}

void apc_object_wtlock(id object, void(NS_NOESCAPE^block)(void))
{
    if(object == nil || block == nil) return;
    apc_runtimelock_writer_t writing(*apc_object_get_rwlock(object));
    block();
}

void apc_safe_instance(id object, void(NS_NOESCAPE^ block)(id object))
{
    if(object == nil || block == nil) return;
    apc_runtimelock_writer_t writing(*apc_object_get_rwlock(object));
    block(object);
}

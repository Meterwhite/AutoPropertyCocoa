//
//  APCSwitchLock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/28.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCSwitchLock.h"
#import <pthread.h>
#import "APCScope.h"

static bool _apc_true   = true;
static bool _apc_false  = false;

@implementation APCSwitchLock
{
    APCSpinLock                 _mutex;
    dispatch_semaphore_t        _order;
    dispatch_semaphore_t        _task;
    bool                        _state;
    pthread_rwlock_t            _lock;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        _mutex  = APC_SPINLOCK_INIT;
        _order  = dispatch_semaphore_create(1);
        _task   = dispatch_semaphore_create(1);
        _state  = true;
        
        _lock   = PTHREAD_RWLOCK_INITIALIZER;
    }
    return self;
}

- (BOOL)visit
{
    apc_spinlock_lock(&_mutex);
    apc_spinlock_unlock(&_mutex);
    
    if(_state == true) {
        
        dispatch_semaphore_wait(_task, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(_task);
    }
    return true;
}

- (void)close
{
    apc_spinlock_lock(&_mutex);
    dispatch_semaphore_wait(_task, DISPATCH_TIME_FOREVER);
    _state = false;
    apc_spinlock_unlock(&_mutex);
}

- (void)open
{
    apc_spinlock_lock(&_mutex);
    dispatch_semaphore_signal(_task);
    _state = true;
    apc_spinlock_unlock(&_mutex);
}

- (void)closing
{
    dispatch_semaphore_wait(_order, DISPATCH_TIME_FOREVER);
    
    apc_spinlock_lock(&_mutex);
    {
        dispatch_semaphore_wait(_task, DISPATCH_TIME_FOREVER);
        _state = false;
    }
    apc_spinlock_unlock(&_mutex);
}

- (void)opening
{
    apc_spinlock_lock(&_mutex);
    {
        
        dispatch_semaphore_signal(_task);
        _state = true;
    }
    apc_spinlock_unlock(&_mutex);
    
    dispatch_semaphore_wait(_order, DISPATCH_TIME_FOREVER);
}

@end

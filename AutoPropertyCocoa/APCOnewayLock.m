//
//  APCOnewayLock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/28.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCOnewayLock.h"
#import "APCScope.h"
#import <pthread.h>

static bool _apc_true   = true;
static bool _apc_false  = false;

@implementation APCOnewayLock
{
    pthread_mutex_t         _lock;
    atomic_bool             _state;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        const int result __attribute__((unused)) = pthread_mutex_init(&_lock, NULL);
        NSAssert(0 == result, @"APC: Failed to initialize mutex with error %d.", result);
    }
    return self;
}

- (BOOL)visit
{
    if(_state == true) {
        
        pthread_mutex_lock(&_lock);
        pthread_mutex_unlock(&_lock);
    }
    return true;
}

- (void)close
{
    if(atomic_compare_exchange_strong(&_state, &_apc_true, _apc_false)){
        
        pthread_mutex_lock(&_lock);
    }
}

- (void)open
{
    if(atomic_compare_exchange_strong(&_state, &_apc_false, _apc_true)){
        
        pthread_mutex_unlock(&_lock);
    }
}

@end

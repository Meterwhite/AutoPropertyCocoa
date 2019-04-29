//
//  APCSwitchLock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/28.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCSwitchLock.h"
#import "APCScope.h"

static bool _apc_true   = true;
static bool _apc_false  = false;

@implementation APCSwitchLock
{
    APCSpinLock         _self_lock;
    APCSpinLock         _lock;
    atomic_bool         _state;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        _self_lock  = APC_SPINLOCK_INIT;
        _lock       = APC_SPINLOCK_INIT;
        _state      = false;
    }
    return self;
}

- (BOOL)visit
{
    if(_state == true) {
        
        apc_spinlock_lock(&_lock);
        apc_spinlock_unlock(&_lock);
    }
    return true;
}

- (void)off
{
    if(atomic_compare_exchange_strong(&_state, &_apc_true, _apc_false)){
        
        apc_spinlock_lock(&_lock);
    }
}

- (void)on
{
    if(atomic_compare_exchange_strong(&_state, &_apc_false, _apc_true)){
        
        apc_spinlock_unlock(&_lock);
    }
}

- (void)waitingOff
{
    apc_spinlock_lock(&_self_lock);
    
    if(atomic_compare_exchange_strong(&_state, &_apc_true, _apc_false)){
        
        apc_spinlock_lock(&_lock);
        return;
    }
    
}

- (void)waitingOn
{
    if(atomic_compare_exchange_strong(&_state, &_apc_false, _apc_true)){
        
        apc_spinlock_unlock(&_lock);
    }
    apc_spinlock_unlock(&_self_lock);
}

@end

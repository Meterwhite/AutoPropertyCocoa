//
//  APCOBJC2Runtimelock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/9.
//  Copyright © 2019 Novo. All rights reserved.
//

#include "apc-objc-runtimelock.h"
#include "apc-fishhook.h"
#include "apc-objc-os.h"
#include <pthread.h>


class APCOBJCRuntimelocker;

/** Initialize in apc_in_main() */
static pthread_mutex_t apc_objcruntimelock = {0};

_Bool apc_contains_objcruntimelock(void)
{
    unsigned int i = sizeof(pthread_mutex_t);
    while (i -= sizeof(long)) {
        
        if(*((long*)((UInt8*)&apc_objcruntimelock + i)) != (long)0){
            
            return true;
        }
    }
    return false;
}

static APCOBJCRuntimelocker*        apc_objcruntimelocker;


class APCOBJCRuntimelocker : apc_nocopy_t{
    
protected:
    
    pthread_mutex_t*        lock;
public:
    
    dispatch_semaphore_t    runtime_locked_success;
    dispatch_semaphore_t    need_unlock_runtime;
    pthread_t               thread_id;
    APCOBJCRuntimelocker(pthread_mutex_t* newlock) : lock(newlock)
    {
        pthread_mutex_lock(lock);
        runtime_locked_success  = dispatch_semaphore_create(0);
        need_unlock_runtime     = dispatch_semaphore_create(0);
        
        APCMemoryBarrier;
        
        apc_objcruntimelocker   = this;
        triggerObjcRuntimelockAsync();
        wait_runtimeLockedSuccess();
    }
    
    
    ~APCOBJCRuntimelocker()
    {
        signal_unlockRuntime();
        apc_objcruntimelocker = nil;
        pthread_mutex_unlock(lock);
    }
    
    _Bool testingThreadID()
    {
        return pthread_equal(thread_id, pthread_self());
    }
    
    void wait_runtimeLockedSuccess()
    {
        dispatch_semaphore_wait(runtime_locked_success, DISPATCH_TIME_FOREVER);
    }
    
    void signal_runtimeLockedSuccess()
    {
        dispatch_semaphore_signal(runtime_locked_success);
    }
    
    void wait_unlockRuntime()
    {
        dispatch_semaphore_wait(need_unlock_runtime, DISPATCH_TIME_FOREVER);
    }
    
    void signal_unlockRuntime()
    {
        dispatch_semaphore_signal(need_unlock_runtime);
    }
    
    void triggerObjcRuntimelockAsync()
    {
        dispatch_queue_t q
        =
        dispatch_queue_create("APCOBJCRuntimelocker::triggerObjcRuntimelockAsync", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(q, ^{
            
            /**
             The runtimelock will be locked in the function objc_allocateProtocol() and then 'calloc' will be called.
             Use fishhook to hook the 'calloc' function, then block 'calloc' to know that we can unlock the thread after completing our work.
             */
            thread_id = pthread_self();
            objc_allocateProtocol("CN198964");
        });
    }
};

void apc_objcruntimelock_lock(void(NS_NOESCAPE^userblock)(void))
{
    APCOBJCRuntimelocker locker(&apc_objcruntimelock);
    userblock();
}

#pragma mark - hook calloc
static void*(*apc_calloc_ptr)(size_t __count, size_t __size);

void* apc_calloc(size_t __count, size_t __size)
{
    
    if(apc_objcruntimelocker != NULL){
        
        if(apc_objcruntimelocker->testingThreadID()){
            
            /**
             objc_allocateProtocol(...) ---> [here] ---> calloc(...) ---> userblock(...)
             */
            apc_objcruntimelocker->signal_runtimeLockedSuccess();
            
            /**
             userblock(...) ---> [here] ---> No longer blocking the thread.
             */
            apc_objcruntimelocker->wait_unlockRuntime();
        }
    }
    
    return apc_calloc_ptr(__count, __size);
}

void apc_in_main(void)
{
    struct apc_rebinding
    rebindInfo
    =
    {
        .name           =   "calloc",
        .replacement    =   (void*)apc_calloc,
        .replaced       =   (void**)(&apc_calloc_ptr)
    };
    
    apc_rebind_symbols((struct apc_rebinding[1]){rebindInfo} , 1);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        const int result __attribute__((unused))
        =
        pthread_mutex_init(&apc_objcruntimelock, NULL);
        NSCAssert(0 == result, @"Failed to initialize mutex with error %d.", result);
    });
}

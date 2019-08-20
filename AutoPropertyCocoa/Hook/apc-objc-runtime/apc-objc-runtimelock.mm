//
//  APCOBJC2Runtimelock.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/9.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#include "apc-objc-runtimelock.h"
#include "apc-objc-extension.h"
#include "apc-objc-locker.h"
#include "apc-fishhook.h"
#include "APCExtScope.h"
#include "APCScope.h"
#include <pthread.h>


class APCOBJCRuntimelocker;

/** Initialize in apc_main_classHookFullSupport() */
static pthread_mutex_t apc_objcruntimelock = {0};

static APCSpinLock apc_lockerlock = apc_spinlock_init;

_Bool apc_contains_objcruntimelock(void)
{
#if APCDebugSchemeDiagnosticsGuardMalloc
    
    return true;
#else
    unsigned int i = sizeof(pthread_mutex_t);
    while (i -= sizeof(long)) {
        
        if(*((long*)((UInt8*)&apc_objcruntimelock + i)) != (long)0){
            
            return true;
        }
    }
    return false;
#endif
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
        
        apc_spinlock_lock(&apc_lockerlock);
        apc_spinlock_unlock(&apc_lockerlock);
        
        pthread_mutex_unlock(lock);
    }
    
    OS_ALWAYS_INLINE _Bool testingThreadID()
    {
        return pthread_equal(thread_id, APCThreadID);
    }
    
    OS_ALWAYS_INLINE void wait_runtimeLockedSuccess()
    {
        dispatch_semaphore_wait(runtime_locked_success, DISPATCH_TIME_FOREVER);
    }
    
    OS_ALWAYS_INLINE void signal_runtimeLockedSuccess()
    {
        dispatch_semaphore_signal(runtime_locked_success);
    }
    
    OS_ALWAYS_INLINE void wait_unlockRuntime()
    {
        dispatch_semaphore_wait(need_unlock_runtime, DISPATCH_TIME_FOREVER);
    }
    
    OS_ALWAYS_INLINE void signal_unlockRuntime()
    {
        dispatch_semaphore_signal(need_unlock_runtime);
    }
    
    void triggerObjcRuntimelockAsync()
    {
        dispatch_queue_t q
        =
        dispatch_queue_create("APCOBJCRuntimelocker::triggerObjcRuntimelockAsync", DISPATCH_QUEUE_SERIAL);
        
        dispatch_async(q, ^{
            
            this->thread_id = pthread_self();
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

void apc_objcruntimelocker_trylock(void)
{
    if(apc_objcruntimelocker &&
       apc_objcruntimelocker->testingThreadID()){
        
        apc_spinlock_lock(&apc_lockerlock);
        
        apc_objcruntimelocker->signal_runtimeLockedSuccess();
        
        apc_objcruntimelocker->wait_unlockRuntime();
        
        apc_objcruntimelocker = nil;
        apc_spinlock_unlock(&apc_lockerlock);
    }
}

/**
 This should compress the function call stack to a minimum.
 */
void* apc_calloc(size_t __count, size_t __size)
{
    
    if(apc_objcruntimelocker != NULL){
        
        apc_objcruntimelocker_trylock();
    }
    
    return apc_calloc_ptr(__count, __size);
}

void apc_main_classHookFullSupport(void)
{
#if !APCDebugSchemeDiagnosticsGuardMalloc
    struct apc_rebinding
    rb_calloc
    =
    {
        .name           =   "calloc",
        .replacement    =   (void*)apc_calloc,
        .replaced       =   (void**)(&apc_calloc_ptr)
    };
    
    apc_rebind_symbols((struct apc_rebinding[1]){rb_calloc} , 1);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        const int result __attribute__((unused))
        =
        pthread_mutex_init(&apc_objcruntimelock, NULL);
        NSCAssert(0 == result, @"Failed to initialize mutex with error %d.", result);
    });
#endif
}


#if DEBUG
void apc_debug_objcruntimelock_delete(void)
{
    pthread_mutex_destroy(&apc_objcruntimelock);
    apc_objcruntimelock = {0};
}

void apc_debug_objcruntimelock_create(void)
{
    const int result __attribute__((unused))
    =
    pthread_mutex_init(&apc_objcruntimelock, NULL);
    NSCAssert(0 == result, @"Failed to initialize mutex with error %d.", result);
}

pthread_rwlock_t apc_test_runtimelock = PTHREAD_RWLOCK_INITIALIZER;
void apc_debug_test_objcruntimelock(void)
{
    {
        int count = 50000;
        while (count--) {

            apc_runtimelock_writer_t writting(apc_test_runtimelock);
            printf("%u\n",count);
        }
    }
    
    {
        __block int count = 50000;
        dispatch_queue_t queue
        =
        dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_apply(count, queue, ^(size_t) {
            
            apc_runtimelock_writer_t writting(apc_test_runtimelock);
            printf("%u\n" ,--count);
        });
    }
}

#endif

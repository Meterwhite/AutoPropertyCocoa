//
//  APCOBJC2Runtimelock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/9.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "apc-objc-runtimelock.h"
#import "APCScope.h"
#import "fishhook.h"
#import <pthread.h>


class APCOBJCRuntimelocker;

static APCOBJCRuntimelocker*    apc_runtime_locker;

_Bool apc_contains_runtimelock(void)
{
    return (_Bool)apc_runtime_locker;
}

static pthread_mutex_t*         apc_objc_runtimelock;


class apc_nocopy_t {
private:
    apc_nocopy_t(const apc_nocopy_t&) = delete;
    const apc_nocopy_t& operator=(const apc_nocopy_t&) = delete;
protected:
    apc_nocopy_t() { }
    ~apc_nocopy_t() { }
};


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
        thread_id               = pthread_self();
        runtime_locked_success  = dispatch_semaphore_create(0);
        need_unlock_runtime     = dispatch_semaphore_create(0);
        
        APCMemoryBarrier;
        
        apc_runtime_locker      = this;
        triggerObjcRuntimelockAsync();
        wait_runtimeLockedSuccess();
    }
    
    ~APCOBJCRuntimelocker()
    {
        signal_unlockRuntime();
        apc_runtime_locker = nil;
        pthread_mutex_unlock(lock);
    }
    
    _Bool equalToCurrentThreadID()
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
        dispatch_semaphore_wait(apc_runtime_locker->need_unlock_runtime, DISPATCH_TIME_FOREVER);
    }
    
    void signal_unlockRuntime()
    {
        dispatch_semaphore_signal(need_unlock_runtime);
    }
    
    void triggerObjcRuntimelockAsync()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            /**
             The runtimelock will be locked in the function objc_allocateProtocol() and then 'calloc' will be called.
             Use fishhook to hook the 'calloc' function, then block 'calloc' to know that we can unlock the thread after completing our work.
             */
            objc_allocateProtocol("CN198964");
        });
    }
};

void apc_runtimelock_lock(void(^userblock)(void))
{
    APCOBJCRuntimelocker locker(apc_objc_runtimelock);
    userblock();
}

#pragma mark - hook calloc
static void*(*apc_calloc_ptr)(size_t __count, size_t __size);

void* apc_calloc(size_t __count, size_t __size)
{
    
    if(apc_runtime_locker != NULL){
        
        if(apc_runtime_locker->equalToCurrentThreadID()){
            
            /**
             objc_allocateProtocol(...) ---> [here] ---> calloc(...) ---> userblock(...)
             */
            apc_runtime_locker->signal_runtimeLockedSuccess();
            
            /**
             userblock(...) ---> [here] ---> No longer blocking the thread.
             */
            apc_runtime_locker->wait_unlockRuntime();
        }
    }
    
    return apc_calloc_ptr(__count, __size);
}

void apc_main_hook(void)
{
    struct rebinding
    rebindInfo
    =
    {
        .name           =   "calloc",
        .replacement    =   (void*)apc_calloc,
        .replaced       =   (void**)(&apc_calloc_ptr)
    };
    
    rebind_symbols((struct rebinding[1]){rebindInfo} , 1);
    
    const int result __attribute__((unused)) = pthread_mutex_init(apc_objc_runtimelock, NULL);
    NSCAssert(0 == result, @"Failed to initialize mutex with error %d.", result);
}

//
//  APCOBJC2Runtimelock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/9.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "apc-objc-runtimelock.h"
#import "fishhook.h"
#import <pthread.h>


class APCOBJCRuntimelocker;

static APCOBJCRuntimelocker*    apc_runtime_locker;

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
        
        dispatch_queue_global_t gqueue
        =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        APCMemoryBarrier;
        apc_runtime_locker      = this;
        dispatch_async(gqueue, ^{
            
            /**
             The runtimelock will be locked in the function objc_allocateProtocol() and then 'calloc' will be called.
             Use fishhook to hook the 'calloc' function, then block 'calloc' to know that we can unlock the thread after completing our work.
             */
            objc_allocateProtocol("CN198964");
        });
        
        dispatch_semaphore_wait(runtime_locked_success, DISPATCH_TIME_FOREVER);
    }
    
    ~APCOBJCRuntimelocker()
    {
        dispatch_semaphore_signal(need_unlock_runtime);
        pthread_mutex_unlock(lock);
        apc_runtime_locker = nil;
    }
};

void apc_runtimelock_lock(void(^block)(void))
{
    APCOBJCRuntimelocker locker(apc_objc_runtimelock);
    block();
}

#pragma mark - hook calloc
static void*(*apc_calloc_ptr)(size_t __count, size_t __size);

void* apc_calloc(size_t __count, size_t __size)
{
    
    if(apc_runtime_locker != NULL){
        
        if(apc_runtime_locker->thread_id == pthread_self()){
            
            /**
             objc_allocateProtocol(...) ---> [here] ---> calloc(...) ---> userfunc(...)
             */
            dispatch_semaphore_signal(apc_runtime_locker->runtime_locked_success);
            
            /**
             userfunc(...) ---> [here] ---> No longer blocking the thread.
             */
            dispatch_semaphore_wait(apc_runtime_locker->need_unlock_runtime, DISPATCH_TIME_FOREVER);
        }
    }
    
    return apc_calloc_ptr(__count, __size);
}

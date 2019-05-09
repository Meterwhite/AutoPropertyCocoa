//
//  APCOBJC2Runtimelock.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/9.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "apc-objc-runtimelock.h"
#import "APCScope.h"
#import <pthread.h>


//@implementation APCOBJC2Runtimelock
//
//@end


class APCXXXLock{
    
    pthread_t   tid;
    APCSpinLock _lockA;
    APCSpinLock _lockB;
    
public:
    APCXXXLock()
    {
        
    }
    ~APCXXXLock()
    {
        
    }
};


void acp_runtimelock_lock(void(^block)(void))
{
    APCXXXLock lock;
    
    dispatch_queue_global_t queue
    =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^{
        
        
    });
    
}

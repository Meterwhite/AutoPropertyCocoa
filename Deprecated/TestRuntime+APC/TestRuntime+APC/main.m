//
//  main.m
//  TestRuntime+APC
//
//  Created by NOVO on 2019/5/5.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "apc-objc-runtimelock.h"
#import <objc/runtime.h>
#import "fishhook.h"
#import "pthread.h"
#import "Person.h"
#import "Man.h"

int main(int argc, const char * argv[]) {
    
    apc_in_main();
    
    
    dispatch_queue_t q
    =
    dispatch_queue_create("APC_Other_Thread", DISPATCH_QUEUE_CONCURRENT);
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), q, ^{
//
//        objc_allocateProtocol("15620540095");
//        printf("End\n");
//    });
    
    
    @Runtimelock({

        printf("<>_<>:locking...\n");
    });
    
    
    
    printf("----------");
    for (int i = 0; i<50000; i++) {
        
        dispatch_async(q, ^{
            
            objc_allocateProtocol("15620540095");
            printf("<>_<>:Thread i = %u\n",i);
        });
    }
    
    
    while (1) ;
    return 0;
}


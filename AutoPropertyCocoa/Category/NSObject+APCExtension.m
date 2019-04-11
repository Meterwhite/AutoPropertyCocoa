//
//  NSObject+APCExtension.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/11.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+APCExtension.h"
#import <objc/runtime.h>

//const static char _keyForAPCLazyLoadBreakPointClass = '\0';

const static char _keyForAPCLazyLoadPerformOldLoopLenth = '\0';
const static char _keyForAPCLazyLoadPerformOldLoopLock = '\0';

@implementation NSObject (APCExtension)

- (NSLock*)apc_lazyload_performOldLoop_lock
{
    static dispatch_semaphore_t semephore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        semephore = dispatch_semaphore_create(1);
    });
    
    NSLock* lock = objc_getAssociatedObject(self, &_keyForAPCLazyLoadPerformOldLoopLock);
    if(lock == nil){
        
        dispatch_semaphore_wait(semephore, DISPATCH_TIME_FOREVER);
        
        lock = objc_getAssociatedObject(self, &_keyForAPCLazyLoadPerformOldLoopLock);
        if(lock == nil){
            
            lock = [[NSLock alloc] init];
            objc_setAssociatedObject(self
                                     , &_keyForAPCLazyLoadPerformOldLoopLock
                                     , lock
                                     , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        dispatch_semaphore_signal(semephore);
    }
    return lock;
}

- (BOOL)apc_lazyload_performOldLoop_testing
{
    return
    
    objc_getAssociatedObject(self, &_keyForAPCLazyLoadPerformOldLoopLenth)
    ? YES
    : NO;
}

- (void)apc_lazyload_performOldLoop
{
    [[self apc_lazyload_performOldLoop_lock] lock];
    
    NSNumber* lenth = objc_getAssociatedObject(self, &_keyForAPCLazyLoadPerformOldLoopLenth);
    
    lenth = [NSNumber numberWithUnsignedInteger:(lenth
                                                 ? lenth.unsignedIntegerValue + 1
                                                 : 1)];
    
    objc_setAssociatedObject(self
                             , &_keyForAPCLazyLoadPerformOldLoopLenth
                             , lenth
                             , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[self apc_lazyload_performOldLoop_lock] unlock];
}
- (NSUInteger)apc_lazyload_performOldLoop_lenth
{
    return
    
    [objc_getAssociatedObject(self, &_keyForAPCLazyLoadPerformOldLoopLenth)
     
     unsignedIntegerValue];
}

- (void)apc_lazyload_performOldLoop_break
{
    [[self apc_lazyload_performOldLoop_lock] lock];
    
    objc_setAssociatedObject(self
                             , &_keyForAPCLazyLoadPerformOldLoopLenth
                             , nil
                             , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[self apc_lazyload_performOldLoop_lock] unlock];
}

@end

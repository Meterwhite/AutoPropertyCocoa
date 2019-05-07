//
//  ViewController.m
//  TestRuntime+APC+iOS
//
//  Created by MDLK on 2019/5/6.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


static NSLock* _lock;
static bool _flag;

void objc_containsLock()
{
    [_lock lock];
    
    uint32_t idx = arc4random();
    NSLog(@"objc_containsLock! -> %u",idx);
    
    [_lock unlock];
}

void fakeLock()
{
    dispatch_queue_t queue_concurrent
    =
    dispatch_queue_create("fakeLock", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_global_t queue_global
    =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    
    dispatch_async(queue_concurrent, ^{
        
        while (_flag) {
            
            objc_containsLock();
        }
    });
}


void doSomething()
{
    uint32_t idx = arc4random();
    NSLog(@"Finished work! -> %u",idx);
}



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Hello, World!");
    
    _flag = 1;
    _lock = [[NSLock alloc] init];
    
    fakeLock();
    
    dispatch_queue_main_t queue = dispatch_get_main_queue();
    
    dispatch_queue_global_t queue_global
    =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        
        
        while (1) {
            
            [_lock lock];
            NSCAssert(0, @"Bad");
            [_lock unlock];
        }
    });
}


@end

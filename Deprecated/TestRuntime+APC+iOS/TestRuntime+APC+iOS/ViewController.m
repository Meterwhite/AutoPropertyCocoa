//
//  ViewController.m
//  TestRuntime+APC+iOS
//
//  Created by MDLK on 2019/5/6.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "ViewController.h"
#import "pthread.h"

@interface ViewController ()

@end

static pthread_t _thread_0;
static pthread_t _thread_1;
static pthread_t _thread_2;
static pthread_t _thread_3;
static pthread_t _thread_4;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _thread_0 = pthread_self();
    
    dispatch_queue_t q2 = dispatch_get_global_queue(0, 0);
    dispatch_async(q2, ^{
        
        if((_thread_2 = pthread_self())==_thread_0){
            
            printf("2\n");
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if((_thread_1 = pthread_self())==_thread_0){
            
            printf("1\n");
        }
    });
    
    
    
}


@end

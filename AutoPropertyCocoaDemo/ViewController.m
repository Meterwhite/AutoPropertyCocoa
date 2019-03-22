//
//  ViewController.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+APCLazyLoad.h"
#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "APCScope.h"
#import "Person.h"
#import "Man.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    APCPropertysArray(self, view, superclass, nextResponder);
    
//    [Person apc_lazyLoadForProperty:@"name" aSelector:@selector(new)];
    
    [Person apc_lazyLoadForProperty:@"frame" usingBlock:^id _Nullable(id  _Nonnull _self) {

        return [NSValue valueWithCGRect:CGRectMake(50, 60, 70, 80)];
    }];
//    [Person apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
//
//        return @(1024);
//    }];
    
    
    Person* p = [Person new];
    
    [p apc_lazyLoadForProperty:@"name" usingBlock:^id _Nullable(id  _Nonnull _self) {
        
        return @"FaFaFaFa...";
    }];
    
//    [p apc_unbindLazyLoadForProperty:@"name"];
    
//    id name = p.name;
    
//    id name3 = p.name;
    
    CGRect r = p.frame;
    
    CGRect r2 = p.frame;
    
    id name3 = p.name;
    
    Person* p2 = [Person new];
    
//    [p2 apc_lazyLoadForProperty:@"name" usingBlock:^id _Nullable(id  _Nonnull _self) {
//
//        return @"HuanHuanHuanHuan...";
//    }];
    
    
    id name2 = p2.name;
    
//    NSUInteger age = p.age;
    
    
    
    NSLog(@"beak");
}


@end

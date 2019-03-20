//
//  ViewController.m
//  AutoPropertyCocoaDemo
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+AutoPropertyCocoa.h"
#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Person.h"
#import "Man.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [Person apc_lazyPropertyForKey:@"name" aSelector:@selector(new)];
    
//    [Person apc_lazyPropertyForKey:@"frame" usingBlock:^id _Nullable(id  _Nonnull _self) {
//
//        return [NSValue valueWithCGRect:CGRectMake(50, 60, 70, 80)];
//    }];
//    [Person apc_lazyPropertyForKey:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
//
//        return @(1024);
//    }];
    
    
    Person* p = [Person new];
    
    [p apc_autoClassProperty:@"name" hookWithBlock:nil hookWithSEL:nil];
    id name = p.name;
    
    Person* p2 = [Person new];
    id name2 = p2.name;
    
//    NSUInteger age = p.age;
    
    NSLog(@"beak");
}


@end

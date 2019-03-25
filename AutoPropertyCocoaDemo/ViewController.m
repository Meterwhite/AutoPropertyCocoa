//
//  ViewController.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyCocoa/Property/AutoLazyPropertyInfo.h"
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
    
    
    [self testBaseSubClass];
}


- (void)testBaseSubClass
{
//    [Person apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
//
//        return @(999);
//    }];
    
    [Man apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {

        return @(111);
    }];
    
    Person* p = [Person new];
    NSUInteger age0 = p.age;
    Man* m = [Man new];
    NSUInteger age1 = m.age;
}

@end

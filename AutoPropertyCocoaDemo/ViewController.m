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
    [Person apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
        
        return @(999);
    }];
    
    [Man apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {

        return @(111);
    }];
    
    NSUInteger age0 = [Person new].age;
    
    NSUInteger age1 = [Man new].age;
    
}

@end

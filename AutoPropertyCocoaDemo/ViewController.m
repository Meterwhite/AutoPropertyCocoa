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
#import "APCHash.h"
#import "Person.h"
#import "Man.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [self testClassSuperclassSubclass];
    [self testHash];
}


- (void)testClassSuperclassSubclass
{
    [Person apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {

        return @(999);
    }];
    
    [Man apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
        
        return @(111);
    }];
    
    [Person apc_unbindLazyLoadForProperty:@"age"];
    
//    [Man apc_unbindLazyLoadForProperty:@"age"];
    
    Person* p = [Person new];
    NSUInteger age0 = p.age;
    Man* m = [Man new];
    NSUInteger age1 = m.age;
}

- (void)testHash
{
    Class p = [Person class];
    Class m = [Man class];
    NSString* propertyName = @"age";
    
    
    NSUInteger hashP = [p hash];
    NSUInteger hashM = [m hash];
    NSUInteger hashN = [propertyName hash];
    
    NSUInteger t0 = apc_hash_pairing(hashM, hashN);
    
    unsigned long long d0;
    unsigned long long d1;
    apc_hash_depairing(t0, &d0, &d1);
    
    
}

@end

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
    
//    size_t s0 = sizeof(NSUInteger);//64
//    size_t s1 = sizeof(unsigned long long);//64
//    size_t s2 = sizeof(double);//64
//    size_t s3 = sizeof(long double);//128
    
    NSUInteger hashP = [p hash];
    NSUInteger hashM = [m hash];
    NSUInteger hashN = [propertyName hash];
    
    NSUInteger t0 = apc_hash_cantorpairing(1111, 9999);
    
    NSUInteger d0;
    NSUInteger d1;
    apc_hash_decantorpairing(t0, &d0, &d1);
    
}

@end

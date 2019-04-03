//
//  ViewController.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyInfo.h"
#import "APCClassPropertyMapperCache.h"
#import "AutoLazyPropertyInfo.h"
#import "NSObject+APCLazyLoad.h"
#import "APCPropertyMapperkey.h"
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
    
    [self testNormalInstance];
//    [self testClassSuperclassSubclass];
//    [self testHash];
//    [self testMapperCache];
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
    
    [Man    apc_unbindLazyLoadForProperty:@"age"];
    
    Person* p = [Person new];
    NSUInteger age0 = p.age;
    Man* m = [Man new];
    NSUInteger age1 = m.age;
}

- (void)testNormalInstance
{
    Person* p = [Person new];
    Man* m = [Man new];
    
    [Man apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
        
        return @(999);
    }];
    
    [m apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
        
        return @(111);
    }];
    
    [m apc_unbindLazyLoadForProperty:@"age"];
    
//    NSUInteger age0 = p.age;
    NSUInteger age1 = m.age;
}

- (void)testHash
{
    Class p = [Person class];
    Class m = [Man class];
    NSString* propertyName = @"age";
    
    
    NSUInteger hashP = [p hash];
    NSUInteger hashM = [m hash];
    NSUInteger hashN = [propertyName hash];//21042608 516213936
    
    AutoLazyPropertyInfo* p0 = [AutoLazyPropertyInfo infoWithPropertyName:@"age" aClass:p];
    AutoLazyPropertyInfo* p1 = [AutoLazyPropertyInfo infoWithPropertyName:@"age" aClass:p];
    [p0 invalid];
    NSMutableSet* set = [NSMutableSet setWithObjects:p0, p1, nil];
    
    [p1 invalid];
    
    AutoLazyPropertyInfo* p2 = [AutoLazyPropertyInfo infoWithPropertyName:@"age" aClass:p];
    [p2 invalid];
    
    [set addObject:p2];
    
    NSLog(@"%@",set);
}


- (void)testMapperCache
{
    
    
//    APCClassPropertyMapperCache* cache = [APCClassPropertyMapperCache cache];
//
//    cache addProperty:<#(AutoPropertyInfo *)#>
    
    id k0 = [APCPropertyMapperkey keyWithClass:self.class];
    id k1 = [APCPropertyMapperkey keyWithClass:self.class];
    
    NSMutableDictionary* mdic = NSMutableDictionary.dictionary;
    
    mdic[k0] = @"A";
    mdic[k1] = @"B";
    
    id xx = mdic[NSStringFromClass(self.class)];
    NSLog(@"%@",mdic);
}
@end

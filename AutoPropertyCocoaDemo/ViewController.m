//
//  ViewController.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassPropertyMapperCache.h"
#import "NSObject+APCTriggerProperty.h"
#import "AutoLazyPropertyInfo.h"
#import "NSObject+APCLazyLoad.h"
#import "APCPropertyMapperkey.h"
#import "AutoPropertyInfo.h"
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
    
    [self testTriggerFrontNormalInstance];
//    [self testTriggerFrontNormalClass];
//    [self testNormalInstance];
//    [self testClassSuperclassSubclass];
//    [self testHash];
//    [self testMapperCache];
}


- (void)testTriggerFrontNormalInstance
{
    Person* p = Person.new;
    Person* p1 = Person.new;
    [p apc_frontOfPropertyGetter:@"age" bindWithBlock:^(id  _Nonnull instance) {
        
        NSLog(@"Afront of age!");
    }];
    
    [p apc_backOfPropertyGetter:@"age" bindWithBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"Abakc of age!");
    }];
    
    [p apc_propertyGetter:@"age" bindUserCondition:^BOOL(id  _Nonnull instance, id  _Nullable value) {
        
        if([value unsignedIntegerValue] == 999){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"Auser condition!");
    }];
    
    [p apc_propertyGetter:@"age" bindAccessCountCondition:^BOOL(id  _Nonnull instance, id  _Nullable value, NSUInteger count) {
        
        if(count == 1){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"Auser count!");
    }];
    //////
    [p apc_frontOfPropertySetter:@"age" bindWithBlock:^(id  _Nonnull instance) {
        
        NSLog(@"front of age!");
    }];
    
    [p apc_backOfPropertySetter:@"age" bindWithBlock:^(id  _Nonnull instance, id  _Nullable value) {
       
         NSLog(@"bakc of age!");
    }];
    
    [p apc_propertySetter:@"age" bindUserCondition:^BOOL(id  _Nonnull instance, id  _Nullable value) {
        
        if([value unsignedIntegerValue] == 999){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"user condition!");
    }];
    
    [p apc_propertySetter:@"age" bindAccessCountCondition:^BOOL(id  _Nonnull instance, id  _Nullable value, NSUInteger count) {
        
        if(count == 1){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"user count!");
    }];
    
    NSUInteger age0 = p.age;
    p.age = 123;
    NSUInteger age1 = p1.age;
}

- (void)testTriggerFrontNormalClass
{
    [Person apc_frontOfPropertyGetter:@"age" bindWithBlock:^(id  _Nonnull instance) {
        
        NSLog(@"Afront of age!");
    }];
    
    [Person apc_backOfPropertyGetter:@"age" bindWithBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"Abakc of age!");
    }];
    
    [Person apc_propertyGetter:@"age" bindUserCondition:^BOOL(id  _Nonnull instance, id  _Nullable value) {
        
        if([value unsignedIntegerValue] == 999){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"Auser condition!");
    }];
    
    [Person apc_propertyGetter:@"age" bindAccessCountCondition:^BOOL(id  _Nonnull instance, id  _Nullable value, NSUInteger count) {
        
        if(count == 1){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"Auser count!");
    }];
    //////
    [Person apc_frontOfPropertySetter:@"age" bindWithBlock:^(id  _Nonnull instance) {
        
        NSLog(@"front of age!");
    }];
    
    [Person apc_backOfPropertySetter:@"age" bindWithBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"bakc of age!");
    }];
    
    [Person apc_propertySetter:@"age" bindUserCondition:^BOOL(id  _Nonnull instance, id  _Nullable value) {
        
        if([value unsignedIntegerValue] == 999){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"user condition!");
    }];
    
    [Person apc_propertySetter:@"age" bindAccessCountCondition:^BOOL(id  _Nonnull instance, id  _Nullable value, NSUInteger count) {
        
        if(count == 1){
            return YES;
        }
        return NO;
    } withBlock:^(id  _Nonnull instance, id  _Nullable value) {
        
        NSLog(@"user count!");
    }];
    
    Person* p = [Person new];
    p.age = 999;
    NSUInteger age0 = p.age;
}

- (void)testClassSuperclassSubclass
{
    
    [Person apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {

        return @(999);
    }];
    
    [Man apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
        
        return @(111);
    }];
    
    [Man    apc_unbindLazyLoadForProperty:@"age"];
    [Person apc_unbindLazyLoadForProperty:@"age"];

    
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
    
    AutoLazyPropertyInfo* p0 = [AutoLazyPropertyInfo instanceWithProperty:@"age" aClass:p];
    AutoLazyPropertyInfo* p1 = [AutoLazyPropertyInfo instanceWithProperty:@"age" aClass:p];
    [p0 invalid];
    NSMutableSet* set = [NSMutableSet setWithObjects:p0, p1, nil];
    
    [p1 invalid];
    
    AutoLazyPropertyInfo* p2 = [AutoLazyPropertyInfo instanceWithProperty:@"age" aClass:p];
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

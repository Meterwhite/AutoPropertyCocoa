//
//  APCTest.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoTriggerPropertyInfo.h"
#import "AutoLazyPropertyInfo.h"
#import "AutoPropertyCocoa.h"
#import <objc/runtime.h>
#import "APCTest.h"
#import "Superman.h"
#import "Person.h"
#import "Man.h"

@implementation APCTest


+ (void)testDemo:(NSUInteger)index
{
    NSString* fName = _f_map[@(index)];
    if(fName == nil){
        
        return;
    }
    SEL sel = NSSelectorFromString(fName);
    IMP imp = [self methodForSelector:sel];
    ((void(*)(id,SEL))imp)(self,sel);
}
+ (void)testDemoFrom:(NSUInteger)from to:(NSUInteger)to
{

    for (NSUInteger i = from; i < to; i++) {
        
        [self testDemo:i];
    }
}


static NSMutableDictionary* _f_map;
+ (void)load
{
    unsigned int count;
    _f_map = [NSMutableDictionary dictionary];
    Method* m_list = class_copyMethodList(objc_getMetaClass(class_getName(self)), &count);//
    
    while (count--) {
        
        Method m = m_list[count];
        NSString* fName = @(sel_getName(method_getName(m)));
        if(NO == [fName containsString:@"_"]){
            
            continue;
        }
        NSArray* cmps = [fName componentsSeparatedByString:@"_"];
        _f_map[@((NSUInteger)[cmps.lastObject integerValue])] = fName;
    }
    free(m_list);
}

#define APC_TEST_CLEANCLASS \
[APCTest unbindAllClass];
+ (void)unbindAllClass
{
    
    [AutoLazyPropertyInfo unhookClassAllProperties:[Person class]];
    [AutoLazyPropertyInfo unhookClassAllProperties:[Man class]];
    
    [AutoTriggerPropertyInfo unhookClassAllProperties:[Person class]];
    [AutoTriggerPropertyInfo unhookClassAllProperties:[Man class]];
}

#pragma mark - demo

apc_testfunc(testClassInstanceLazyLoadSimple,0)
{
    APC_TEST_CLEANCLASS
    
    Man* m = [Man new];
    Man* m2 = [Man new];
    
    [Man apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @(999);
    }];
    
    [m apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @(111);
    }];
    
    
    NSParameterAssert(m2.age == 999);
    NSParameterAssert(m.age == 111);
}

apc_testfunc(testClassInstanceLazyLoadSimple,1)
{
    APC_TEST_CLEANCLASS
    
    Person* p = [Person new];
    Man* m = [Man new];
    
    [Person apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @(999);
    }];
    
    [m apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @(111);
    }];
    
    
    NSParameterAssert(p.age == 999);
    NSParameterAssert(m.age == 111);
}

apc_testfunc(testSuperAndSubClass,2)
{
    APC_TEST_CLEANCLASS
    
    Person* p = [Person new];
    Man* m = [Man new];
    
    [Person apc_lazyLoadForProperty:@"name" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Person";
    }];
    
    
    NSParameterAssert([p.name isEqualToString:@"Person"]);
    NSParameterAssert([m.name isEqualToString:@"Person"]);
}

apc_testfunc(testSuperAndSubClass,3)
{
    APC_TEST_CLEANCLASS
    
    Person*   p = [Person new];
    Superman* m = [Superman new];
    
    [Person apc_lazyLoadForProperty:@"name" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Person";
    }];
    
    
    NSParameterAssert([p.name isEqualToString:@"Person"]);
    NSParameterAssert([m.name isEqualToString:@"Person"]);
}

apc_testfunc(testSuperAndSubClass,4)
{
    APC_TEST_CLEANCLASS
    
    Person* p = [Person new];
    Man* m = [Man new];
    
    [Man apc_lazyLoadForProperty:@"name" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Person";
    }];
    
    
    NSParameterAssert(p.name == nil);
    NSParameterAssert([m.name isEqualToString:@"Person"]);
}

apc_testfunc(testSuperAndSubClass,5)
{
    APC_TEST_CLEANCLASS
    
    Person*     p   = [Person new];
    Superman*   m   = [Superman new];
    
    [Man apc_lazyLoadForProperty:@"name" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Person";
    }];
    
    
    NSParameterAssert(p.name == nil);
    NSParameterAssert([m.name isEqualToString:@"Person"]);
}

apc_testfunc(testUnbindDeadCycle,50)
{
    APC_TEST_CLEANCLASS
    
    Person*     p   = [Person new];
    Man*        m   = [Man new];
    Superman*   sm  = [Superman new];
    
    [Person apc_lazyLoadForProperty:@"name1" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Person";
    }];
    
    [Man apc_lazyLoadForProperty:@"name1" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Man";
    }];
    
    [Superman apc_lazyLoadForProperty:@"name1" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Superman";
    }];
    
    //Normal
    NSParameterAssert([p.name1 isEqualToString:@"Person"]);
    NSParameterAssert([m.name1 isEqualToString:@"Man"]);
    NSParameterAssert([sm.name1 isEqualToString:@"Superman"]);
}

apc_testfunc(testUnbindDeadCycleMultThread,51)
{
    APC_TEST_CLEANCLASS
    
    Superman*   sm  = [Superman new];
    
    [Person apc_lazyLoadForProperty:@"name1" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Person";
    }];
    
    [Man apc_lazyLoadForProperty:@"name1" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Man";
    }];
    
    [Superman apc_lazyLoadForProperty:@"name1" usingBlock:^id _Nullable(id _Nonnull instance) {
        
        return @"Superman";
    }];
    
    //APCLazyloadOldLoopController.h -> joinLoop: -> count>4 -> error
    dispatch_queue_t queue = dispatch_queue_create("Lazy-load", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_apply(30000, queue, ^(size_t s) {
        
        int i = 100;
        while (i--) {
            NSLog(@"%@",sm.name1);
        }
    });
    
}

apc_testfunc(testTriggerFrontNormalInstance, 100)
{
    APC_TEST_CLEANCLASS
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

apc_testfunc(testTriggerFrontNormalClass,101)
{
    APC_TEST_CLEANCLASS
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


@end

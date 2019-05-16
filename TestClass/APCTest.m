//
//  APCTest.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerGetterProperty.h"
#import "NSObject+APCExtension.h"
#import "apc-objc-extension.h"
#import "AutoPropertyCocoa.h"
#import "APCPropertyHook.h"
#import "APCLazyProperty.h"
#import "APCClassMapper.h"
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

static bool _clearTest;

+ (void)openClearTest
{
    _clearTest = YES;
}
+ (void)closeClearTest
{
    _clearTest = NO;
}

#define APC_TEST_CLEAN \
do{\
    if(_clearTest){\
    \
        apc_unhook_all();\
    };\
}while(0);


#pragma mark - Demos

APC_TEST_DEMO(removeMethod,0)
{
    APC_TEST_CLEAN
    {
        class_removeMethod_APC_OBJC2([Man class], @selector(manDeletedWillCallPerson));
        
        APCTestInstance(Man, m);
        NSParameterAssert([m.manDeletedWillCallPerson isEqualToString:@"Person"]);
        
        APCTestInstance(Superman, sm);
        NSParameterAssert([sm.manDeletedWillCallPerson isEqualToString:@"Person"]);
    }
}


APC_TEST_DEMO(ClassUnhook,100)
{
   
    APC_TEST_CLEAN
    {
        ///Unimplemented method, add and delete.
        [Man apc_lazyLoadForProperty:@key_manObj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"Man";
        }];
        
        [Man apc_unbindLazyLoadForProperty:@key_manObj];
        
        APCTestInstance(Man, m);
        NSParameterAssert(m.manObj == nil);
        
        APCTestInstance(Superman, sm);
        NSParameterAssert(sm.manObj == nil);
    }
    
    APC_TEST_CLEAN
    {
        ///Repeat bind and unbind
        [Man apc_lazyLoadForProperty:@key_manObj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"Man0";
        }];
        
        [Man apc_lazyLoadForProperty:@key_manObj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"Man1";
        }];
        
        {
            APCTestInstance(Man, m);
            APCTestInstance(Superman, sm);
            NSParameterAssert([m.manObj isEqualToString:@"Man1"]);
            NSParameterAssert([sm.manObj isEqualToString:@"Man1"]);
        }
        
        {
            APCTestInstance(Man, m);
            APCTestInstance(Superman, sm);
            [Man apc_unbindLazyLoadForProperty:@key_manObj];
            NSParameterAssert(m.manObj == nil);
            NSParameterAssert(sm.manObj == nil);
        }
    }
}

APC_TEST_DEMO(InstanceUnhook,101)
{
    APC_TEST_CLEAN
    {
        APCTestInstance(Man, m);
        APCTestInstance(Superman, sm);
        ///Reapt bind.
        [m apc_lazyLoadForProperty:@key_manObj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"M a n";
        }];
        
        [sm apc_lazyLoadForProperty:@key_manObj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"S u p e r m a n";
        }];
        
        NSParameterAssert([m.manObj isEqualToString:@"M a n"]);
        NSParameterAssert([sm.manObj isEqualToString:@"S u p e r m a n"]);
        
        m.manObj = nil;
        sm.manObj = nil;
        
        [m apc_unbindLazyLoadForProperty:@key_manObj];
        
        NSParameterAssert(m.manObj == nil);
        NSParameterAssert([sm.manObj isEqualToString:@"S u p e r m a n"]);
    }
    
    APC_TEST_CLEAN
    {
        APCTestInstance(Man, m);
        ///Repeat unbind instance
        [m apc_lazyLoadForProperty:@key_manObj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"M a n";
        }];
        
        NSParameterAssert([m.manObj isEqualToString:@"M a n"]);
        m.manObj = nil;
        
        [m apc_unbindLazyLoadForProperty:@key_manObj];
        [m apc_unbindLazyLoadForProperty:@key_manObj];
        
        NSParameterAssert(m.manObj == nil);
    }
}

APC_TEST_DEMO(ClassLazyload,102)
{
    APC_TEST_CLEAN
    {
        [Man apc_lazyLoadForProperty:@key_arrayValue selector:@selector(array)];
        [Man apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"gettersetterobj";
        }];
        
        [Man apc_lazyLoadForProperty:@key_getterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"getterobj";
        }];
        
        [Man apc_lazyLoadForProperty:@key_setterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"setterobj";
        }];
        
        {
            APCTestInstance(Man, m);
            
            NSParameterAssert(m.objCopy == nil);
            NSParameterAssert([m.arrayValue isKindOfClass:[NSArray class]] && m.arrayValue.count == 0);
            NSParameterAssert([m.gettersetterobj isEqualToString:@"gettersetterobj"]);
            NSParameterAssert([m.getterobj isEqualToString:@"getterobj"]);
            NSParameterAssert([m.setterobj isEqualToString:@"setterobj"]);
        }
        
        {
            APCTestInstance(Superman, m);
            
            NSParameterAssert(m.objCopy == nil);
            NSParameterAssert([m.arrayValue isKindOfClass:[NSArray class]] && m.arrayValue.count == 0);
            NSParameterAssert([m.gettersetterobj isEqualToString:@"gettersetterobj"]);
            NSParameterAssert([m.getterobj isEqualToString:@"getterobj"]);
            NSParameterAssert([m.setterobj isEqualToString:@"setterobj"]);
        }
    }
}

APC_TEST_DEMO(InstanceLazyload,103)
{
    APC_TEST_CLEAN
    {
        APCTestInstance(Man, m);
        [m apc_lazyLoadForProperty:@key_arrayValue selector:@selector(array)];
        [m apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {

            return @"gettersetterobj";
        }];
//
//        [m apc_lazyLoadForProperty:@key_getterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
//
//            return @"getterobj";
//        }];
//
//        [m apc_lazyLoadForProperty:@key_setterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
//
//            return @"setterobj";
//        }];
        
        {
//            NSParameterAssert(m.objCopy == nil);
//            NSParameterAssert([m.arrayValue isKindOfClass:[NSArray class]] && m.arrayValue.count == 0);
            NSParameterAssert([m.gettersetterobj isEqualToString:@"gettersetterobj"]);
//            NSParameterAssert([m.getterobj isEqualToString:@"getterobj"]);
//            NSParameterAssert([m.setterobj isEqualToString:@"setterobj"]);
        }
        m.arrayValue = nil;
        m.gettersetterobj = nil;
        apc_instance_unhookFromProxyClass(m);
        
        {
            NSParameterAssert(m.arrayValue == nil);
            NSParameterAssert(m.gettersetterobj == nil);
        }
        
        
        printf("K");
    }
}


@end

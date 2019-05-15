//
//  APCTest.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerGetterProperty.h"
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


#pragma mark - demo

apc_testfunc(ClassUnhook,100)
{
    APC_TEST_CLEAN
    {
        ///Implementation is replaced and then deleted.
        [Man apc_lazyLoadForProperty:@key_manDeletedWillCallPerson usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @(__func__);
        }];
        
        [Man apc_unbindLazyLoadForProperty:@key_manDeletedWillCallPerson];
        
        APCTestInstance(Superman, sm);
        
        NSAssert([sm.manDeletedWillCallPerson isEqualToString:@"Person"], @"Fail");
    }
    
    APC_TEST_CLEAN
    {
        ///Unimplemented method, add and delete.
        [Man apc_lazyLoadForProperty:@key_manObj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"Man";
        }];
        
        [Man apc_unbindLazyLoadForProperty:@key_manObj];
        
        APCTestInstance(Superman, sm);
        
        NSAssert(sm.manDeletedWillCallPerson == nil, @"Fail");
    }
}



@end

//
//  APCTest.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/8.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "apc-objc-extension.h"
#import "APCScope.h"
#import "AutoPropertyCocoa.h"
#import "APCObjectLock.h"
#import "APCRuntime.h"
#import "Superman.h"
#import "APCTest.h"
#import "Person.h"
#import "Man.h"

@implementation APCTest

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

        [m apc_lazyLoadForProperty:@key_getterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {

            return @"getterobj";
        }];

        [m apc_lazyLoadForProperty:@key_setterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {

            return @"setterobj";
        }];
        
        {
            NSParameterAssert(m.objCopy == nil);
            NSParameterAssert([m.arrayValue isKindOfClass:[NSArray class]] && m.arrayValue.count == 0);
            NSParameterAssert([m.gettersetterobj isEqualToString:@"gettersetterobj"]);
            NSParameterAssert([m.getterobj isEqualToString:@"getterobj"]);
            NSParameterAssert([m.setterobj isEqualToString:@"setterobj"]);
        }
    }
}

APC_TEST_DEMO(ClassTrigger,104)
{
    APC_TEST_CLEAN
    {
        __block ushort flag = 0;
        __block ushort apc_propertyGetterbindUserCondition_2 = 0;
        __block ushort apc_propertyGetterbindAccessCountCondition_2 = 0;
        
        [Man apc_willGet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance) {
            
            ++flag;
            NSParameterAssert(flag == 1);
        }];
        
        [Man apc_didGet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++flag;
            NSParameterAssert(flag == 2);
        }];
        
        [Man apc_get:@key_obj bindUserCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertyGetterbindUserCondition_2++;
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertyGetterbindUserCondition_2++;
        }];
        
        [Man apc_get:@key_intValue bindAccessCountCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value, NSUInteger count) {
            
            apc_propertyGetterbindAccessCountCondition_2++;
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertyGetterbindAccessCountCondition_2++;
        }];
        
        APCTestInstance(Man, m);
        [m obj];
        [m intValue];
        NSParameterAssert(flag == 2);
        NSParameterAssert(apc_propertyGetterbindUserCondition_2 == 2);
        NSParameterAssert(apc_propertyGetterbindAccessCountCondition_2 == 2);
    }
    
    APC_TEST_CLEAN
    {
        __block ushort flag = 0;
        __block ushort apc_propertySetterbindUserCondition_2 = 0;
        __block ushort apc_propertySetterbindAccessCountCondition_2 = 0;
        
        [Man apc_willSet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance) {
            
            ++flag;
            NSParameterAssert(flag == 1);
        }];
        
        [Man apc_didSet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++flag;
            NSParameterAssert(flag == 2);
        }];
        
        [Man apc_set:@key_obj bindUserCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            if([value integerValue] == 100){
            
                apc_propertySetterbindUserCondition_2++;
            }
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertySetterbindUserCondition_2++;
        }];
        
        [Man apc_set:@key_intValue bindAccessCountCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value, NSUInteger count) {
            
            apc_propertySetterbindAccessCountCondition_2++;
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertySetterbindAccessCountCondition_2++;
        }];
        
        APCTestInstance(Man, m);
        m.obj = @(100);
        m.intValue = 100;
        NSParameterAssert(flag == 2);
        NSParameterAssert(apc_propertySetterbindUserCondition_2 == 2);
        NSParameterAssert(apc_propertySetterbindAccessCountCondition_2 == 2);
    }
}

APC_TEST_DEMO(InstanceTrigger,105)
{
    APC_TEST_CLEAN
    {
        APCTestInstance(Man, m);
        __block ushort flag = 0;
        __block ushort apc_propertyGetterbindUserCondition_2 = 0;
        __block ushort apc_propertyGetterbindAccessCountCondition_2 = 0;
        
        [m apc_willGet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance) {
            
            ++flag;
            NSParameterAssert(flag == 1);
        }];
        
        [m apc_didGet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++flag;
            NSParameterAssert(flag == 2);
        }];
        
        [m apc_get:@key_obj bindUserCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertyGetterbindUserCondition_2++;
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertyGetterbindUserCondition_2++;
        }];
        
        [m apc_get:@key_intValue bindAccessCountCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value, NSUInteger count) {
            
            apc_propertyGetterbindAccessCountCondition_2++;
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertyGetterbindAccessCountCondition_2++;
        }];
        
        [m obj];
        [m intValue];
        NSParameterAssert(flag == 2);
        NSParameterAssert(apc_propertyGetterbindUserCondition_2 == 2);
        NSParameterAssert(apc_propertyGetterbindAccessCountCondition_2 == 2);
    }
    
    APC_TEST_CLEAN
    {
        __block ushort flag = 0;
        __block ushort apc_propertySetterbindUserCondition_2 = 0;
        __block ushort apc_propertySetterbindAccessCountCondition_2 = 0;
        
        APCTestInstance(Man, m);
        [m apc_willSet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance) {
            
            ++flag;
            NSParameterAssert(flag == 1);
        }];
        
        [m apc_didSet:@key_obj bindWithBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++flag;
            NSParameterAssert(flag == 2);
        }];
        
        [m apc_set:@key_obj bindUserCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            if([value integerValue] == 100){
                
                apc_propertySetterbindUserCondition_2++;
            }
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertySetterbindUserCondition_2++;
        }];
        
        [m apc_set:@key_intValue bindAccessCountCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value, NSUInteger count) {
            
            apc_propertySetterbindAccessCountCondition_2++;
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            apc_propertySetterbindAccessCountCondition_2++;
        }];
        
        m.obj = @(100);
        m.intValue = 100;
        NSParameterAssert(flag == 2);
        NSParameterAssert(apc_propertySetterbindUserCondition_2 == 2);
        NSParameterAssert(apc_propertySetterbindAccessCountCondition_2 == 2);
    }
}


APC_TEST_DEMO(ClassMix,106)
{
    APC_TEST_CLEAN
    {
        [Person apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"Person.gettersetterobj";
        }];
        
        [Man apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"Man.gettersetterobj";
        }];
        
        [Superman apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            return @"Superman.gettersetterobj";
        }];
        
        APCTestInstance(Person, p);
        APCTestInstance(Man, m);
        APCTestInstance(Superman, sm);
        
        NSParameterAssert([p.gettersetterobj isEqualToString:@"Person.gettersetterobj"]);
        NSParameterAssert([m.gettersetterobj isEqualToString:@"Man.gettersetterobj"]);
        NSParameterAssert([sm.gettersetterobj isEqualToString:@"Superman.gettersetterobj"]);
        
        [Person apc_get:@key_gettersetterobj bindAccessCountCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value, NSUInteger count) {
            
            if(count == 0){
                
                NSParameterAssert(([value isEqualToString:@"Superman.gettersetterobj"]));
            }else if (count == 1){
                
                NSParameterAssert(([value isEqualToString:@"Man.gettersetterobj"]));
            }else if (count == 2){
                
                NSParameterAssert(([value isEqualToString:@"Person.gettersetterobj"]));
            }
            
            return 1;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {}];
        
        [sm mySetGettersetterobj:nil];
        [sm myGetGettersetterobj];
        
        [Superman apc_unbindLazyLoadForProperty:@key_gettersetterobj];
        [sm mySetGettersetterobj:nil];
        [sm myGetGettersetterobj];
        
        [Man apc_unbindLazyLoadForProperty:@key_gettersetterobj];
        [sm mySetGettersetterobj:nil];
        [sm myGetGettersetterobj];
    }
}

APC_TEST_DEMO(InstanceMix,107)
{
    APC_TEST_CLEAN
    {
        __block int count = 0;
        
        APCTestInstance(Man, m);
        
        [m apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return @"gettersetterobj";
        }];
        
        [m apc_lazyLoadForProperty:@key_obj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return @"obj";
        }];
        
        [m apc_didSet:@key_gettersetterobj bindWithBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++count;
        }];
        
        [m apc_set:@key_gettersetterobj bindAccessCountCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value, NSUInteger count) {
            
            ++count;
            return YES;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++count;
        }];
        
        NSParameterAssert([m.obj isEqualToString:@"obj"]);
        NSParameterAssert(count==1);
        NSParameterAssert([m.gettersetterobj isEqualToString:@"gettersetterobj"]);
        NSParameterAssert(count==4);
        m.gettersetterobj = @"0";
        NSParameterAssert(count==6);
    }
}

APC_TEST_DEMO(ClassInstanceMix,108)
{
    APC_TEST_CLEAN
    {
        __block int count = 0;
        [Person apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return @"Person.gettersetterobj";
        }];
        
        [Man apc_lazyLoadForProperty:@key_obj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return @"Man.obj";
        }];
        
        [Man apc_didSet:@key_setterobj bindWithBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++count;
        }];
        
        APCTestInstance(Man, m);
        
        [m apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return APCSuperPerformedAsId(instance);
        }];
        
        NSParameterAssert([m.gettersetterobj isEqualToString:@"Person.gettersetterobj"]);
        NSParameterAssert([m.obj isEqualToString:@"Man.obj"]);
        m.setterobj = @"0";
        NSParameterAssert([m.setterobj isEqualToString:@"0"]);
        
        NSParameterAssert(count==4);
    }
}

APC_TEST_DEMO(UserEnviroment, 109)
{
    APC_TEST_CLEAN
    {
        __block int count = 0;
        
        [Person apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return @"Person.gettersetterobj";
        }];
        
        [Man apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return APCSuperPerformedAsId(instance);
        }];
        
        [Superman apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return APCSuperPerformedAsId(instance);
        }];
        
        APCTestInstance(Superman, sm);
        
        NSParameterAssert([sm.gettersetterobj isEqualToString:@"Person.gettersetterobj"]);
        NSParameterAssert(count == 3);
        
        
        [sm apc_lazyLoadForProperty:@key_gettersetterobj  usingBlock:^id _Nullable(Superman*  _Nonnull instance) {
            
            ++count;
            [instance fly];
            NSParameterAssert([instance apc_isKindOfClass:[Superman class]]);
            return APCSuperPerformedAsId(instance);
        }];
        
        sm.gettersetterobj = nil;
        NSParameterAssert([sm.gettersetterobj isEqualToString:@"Person.gettersetterobj"]);
        
        NSParameterAssert(count == 7);
    }
}

APC_TEST_DEMO(BasicValue, 110)
{
    APC_TEST_CLEAN
    {
        APCTestInstance(Man, m);
        __block int count = 0;
        [m apc_lazyLoadForProperty:@key_intValue usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            return @(1024);
        }];
        
        [m apc_get:@key_intValue bindUserCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++count;
            if([value integerValue] > 0){
                return YES;
            }
            return NO;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            
            ++count;
        }];
        
        [m apc_lazyLoadForProperty:@key_rectValue usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
            
            ++count;
            APCRect rect = {{1024,1024},{1024,1024}};
            return [NSValue value:&rect
                     withObjCType:@encode(APCRect)];
        }];
        
        [m apc_set:@key_rectValue bindAccessCountCondition:^BOOL(id_apc_t  _Nonnull instance, id  _Nullable value, NSUInteger icount) {
            
            if(icount == 0){
                ++count;
                return YES;
            }
            return NO;
        } withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
            ++count;
        }];
        
        NSParameterAssert(m.intValue == 1024);
        NSParameterAssert(count == 3);
        
        NSParameterAssert(m.rectValue.size.width == 1024);
        NSParameterAssert(count == 4);
        
        APCRect newrect = {{1024,1024},{1024,1024}};
        m.rectValue = newrect;
        NSParameterAssert(count == 6);
    }
}

APC_TEST_DEMO(InstanceMultiThread, 111)
{
    APC_TEST_CLEAN
    {
        static Man* m;
        m = [Man new];
        static dispatch_queue_t queue;
        
        queue = dispatch_queue_create("InstanceMultiThread", DISPATCH_QUEUE_CONCURRENT);
        
        __block int i = 0;
        for (i = 50000; i >= 0; i--) {
            
            
            dispatch_async(queue, ^{
                
                apc_safe_instance(m, ^(id  _Nullable object) {
                    
                    [object apc_lazyLoadForProperty:@key_obj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
                        
                        return @"obj";
                    }];
                });
            });
            
            dispatch_async(queue, ^{
                
                apc_safe_instance(m, ^(id  _Nullable object) {
                    
                    [object apc_unbindLazyLoadForProperty:@key_obj];
                });
            });
            
            dispatch_async(queue, ^{
                
                apc_safe_instance(m, ^(Man* object) {
                    
                    [object obj];
                });
            });
        }
    }
}

APC_TEST_DEMO(ClassMultiThread, 112)
{
    APC_TEST_CLEAN
    {
        static Man* m;
        m = [Man new];
        static dispatch_queue_t queue;
        
        queue = dispatch_queue_create("ClassMultiThread", DISPATCH_QUEUE_CONCURRENT);
        
        __block int i = 0;
        for (i = 50000; i >= 0; i--) {
            
            
            dispatch_async(queue, ^{
                
                [Man apc_lazyLoadForProperty:@key_obj usingBlock:^id _Nullable(id_apc_t  _Nonnull instance) {
                    
                    return @"obj";
                }];
            });
            
            dispatch_async(queue, ^{
                
                [Man apc_unbindLazyLoadForProperty:@key_obj];
            });
            
            dispatch_async(queue, ^{
                
                [m obj];
            });
        }
    }
}

#pragma mark - Ready for Work

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
    for (NSUInteger i = from; i < to; i++)
        
        [self testDemo:i];
}

static NSMutableDictionary* _f_map;
+ (void)load
{
    unsigned int count;
    _f_map = [NSMutableDictionary dictionary];
    Method* m_list = class_copyMethodList(objc_getMetaClass(class_getName(self)), &count);
    
    while (count--) {
        
        Method m = m_list[count];
        NSString* fName = @(sel_getName(method_getName(m)));
        if(![fName containsString:@"_"]){
            
            continue;
        }
        NSArray* cmps = [fName componentsSeparatedByString:@"_"];
        _f_map[@((NSUInteger)[cmps.lastObject integerValue])] = fName;
    }
    free(m_list);
}

static bool _clearTest = YES;

+ (void)openClearTest
{
    _clearTest = YES;
}
+ (void)closeClearTest
{
    _clearTest = NO;
}
@end

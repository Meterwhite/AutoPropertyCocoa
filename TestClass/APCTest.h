//
//  APCTest.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define APC_TEST_DEMO(domo,id) + (void)domo##__##id
/**
 100
 101
 */
@interface APCTest : NSObject

+ (void)openClearTest;
+ (void)closeClearTest;

+ (void)testDemo:(NSUInteger)index;
+ (void)testDemoFrom:(NSUInteger)from to:(NSUInteger)to;

APC_TEST_DEMO(removeMethod,0);

#pragma mark - unhook
APC_TEST_DEMO(ClassUnhook,100);
APC_TEST_DEMO(InstanceUnhook,101);

APC_TEST_DEMO(ClassLazyload,102);
APC_TEST_DEMO(InstanceLazyload,103);

APC_TEST_DEMO(ClassGettertrigger,104);
APC_TEST_DEMO(InstanceGettertrigger,105);

APC_TEST_DEMO(ClassSettertrigger,106);
APC_TEST_DEMO(InstanceSettertrigger,107);

@end

NS_ASSUME_NONNULL_END

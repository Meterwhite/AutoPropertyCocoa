//
//  APCTest.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APCTest : NSObject

+ (void)openClearTest;
+ (void)closeClearTest;

+ (void)testDemo:(NSUInteger)index;
+ (void)testDemoFrom:(NSUInteger)from to:(NSUInteger)to;

#define apc_testfunc(name,idx)\
\
+ (void)name##__##idx

apc_testfunc(testClassInstanceLazyLoadSimple,0);


apc_testfunc(testTriggerFrontNormalInstance, 100);
@end

NS_ASSUME_NONNULL_END

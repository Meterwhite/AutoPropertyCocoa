//
//  APCLazyloadOldLoopController.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/13.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Make property thread safe and break dead cycle when lazy-load property perform old imp from subclass to superclass.
 */
@interface APCLazyloadOldLoopController : NSObject

+ (BOOL)testingIsInLoop:(id _Nonnull)instance;

+ (NSUInteger)loopCount:(id _Nonnull)instance;

+ (void)joinLoop:(id _Nonnull)instance;

+ (void)breakLoop:(id _Nonnull)instance;

@end


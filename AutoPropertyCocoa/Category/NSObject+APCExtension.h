//
//  NSObject+APCExtension.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/11.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSObject (APCExtension)

- (BOOL)apc_lazyload_performOldLoop_testing;
- (void)apc_lazyload_performOldLoop;
- (NSUInteger)apc_lazyload_performOldLoop_lenth;
- (void)apc_lazyload_performOldLoop_break;
@end



//
//  APCProxyInstanceDisposer.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/16.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCScope.h"


/**
 Lazily release resources
 */
@interface APCProxyInstanceDisposer : NSObject
- (nonnull instancetype)initWithClass:(nullable APCProxyClass)clazz;
@end

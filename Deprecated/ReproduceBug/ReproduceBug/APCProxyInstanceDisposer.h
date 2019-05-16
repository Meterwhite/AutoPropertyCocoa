//
//  APCProxyInstanceDisposer.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/16.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APCProxyInstanceDisposer : NSObject
- (nonnull instancetype)initWithClass:(nullable Class)clazz;
@end

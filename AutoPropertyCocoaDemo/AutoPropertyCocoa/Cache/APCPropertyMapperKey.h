//
//  APCPropertyMapperKey.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APCPropertyMapperKey : NSObject<NSCopying>

+ (_Nonnull instancetype)keyWithClass:(Class _Nonnull)aClass;

+ (_Nonnull instancetype)keyWithClass:(Class _Nonnull)aClass
                    property:(NSString* _Nonnull)property;

- (NSUInteger)hash;
@end


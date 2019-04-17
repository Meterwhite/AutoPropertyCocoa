//
//  APCPropertyMapperkey.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCPropertyMapperkey;

@protocol APCPropertyMapperKeyProtocol <NSObject>

@required
- (APCPropertyMapperkey* _Nonnull)classMapperkey;
- (NSSet<APCPropertyMapperkey*>* _Nonnull)propertyMapperkeys;
@end

@interface APCPropertyMapperkey : NSObject<NSCopying>

+ (instancetype _Nonnull)keyWithClass:(Class _Nonnull)aClass;

+ (instancetype _Nonnull)keyWithClass:(Class _Nonnull)aClass
                    property:(NSString* _Nonnull)property;

- (NSUInteger)hash;
@end


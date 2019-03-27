//
//  APCPropertyCacheKey.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyCacheKey.h"

@implementation APCPropertyCacheKey
{
    NSUInteger _hashCode;
}

+ (instancetype)keyWithClass:(Class _Nonnull)aClass
                    property:(NSString* _Nonnull)property
{
    return [[self.class alloc] initWithClass:aClass property:property];
}

+ (instancetype)keyWithClass:(Class _Nonnull)aClass
{
    return [[self.class alloc] initWithClass:aClass];
}

- (instancetype)initWithClass:(Class _Nonnull)aClass
                     property:(NSString* _Nonnull)property
{
    self = [super init];
    if (self) {
        
        _hashCode = [[NSString stringWithFormat:@"%@.%@",NSStringFromClass(aClass),property] hash];
    }
    return self;
}

- (instancetype)initWithClass:(Class _Nonnull)aClass
{
    self = [super init];
    if (self) {
        
        _hashCode = [aClass hash];
    }
    return self;
}

- (NSUInteger)hash
{
    return _hashCode;
}
@end

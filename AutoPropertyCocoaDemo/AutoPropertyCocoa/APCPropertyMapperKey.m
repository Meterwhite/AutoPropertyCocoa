//
//  APCPropertyMapperKey.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyMapperKey.h"
//#import "APCHash.h"

@implementation APCPropertyMapperKey
{
    NSUInteger _hash;
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
        
        _hash = [apc_desMapperKeyString(aClass,property) hash];
        
//        NSUInteger h0 = [aClass hash];
//        NSUInteger h1 = [property hash];
//        void* ptr = malloc(sizeof(NSUInteger) * 2);
//        memcpy(ptr, &h0, sizeof(NSUInteger));
//        memcpy(ptr+sizeof(NSUInteger), &h1, sizeof(NSUInteger));
//
//        _hash = apc_hash_bytes(ptr, 2 * sizeof(NSUInteger));
//
//        free(ptr);
    }
    return self;
}

- (instancetype)initWithClass:(Class _Nonnull)aClass
{
    self = [super init];
    if (self) {
        
        _hash = [apc_srcMapperKeyString(aClass) hash];
        
//        NSUInteger h = [aClass hash];
//        _hash = apc_hash_bytes((uint8_t*)(&h), sizeof(NSUInteger));
    }
    return self;
}

- (NSUInteger)hash
{
    return _hash;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    typeof(self) c = [[self.class allocWithZone:zone] init];
    c->_hash = _hash;
    return c;
}

- (BOOL)isEqual:(id)object
{
    if(self == object)
        
        return YES;
    
    return _hash == [object hash];
}

@end

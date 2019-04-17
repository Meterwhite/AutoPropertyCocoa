//
//  APCPropertyMapperkey.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyMapperkey.h"

NS_INLINE NSString* apc_desMapperKeyString(Class desClass,NSString* propertyName){
    return [NSString stringWithFormat:@"%@.%@",NSStringFromClass(desClass),propertyName];
}

NS_INLINE NSString* apc_srcMapperKeyString(Class srcClass){
    return NSStringFromClass(srcClass);
}

@implementation APCPropertyMapperkey
{
    NSString*   _description;
    NSUInteger  _hash;
}

+ (instancetype)keyWithClass:(Class)aClass
                    property:(NSString*)property
{
    return [[self.class alloc] initWithClass:aClass property:property];
}

+ (instancetype)keyWithClass:(Class)aClass
{
    return [[self.class alloc] initWithClass:aClass];
}

- (instancetype)initWithClass:(Class)aClass
                     property:(NSString*)property
{
    self = [super init];
    if (self) {
        
        _description= apc_desMapperKeyString(aClass,property);
        _hash       = [_description hash];
        
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
        
        _description= apc_srcMapperKeyString(aClass);
        _hash       = [_description hash];
        
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
    APCPropertyMapperkey* c = [[self.class allocWithZone:zone] init];
    c->_description = _description;
    c->_hash        = _hash;
    return c;
}

- (BOOL)isEqual:(id)object
{
    if(self == object)
        
        return YES;
    
    return _hash == [object hash];
}

- (NSString *)description
{
    return _description;
}
@end

//
//  APCStringkey.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/21.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCStringkey.h"

@implementation APCStringkey


- (instancetype)initWithString:(NSString*)string
{
    self = [super init];
    if (self) {
        
        value = string;
    }
    return self;
}

+ (instancetype)stringkey
{
    return [[self allocWithZone:NSDefaultMallocZone()] init];
}

+ (nonnull instancetype)stringkeyWithString:(nonnull NSString*)string
{
    return [[self allocWithZone:NSDefaultMallocZone()] initWithString:string];
}

- (NSUInteger)hash
{
    return [value hash];
}

- (BOOL)isEqual:(APCStringkey*)object
{
    if(value == object->value) return YES;
    
    if(value.length != object->value.length) return NO;
    
    return [value isEqualToString:object->value];
}

- (BOOL)isEqualToString:(NSString *)string
{
    if(value == string) return YES;
    
    if(value.length != string.length) return NO;
    
    return [value isEqualToString:string];
}

- (nonnull instancetype)copyKey
{
    return [[APCStringkey alloc] initWithString:value];
}

@end

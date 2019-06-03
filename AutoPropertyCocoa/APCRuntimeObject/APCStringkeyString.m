//
//  APCStringkeyString.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/21.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCMultipleStringkeyString.h"
#import "APCMutableStringkeyString.h"
#import "APCSingleStringkeyString.h"
#import "APCStringkeyString.h"

@implementation APCStringkeyString

+ (instancetype)stringkeyStringWithString:(NSString *)string
{
    return [APCSingleStringkeyString stringkeyStringWithString:string];
}

+ (instancetype)stringkeyStringWithProperty:(NSString*)property
                                     getter:(NSString*)getter
                                     setter:(NSString*)setter
{
    
    NSAssert(property, @"APC: Property can not be nil!");
    
    if(getter || setter){
        
        return
        
        [APCMultipleStringkeyString stringkeyStringWithProperty:property
                                                         getter:getter
                                                         setter:setter];
    }
    return
    
    [APCSingleStringkeyString stringkeyStringWithString:property];
}

+ (instancetype)stringkeyStringFromArray:(NSArray<NSString *> *)array
{
    return [APCMultipleStringkeyString stringkeyStringFromArray:array];
}

- (instancetype)initWithStringArray:(NSArray<NSString *> *)array
{
    return [[APCMultipleStringkeyString alloc] initWithStringArray:array];
}

- (BOOL)isEqualToStringkeyString:(APCStringkeyString *)stringstring
{
    @throw
    
    [NSException exceptionWithName:NSDestinationInvalidException
                            reason:@"APC: Subclass responsibility."
                          userInfo:nil];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nullable [])buffer count:(NSUInteger)len
{
    @throw
    
    [NSException exceptionWithName:NSDestinationInvalidException
                            reason:@"APC: Subclass responsibility."
                          userInfo:nil];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    
    @throw
    
    [NSException exceptionWithName:NSDestinationInvalidException
                            reason:@"APC: Subclass responsibility."
                          userInfo:nil];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return [[APCMutableStringkeyString allocWithZone:zone] initWithStringArray:self.allStrings];
}

@end

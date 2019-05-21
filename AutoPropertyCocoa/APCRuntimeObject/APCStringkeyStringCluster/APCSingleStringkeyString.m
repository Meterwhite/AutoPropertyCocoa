//
//  APCSingleStringKeyString.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/21.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCMutableStringkeyString.h"
#import "APCSingleStringkeyString.h"

@implementation APCSingleStringkeyString
{
    NSArray<NSString*>* _allStrings;
}

+ (instancetype)stringkeyStringWithString:(NSString*)string
{
    return [APCSingleStringkeyString stringkeyWithString:string];
}

- (APCStringkeyString *)head
{
    return self;
}

- (NSUInteger)length
{
    return 1;
}

- (BOOL)isEqualToStringkeyString:(APCStringkeyString *)stringstring
{
    if(self == stringstring) return YES;
    
    if(1 != stringstring.length) return NO;
    
    return [value isEqualToString:stringstring->value];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id  _Nullable [])buffer
                                    count:(NSUInteger)len
{
    if(state->state != 0) return 0;
    
    __unsafe_unretained const id * const_ptr = &value;
    state->itemsPtr = (__typeof__(state->itemsPtr))const_ptr;
    
    (state->state)++;
    
    return 1;
}

- (NSArray<NSString *> *)allStrings
{
    return @[value];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[APCSingleStringkeyString allocWithZone:zone] initWithString:value];
}

@end

//
//  APCSingleStringKeyString.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/21.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCMutableStringkeyString.h"
#import "APCSingleStringkeyString.h"

@implementation APCSingleStringkeyString
{
    void*  _self_ptr;
}

+ (instancetype)stringkeyStringWithString:(NSString*)string
{
    APCSingleStringkeyString* ret
    =
    [APCSingleStringkeyString stringkeyWithString:string];
    
    ret->_self_ptr = (__bridge void *)(ret);
    
    return ret;
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
    if(state->state == 0){
        
        state->mutationsPtr = (unsigned long*)&_self_ptr;
    }else if(state->state != 0){
        
        return 0;
    }
    
    state->itemsPtr = (typeof(state->itemsPtr))(__unsafe_unretained const id *)(void*)(&_self_ptr);
    
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

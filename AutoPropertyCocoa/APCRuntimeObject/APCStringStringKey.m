//
//  APCStringStringKey.m
//  AutoPropertyCocoaMacOS
//
//  Created by MDLK on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCStringStringKey.h"

@implementation APCStringStringKey

+ (instancetype)key
{
    return [[self allocWithZone:NSDefaultMallocZone()] init];
}

+ (nonnull instancetype)keyWithMatchingProperty:(NSString*)property
{
    return [[APCStringStringKey alloc] initWithString:property];
}

+ (nonnull instancetype)keyWithProperty:(NSString*)property
                                 getter:(NSString*)getter
                                 setter:(NSString*)setter
{
    
    APCStringStringKey* isetter = setter ? [self key] : nil;
    APCStringStringKey* igetter = getter ? [self key] : nil;
    APCStringStringKey* ihead   = [self key];
    
    ihead->value    =   property;
    ihead->head     =   ihead;
    
    do {
        
        if(igetter == nil) break;
        
        ihead->next       =   igetter;
        igetter->value    =   getter;
        igetter->head     =   ihead;
        
        if(isetter == nil) break;
        
        igetter->next     =   isetter;
        isetter->value    =   setter;
        isetter->head     =   ihead;
    } while (0);
    
    return ihead;
}

- (instancetype)initWithString:(NSString*)string
{
    self = [super init];
    if (self) {
        
        value = string;
        head  = self;
    }
    return self;
}

- (NSUInteger)hash
{
    return [value hash];
}

- (BOOL)isEqual:(APCStringStringKey*)object
{
    if(value == object->value) return YES;
    
    if(value.length != object->value.length) return YES;
    
    return [value isEqualToString:object->value];
}

- (void)dealloc
{
    head = nil;
}

@end

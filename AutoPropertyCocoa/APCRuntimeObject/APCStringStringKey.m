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
    return [[self allocWithZone:NSDefaultMallocZone()] initWithString:property];
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

+ (instancetype)keyFromArray:(NSArray<NSString *> *)array
{
    APCStringStringKey* ihead       = nil;
    APCStringStringKey* previous    = nil;
    APCStringStringKey* current     = nil;
    for (NSString* item in array) {
        
        if(previous == nil){
            
            ihead = [APCStringStringKey keyWithMatchingProperty:item];
            ihead->head = ihead;
            current     = ihead;
        }else {
            
            current = [APCStringStringKey keyWithMatchingProperty:item];
            previous->next = current;
            previous->head = ihead;
        }
        previous = current;
    }
    
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

- (NSUInteger)count
{
    
    NSUInteger          count   = 1;
    APCStringStringKey* item    = self;
    
    while (nil != (item = item->next))
        ++count;
    
    return count;
}

- (BOOL)isEqualToStringString:(APCStringStringKey *)stringstring
{
    if(self == stringstring) return YES;
    
    if(self.count != stringstring.count) return NO;
    
    APCStringStringKey* selfKey = self;
    while (selfKey != nil && stringstring != nil) {
        
        if(selfKey){
            
            if(NO ==[selfKey isEqual:stringstring]) return NO;
                
            selfKey         = selfKey->next;
            stringstring    = stringstring->next;
        }
    }
    
    if(selfKey == nil && stringstring == nil) return YES;
    
    return NO;
}

- (void)dealloc
{
    head = nil;
}

@end

//
//  APCMultipleStringkeyString.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCMultipleStringkeyString.h"
#import "APCMutableStringkeyString.h"

@implementation APCMultipleStringkeyString
+ (APCMultipleStringkeyString*)stringkeyStringWithProperty:(NSString*)property
                                                    getter:(NSString*)getter
                                                    setter:(NSString*)setter
{
    
    APCMultipleStringkeyString* isetter = setter ? [self stringkey] : nil;
    APCMultipleStringkeyString* igetter = getter ? [self stringkey] : nil;
    APCMultipleStringkeyString* ihead   = [self stringkey];
    
    ihead->value    =   property;
    ihead->_head    =   ihead;
    
    do {
        
        if(igetter == nil) break;
        
        ihead->next        =   igetter;
        igetter->value     =   getter;
        igetter->_head     =   ihead;
        
        if(isetter == nil) break;
        
        igetter->next     =   isetter;
        isetter->value    =   setter;
        isetter->_head    =   ihead;
    } while (0);
    
    return ihead;
}

- (instancetype)initWithStringArray:(NSArray<NSString *> *)array
{
    APCMultipleStringkeyString* previous    = nil;
    APCMultipleStringkeyString* current     = nil;
    for (NSString* item in array) {
        
        if(previous == nil){
            
            _head       = self;
            current     = self;
        }else {
            
            current = [self.class stringkeyWithString:item];
            previous->next  = current;
            previous->_head = self;
        }
        previous = current;
    }
    
    return self;
}

+ (instancetype)stringkeyStringFromArray:(NSArray<NSString *> *)array
{
    return [[self allocWithZone:NSDefaultMallocZone()] initWithStringArray:array];
}

- (APCStringkeyString *)head
{
    return _head;
}

- (NSUInteger)length
{
    APCMultipleStringkeyString* item = _head;
    NSUInteger count = 1;
    
    while (nil != (item = item->next))
        ++count;
    
    return count;
}

- (BOOL)isEqualToStringkeyString:(APCStringkeyString *)stringstring
{
    if(self == stringstring) return YES;
    
    if(self.length != stringstring.length) return NO;
    
    APCStringkeyString* selfKey = self;
    while (selfKey != nil && stringstring != nil) {
        
        if(selfKey){
            
            if(![selfKey isEqual:stringstring]) return NO;
            
            selfKey         = selfKey->next;
            stringstring    = stringstring->next;
        }
    }
    
    if(selfKey == nil && stringstring == nil) return YES;
    
    return NO;
}

- (NSArray<NSString *> *)allStrings
{
    NSMutableArray* ret = [NSMutableArray array];
    
    APCMultipleStringkeyString* item = _head;
    
    do {
        
        [ret addObject:item->value];
    } while (nil != (item = item->next));
    
    return [ret copy];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id  _Nullable [])buffer
                                    count:(NSUInteger)len
{
    unsigned long   counted = state->state;
    NSUInteger      length  = self.length;
    NSUInteger      count   = 0;
    if(counted == 0){
        
        state->mutationsPtr = (unsigned long*)(&(_head->_mutation));
        atomic_fetch_add(&_enumerating, 1);
    }else if (counted >= length) {
        
        atomic_fetch_sub(&_enumerating, 1);
        return 0;
    }
    state->itemsPtr = buffer;
    for (APCMultipleStringkeyString* item = self
         ; (counted < length) && (count < len)
         ; (count++, counted++, item = item->next) ) {
        
        buffer[count] = item;
    }
    state->state = counted;
    
    return count;
}

- (id)copyWithZone:(NSZone *)zone
{
    return
    
    [[APCMultipleStringkeyString allocWithZone:zone] initWithStringArray:self.allStrings];
}

- (void)dealloc
{
    _head = nil;
}

@end

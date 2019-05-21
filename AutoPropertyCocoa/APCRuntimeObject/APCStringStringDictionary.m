//
//  APCStringStringDictionary.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCStringStringDictionary.h"

@implementation APCStringStringDictionary
{
    NSMapTable          <APCStringkeyString*, id>*
    _manager;

    NSMutableDictionary <NSString*, id>*
    _read_data;
    
    ///Immutable type can increase reading speed by 10~20%
    NSDictionary        <NSString*, id>*
    _readonly;
    
    NSMutableArray*
    _values;
}


+ (instancetype)dictionary
{
    return [[self allocWithZone:NSDefaultMallocZone()] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _read_data  = [NSMutableDictionary dictionaryWithCapacity:31];
        _manager    = [NSMapTable strongToStrongObjectsMapTable];
        _values     = [NSMutableArray arrayWithCapacity:31];
    }
    return self;
}

- (NSUInteger)count
{
    return [_readonly count];
}

- (NSArray<NSString *> *)allKeys
{
    return [_readonly allKeys];
}

- (NSArray<NSString *> *)allKeysForObject:(id)anObject
{
    return [_readonly allKeysForObject:anObject];
}

- (NSArray *)allValues
{
    return [_values copy];
}

- (void)setObject:(id)anObject forKey:(APCStringkeyString *)mKey
{
    for (APCStringkeyString * item in mKey.head) {
        
        [_manager setObject:anObject forKey:item];
        [_read_data setObject:anObject forKey:item->value];
    }
    
    [_values addObject:anObject];
    
    _readonly = [_read_data copy];
}

- (id)objectForKey:(NSString *)aKey
{
    return [_readonly objectForKey:aKey];
}

- (void)removeObjectForKey:(NSString *)aKey
{
    APCStringkeyString* iKey;
    for (APCStringkeyString* item in _manager.keyEnumerator) {
        
        if([item isEqualToString:aKey]){
            
            iKey = item;
            break;
        }
    }
    
    if(iKey == nil) return;
    
    ///Find head key
    iKey = iKey.head;
    
    for (iKey in iKey.head) {
        
        [_manager removeObjectForKey:iKey];
        [_read_data removeObjectForKey:iKey->value];
    }
    
    [_values removeObject:[_readonly objectForKey:aKey]];
    
    _readonly = [_read_data copy];
}

- (NSEnumerator *)objectEnumerator
{
    return [_values objectEnumerator];
}

- (NSEnumerator<NSString *> *)keyEnumerator
{
    return [_readonly keyEnumerator];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [_readonly countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(NSString * _Nonnull, id _Nonnull, BOOL *))block
{
    [_readonly enumerateKeysAndObjectsUsingBlock:block];
}

- (void)removeAllObjects
{
    _readonly = nil;
    [_read_data removeAllObjects];
    [_manager removeAllObjects];
    [_values removeAllObjects];
}

- (NSString *)description
{
    return [_readonly description];
}

@end

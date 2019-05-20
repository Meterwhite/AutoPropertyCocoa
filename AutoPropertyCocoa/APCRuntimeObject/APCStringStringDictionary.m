//
//  APCStringStringDictionary.m
//  AutoPropertyCocoaMacOS
//
//  Created by MDLK on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCStringStringDictionary.h"

@implementation APCStringStringDictionary
{
    NSMapTable          <APCStringStringKey*, id>*
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

- (void)setObject:(id)anObject forKey:(APCStringStringKey *)mKey
{
    APCStringStringKey * key = mKey->head;
    
    do {
        
        [_manager setObject:anObject forKey:key];
        [_read_data setObject:anObject forKey:key->value];
    } while ((key = key->next));
    
    [_values addObject:anObject];
    
    _readonly = [_read_data copy];
}

- (id)objectForKey:(NSString *)aKey
{
    return [_readonly objectForKey:aKey];
}

- (void)removeObjectForKey:(NSString *)aKey
{
    id value = [_readonly objectForKey:aKey];
    
    if(value == nil) return;
    
    APCStringStringKey* iKey = [APCStringStringKey keyWithMatchingProperty:aKey];
    
    iKey = [_manager objectForKey:iKey];
    
    ///Find head key
    iKey = iKey->head;
    
    do {
        
        [_manager removeObjectForKey:iKey];
        [_read_data removeObjectForKey:iKey->value];
    } while ((iKey = iKey->next));
    
    [_values removeObject:value];
    
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

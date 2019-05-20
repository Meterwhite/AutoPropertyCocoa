//
//  APCStringStringDictionary.h
//  AutoPropertyCocoaMacOS
//
//  Created by MDLK on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCStringStringKey.h"

/**
 Many string to one object dictionary.
 Very insecure collection of threads, but read fast.
 */
@interface APCStringStringDictionary<ObjectType> : NSObject<NSFastEnumeration>

+ (nonnull instancetype)dictionary;

- (void)setObject:(nonnull ObjectType)anObject forKey:(nonnull APCStringStringKey*)aKey;

- (nonnull ObjectType)objectForKey:(nonnull NSString*)aKey;

- (void)removeObjectForKey:(nonnull NSString*)aKey;

- (nonnull NSEnumerator<NSString*> *)keyEnumerator;

- (void)removeAllObjects;

/**
 Uniquely traversing objects.
 */
- (nonnull NSEnumerator<ObjectType> *)objectEnumerator;

/**
 for(NSString* string_item in self) {...}
 */
- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state
                                  objects:(id  _Nullable __unsafe_unretained [_Nullable])buffer
                                    count:(NSUInteger)len;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^_Nonnull)(NSString* _Nonnull key, ObjectType _Nonnull obj, BOOL * _Nonnull stop))block;
@end


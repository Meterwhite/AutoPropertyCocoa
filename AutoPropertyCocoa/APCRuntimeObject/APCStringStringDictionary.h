//
//  APCStringStringDictionary.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCStringkeyString.h"

/**
 Many string to one object dictionary.
 Very insecure collection of threads, but read fast.
 
 Main feature :
 
 1.
 stringstring = {a0->a1->...->an}
 
 2.
 [dictionary setObject:object forKey:stringstring]
 
 =>
 
 a0 -> object
 a1 -> object
 a2 -> object
 ............
 an -> object
 b0 -> object
 b1 -> object
 
 3.
 [dictionary removeObjectForKey:a1]
 
 =>
 
 b0 -> object
 b1 -> object
 
 */
#warning change me to APCStringkeyStringDictionary
@interface APCStringStringDictionary<__covariant ObjectType> : NSObject<NSFastEnumeration>

@property (readonly) NSUInteger count;
@property (nullable,readonly,copy) NSArray<NSString*> *allKeys;
- (nullable NSArray<NSString*> *)allKeysForObject:(nonnull ObjectType)anObject;

/**
 Non-repeating mapped objects.
 */
@property (nullable,readonly,copy) NSArray<ObjectType> *allValues;

+ (nonnull instancetype)dictionary;

- (void)setObject:(nonnull ObjectType)anObject forKey:(nonnull APCStringkeyString*)aKey;

- (nonnull ObjectType)objectForKey:(nonnull NSString*)aKey;

- (void)removeObjectForKey:(nonnull NSString*)aKey;

/**
 The last two objects will be deleted at the same time
 */
- (void)removePropertyHookForKey:(nonnull NSString*)aKey;

- (nonnull NSEnumerator<NSString*> *)keyEnumerator;

- (void)removeAllObjects;


/**
 Non-repeating mapped objects.
 */
- (nonnull NSEnumerator<ObjectType> *)objectEnumerator;

/**
 For-in string keys;
 */
- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state
                                  objects:(id  _Nullable __unsafe_unretained [_Nullable])buffer
                                    count:(NSUInteger)len;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^_Nonnull)(NSString* _Nonnull key
                                                                        , ObjectType _Nonnull obj
                                                                        , BOOL * _Nonnull stop))block;
@end


//
//  APCStringkeyString.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/21.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCStringkey.h"


@interface APCStringkeyString : APCStringkey<NSFastEnumeration,NSMutableCopying>
{
@public
    __kindof APCStringkeyString* next;
}

@property (nullable,strong,readonly) APCStringkeyString* head;

@property (nonnull,readonly,strong) NSArray<NSString*> *allStrings;

@property (readonly) NSUInteger length;

+ (nonnull instancetype)stringkeyStringWithString:(nonnull NSString*)string;

+ (nonnull instancetype)stringkeyStringWithProperty:(nonnull NSString*)property
                                             getter:(nullable NSString*)getter
                                             setter:(nullable NSString*)setter;

+ (nonnull instancetype)stringkeyStringFromArray:(nonnull NSArray<NSString*>*)array;

- (nonnull instancetype)initWithStringArray:(nonnull NSArray<NSString*>*)array;

- (BOOL)isEqualToStringkeyString:(nullable APCStringkeyString*)stringstring;

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state
                                  objects:(id  _Nullable __unsafe_unretained [_Nullable])buffer
                                    count:(NSUInteger)len;

@end


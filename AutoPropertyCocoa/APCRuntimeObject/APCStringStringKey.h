//
//  APCStringStringKey.h
//  AutoPropertyCocoaMacOS
//
//  Created by MDLK on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A string of string as a key in key-value collection.
 */
@interface APCStringStringKey : NSObject
{
@public
    
    NSString*                   value;
    __weak APCStringStringKey*  head;
    APCStringStringKey*         next;
}

+ (nonnull instancetype)keyWithMatchingProperty:(nonnull NSString*)property;

+ (nonnull instancetype)keyWithProperty:(nonnull NSString*)property
                                 getter:(nullable NSString*)getter
                                 setter:(nullable NSString*)setter;

- (nonnull instancetype)initWithString:(NSString*)string;

- (BOOL)isEqual:(nonnull APCStringStringKey*)object;

- (NSUInteger)hash;
@end

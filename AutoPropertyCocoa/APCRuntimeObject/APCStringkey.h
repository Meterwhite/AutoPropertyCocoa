//
//  APCStringkey.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/21.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCStringkey : NSObject
{
@public
    
    NSString* value;
}

+ (nonnull instancetype)stringkey;

+ (nonnull instancetype)stringkeyWithString:(nonnull NSString*)string;

- (nonnull instancetype)initWithString:(nonnull NSString*)string;

- (BOOL)isEqual:(nonnull APCStringkey*)object;

- (BOOL)isEqualToString:(nullable NSString*)string;

- (NSUInteger)hash;

- (nonnull instancetype)copyKey;

@end


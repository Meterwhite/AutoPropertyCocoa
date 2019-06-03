//
//  APCMutableStringkeyString.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/21.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCMultipleStringkeyString.h"
@class APCStringkeyString;
@class APCStringkey;

@interface APCMutableStringkeyString : APCMultipleStringkeyString

- (void)appendStringkeyString:(nonnull APCStringkeyString *)aStringkeyString;

- (void)appendStringkey:(nonnull APCStringkey *)aStringkey;

- (void)appendString:(nonnull NSString *)aString;

@end


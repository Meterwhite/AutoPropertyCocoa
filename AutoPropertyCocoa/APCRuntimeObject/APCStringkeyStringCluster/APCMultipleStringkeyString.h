//
//  APCMultipleStringkeyString.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCStringkeyString.h"
#import <stdatomic.h>

/**
 A string of string as a key in key-value collection.
 */
@interface APCMultipleStringkeyString : APCStringkeyString
{
    @protected
    __weak APCMultipleStringkeyString*  _head;
    atomic_ulong                _mutation;
    atomic_ulong                _enumerating;
}

@end

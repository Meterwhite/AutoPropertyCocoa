//
//  APCMutableStringkeyString.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/21.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCMutableStringkeyString.h"

@implementation APCMutableStringkeyString

- (void)appendString:(NSString *)aString
{
    if(atomic_load(&(_head->_enumerating)) > 0){
        
        atomic_fetch_add(&(_head->_mutation), 1);
    }
    
    APCMutableStringkeyString* item = self;
    while (1){
        
        if(item->next == nil) break;
        
        item = item->next;
    }
    
    APCMutableStringkeyString* newer = [APCMutableStringkeyString stringkeyWithString:aString];
    item->next = newer;
    newer->_head = _head;
}

- (void)appendStringkey:(APCStringkey *)aStringkey
{
    [self appendString:aStringkey->value];
}

- (void)appendStringkeyString:(APCStringkeyString *)aStringkeyString
{
    APCMutableStringkeyString* item = self;
    
    do {
        
        [self appendString:item->value];
    } while (nil != (item = item->next));
}



@end

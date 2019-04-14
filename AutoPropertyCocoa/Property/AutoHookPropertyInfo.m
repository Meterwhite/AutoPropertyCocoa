//
//  AutoghookPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoHookPropertyInfo.h"

@implementation AutoHookPropertyInfo

- (void)dealloc
{
    if(self.kindOfOwner == AutoPropertyOwnerKindOfInstance){
        
        [self disposeRuntimeResource];
    }
}

- (void)disposeRuntimeResource
{
    if(nil != _proxyClass){
        
        objc_disposeClassPair(_proxyClass);
    }
}


@end

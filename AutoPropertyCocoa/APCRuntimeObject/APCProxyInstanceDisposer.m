//
//  APCProxyInstanceDisposer.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/16.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCProxyInstanceDisposer.h"
#import "APCRuntime.h"

@implementation APCProxyInstanceDisposer
{
    APCProxyClass _class;
}

- (instancetype)initWithClass:(APCProxyClass)clazz
{
    self = [super init];
    if (self) {
        
//        _class = clazz;
    }
    return self;
}

- (void)dealloc
{
    if(_class){
        
        if(YES == apc_class_conformsProxyClass(_class)){
            
//            objc_disposeClassPair(_class);
        }
    }
}

@end

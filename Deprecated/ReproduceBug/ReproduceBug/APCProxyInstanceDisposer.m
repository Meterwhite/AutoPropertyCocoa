//
//  APCProxyInstanceDisposer.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/16.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCProxyInstanceDisposer.h"
#import <objc/runtime.h>

@implementation APCProxyInstanceDisposer
{
    Class _class;
}

- (instancetype)initWithClass:(Class)clazz
{
    self = [super init];
    if (self) {
        
        _class = clazz;
    }
    return self;
}

- (void)dealloc
{
    if(_class){
        
        NSLog(@"Diposer : %@", NSStringFromClass(_class));
        objc_disposeClassPair(_class);
        
    }
}

@end

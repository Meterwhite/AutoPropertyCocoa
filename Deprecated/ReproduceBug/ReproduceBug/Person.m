//
//  Person.m
//  ReproduceBug
//
//  Created by NOVO on 2019/5/16.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

@implementation Person

- (void)dealloc
{
    if(_proxyClass){
        
//        objc_disposeClassPair(_proxyClass);
    }
}

@end

//
//  APCProxyInstanceDisposer.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/16.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
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
        _class = clazz;
    }
    return self;
}

- (void)dealloc
{
    APCDlog(@"Enter Disposer << dealoc: %@", NSStringFromClass(_class));
    if(_class != nil){
        if(apc_class_conformsProxyClass(_class)){
            APCDlog(@"Disposer << dealoc << objc_disposeClassPair : %@", NSStringFromClass(_class));
            objc_disposeClassPair(_class);
            _class = nil;
        }
    }
}

- (NSString *)description
{
    if(_class == nil) return @"NULL";
    
    return @(class_getName(_class));
}

- (NSUInteger)hash
{
    return [_class hash];
}

- (BOOL)isEqual:(id)object
{
    if(self == object) return YES;
    return [self hash] == [object hash];
}

@end

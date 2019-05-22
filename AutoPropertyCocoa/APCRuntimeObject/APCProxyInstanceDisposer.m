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

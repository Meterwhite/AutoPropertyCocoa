//
//  APCProxyInstanceResource.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/16.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCProxyInstanceResource.h"
#import "APCRuntime.h"

@implementation APCProxyInstanceResource
{
    APCProxyClass _class;
}

- (instancetype)initWithClass:(APCProxyClass)clazz
{
    self = [super init];
    if (self) {
        
        pthread_rwlock_init(&instanceLock, NULL);
        _class = clazz;
    }
    return self;
}

- (void)dealloc
{
    
    pthread_rwlock_destroy(&instanceLock);
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

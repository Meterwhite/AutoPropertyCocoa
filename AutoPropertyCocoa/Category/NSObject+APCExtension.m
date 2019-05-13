//
//  NSObject+APCExtension.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/3.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+APCExtension.h"
#import "APCRuntime.h"
#import "APCScope.h"

@implementation NSObject(APCExtension)

- (nonnull Class)apc_originalClass
{
    if(apc_object_isProxyInstance(self)){
        
        return apc_class_unproxyClass([self class]);
    }
    
    return [self class];
}

- (void)apc_performUserSuperAsVoid
{
    
}

- (void)apc_performUserSuperAsVoidWithObject:(id)object
{
    
}

- (BOOL)apc_performUserSuperAsBOOLWithObject:(id)object
{
    return NO;
}

- (nullable id)apc_performUserSuperAsId
{
    return nil;
}
@end

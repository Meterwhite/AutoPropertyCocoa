//
//  NSObject+APCExtension.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/3.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "NSObject+APCExtension.h"
#import "APCRuntime.h"
#import "APCScope.h"

@implementation NSObject(APCExtension)

- (BOOL)apc_isKindOfClass:(Class)cls
{
    return [[self apc_originalClass] isSubclassOfClass:cls];
}

- (nonnull Class)apc_originalClass
{
    if(apc_object_isProxyInstance(self)){
        
        return apc_class_unproxyClass(object_getClass(self));
    }
    
    return object_getClass(self);
}

- (void)apc_instanceUnbind
{
    if(apc_object_isProxyInstance(self)){
        
        apc_instance_unhookFromProxyClass(self);
    }
}

+ (void)apc_classUnbind
{
    apc_class_unhook(self);
}

- (BOOL)apc_performUserSuperAsBOOLWithObject:(id)object{return NO;}
- (void)apc_performUserSuperAsVoidWithObject:(id)object{}
- (nullable id)apc_performUserSuperAsId{return nil;}
- (void)apc_performUserSuperAsVoid{}
@end

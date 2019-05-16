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

- (void)apc_instanceUnbind
{
    if(YES == apc_object_isProxyInstance(self)){
        
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

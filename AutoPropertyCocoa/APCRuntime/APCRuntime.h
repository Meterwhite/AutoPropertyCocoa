//
//  APCRuntime.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCHookProperty.h"

#pragma mark - For class

OBJC_EXPORT NSArray<__kindof APCHookProperty*>* _Nonnull
apc_classBoundProperties(Class _Nonnull cls, NSString* _Nonnull property);

OBJC_EXPORT APCHookProperty* _Nullable
apc_property_getSuperProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT NSArray<__kindof APCHookProperty*>* _Nullable
apc_property_getSuperPropertyList(APCHookProperty* _Nonnull p);

OBJC_EXPORT void
apc_registerProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT void
apc_disposeProperty(APCHookProperty* _Nonnull p);




#pragma mark - For instance

OBJC_EXPORT NSArray<__kindof APCHookProperty*>* _Nonnull
apc_instanceBoundPropertyies(id _Nonnull instance, NSString* _Nonnull property);

OBJC_EXPORT APCHookProperty* _Nullable
apc_instanceProperty_getSuperProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT NSArray<__kindof APCHookProperty*>* _Nullable
apc_instanceProperty_getSuperPropertyList(APCHookProperty* _Nonnull p);

OBJC_EXPORT void
apc_instanceSetAssociatedProperty(id _Nonnull instance, APCHookProperty* _Nonnull p);

OBJC_EXPORT void
apc_instanceRemoveAssociatedProperty(id _Nonnull instance, APCHookProperty* _Nonnull p);

//OBJC_EXPORT BOOL
//apc_instanceContainsValidProperty(id _Nonnull instance);

#warning proxyClass

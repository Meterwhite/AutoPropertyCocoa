//
//  APCRuntime.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCHookProperty.h"


OBJC_EXPORT APCHookProperty* _Nullable
apc_property_getSuperProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT NSArray<__kindof APCHookProperty*>* _Nullable
apc_property_getSuperPropertyList(APCHookProperty* _Nonnull p);

//OBJC_EXPORT APCHookProperty* _Nullable
//apc_property_nextBoundProperty(APCHookProperty* _Nullable p);

OBJC_EXPORT NSArray<__kindof APCHookProperty*>* _Nonnull
apc_classBoundProperties(Class _Nonnull cls, NSString* _Nonnull property);

//OBJC_EXPORT void
//apc_property_isRegistered(APCHookProperty* _Nullable p);

OBJC_EXPORT void
apc_addProperty(APCHookProperty* _Nonnull p);


OBJC_EXPORT void
apc_removeProperty(APCHookProperty* _Nonnull p);

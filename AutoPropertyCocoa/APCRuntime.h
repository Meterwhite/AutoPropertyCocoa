//
//  APCRuntime.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/15.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCHookProperty.h"
#include <pthread.h>
#import "APCScope.h"

#pragma mark - Hook
FOUNDATION_EXPORT void
apc_unhook_all(void);

FOUNDATION_EXPORT void
apc_unhook_allClass(void);

FOUNDATION_EXPORT void
apc_unhook_allInstance(void);

FOUNDATION_EXPORT APCPropertyHook*  _Nullable
apc_lookup_propertyhook(Class  _Nullable cls
                        , NSString* _Nonnull property);

FOUNDATION_EXPORT APCPropertyHook*  _Nullable
apc_getPropertyhook(Class  _Nullable cls
                    , NSString* _Nonnull property);

/** The second parameter 'to' is include. */
FOUNDATION_EXPORT APCPropertyHook* _Nullable
apc_lookup_superPropertyhook_inRange(Class _Nonnull from
                                     , Class _Nonnull to
                                     , NSString* _Nonnull property);

/** The second parameter 'to' is include. */
FOUNDATION_EXPORT APCPropertyHook* _Nullable
apc_lookup_sourcePropertyhook_inRange(Class _Nonnull from
                                      , Class _Nonnull to
                                      , NSString* _Nonnull property);

FOUNDATION_EXPORT APCPropertyHook* _Nullable
apc_lookup_instancePropertyhook(APCProxyInstance* _Nonnull instance
                                , NSString* _Nonnull property);

FOUNDATION_EXPORT APCPropertyHook* _Nullable
apc_propertyhook_rootHook(APCPropertyHook* _Nonnull hook);

FOUNDATION_EXPORT __kindof APCHookProperty* _Nullable
apc_propertyhook_lookupSuperProperty(APCPropertyHook* _Nonnull hook, const char* _Nonnull ivar);

#pragma mark - Property

FOUNDATION_EXPORT __kindof APCHookProperty* _Nullable
apc_property_getSuperProperty(APCHookProperty* _Nonnull p);

#pragma mark - Class

FOUNDATION_EXPORT void
apc_registerProperty(APCHookProperty* _Nonnull p);

FOUNDATION_EXPORT void
apc_disposeProperty(APCHookProperty* _Nonnull p);

/**
 @param cls A Class only in APC inheritance.
 */
FOUNDATION_EXPORT Class _Nullable
apc_class_getSuperclass(Class _Nonnull cls);

FOUNDATION_EXPORT void
apc_class_unhook(Class _Nonnull cls);

#pragma mark - Instance

FOUNDATION_EXPORT void
apc_instance_setAssociatedProperty(APCProxyInstance* _Nonnull instance
                                   , APCHookProperty* _Nonnull p);

FOUNDATION_EXPORT void
apc_instance_removeAssociatedProperty(APCProxyInstance* _Nonnull instance
                                      , APCHookProperty* _Nonnull p);

#pragma mark - Instance / Proxy class

FOUNDATION_EXPORT BOOL
apc_class_conformsProxyClass(Class _Nonnull cls);

FOUNDATION_EXPORT Class _Nullable
apc_class_unproxyClass(APCProxyClass _Nonnull cls);

FOUNDATION_EXPORT Class _Nullable
apc_object_unproxyClass(id _Nonnull object);

FOUNDATION_EXPORT APCProxyClass _Nullable
apc_instance_getProxyClass(APCProxyInstance* _Nonnull instance);

FOUNDATION_EXPORT APCProxyClass _Nonnull
apc_object_hookWithProxyClass(id _Nonnull instance);

FOUNDATION_EXPORT void
apc_instance_unhookFromProxyClass(APCProxyInstance* _Nonnull instance);

FOUNDATION_EXPORT BOOL
apc_object_isProxyInstance(id _Nonnull object);

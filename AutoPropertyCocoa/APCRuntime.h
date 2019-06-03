//
//  APCRuntime.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCHookProperty.h"
#include <pthread.h>
#import "APCScope.h"

#pragma mark - Hook
OBJC_EXPORT void
apc_unhook_all(void);

OBJC_EXPORT void
apc_unhook_allClass(void);

OBJC_EXPORT void
apc_unhook_allInstance(void);

OBJC_EXPORT APCPropertyHook*  _Nullable
apc_lookup_propertyhook(Class  _Nullable cls
                        , NSString* _Nonnull property);

OBJC_EXPORT APCPropertyHook*  _Nullable
apc_getPropertyhook(Class  _Nullable cls
                    , NSString* _Nonnull property);

/** The second parameter 'to' is include. */
OBJC_EXPORT APCPropertyHook* _Nullable
apc_lookup_superPropertyhook_inRange(Class _Nonnull from
                                     , Class _Nonnull to
                                     , NSString* _Nonnull property);

/** The second parameter 'to' is include. */
OBJC_EXPORT APCPropertyHook* _Nullable
apc_lookup_sourcePropertyhook_inRange(Class _Nonnull from
                                      , Class _Nonnull to
                                      , NSString* _Nonnull property);

OBJC_EXPORT APCPropertyHook* _Nullable
apc_lookup_instancePropertyhook(APCProxyInstance* _Nonnull instance
                                , NSString* _Nonnull property);

OBJC_EXPORT APCPropertyHook* _Nullable
apc_propertyhook_rootHook(APCPropertyHook* _Nonnull hook);

OBJC_EXPORT __kindof APCHookProperty* _Nullable
apc_propertyhook_lookupSuperProperty(APCPropertyHook* _Nonnull hook, const char* _Nonnull ivar);

#pragma mark - Property

OBJC_EXPORT __kindof APCHookProperty* _Nullable
apc_property_getSuperProperty(APCHookProperty* _Nonnull p);

#pragma mark - Class

OBJC_EXPORT void
apc_registerProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT void
apc_disposeProperty(APCHookProperty* _Nonnull p);

/**
 @param cls A Class only in APC inheritance.
 */
OBJC_EXPORT Class _Nullable
apc_class_getSuperclass(Class _Nonnull cls);

OBJC_EXPORT void
apc_class_unhook(Class _Nonnull cls);

#pragma mark - Instance

OBJC_EXPORT void
apc_instance_setAssociatedProperty(APCProxyInstance* _Nonnull instance
                                   , APCHookProperty* _Nonnull p);

OBJC_EXPORT void
apc_instance_removeAssociatedProperty(APCProxyInstance* _Nonnull instance
                                      , APCHookProperty* _Nonnull p);

#pragma mark - Instance / Proxy class

OBJC_EXPORT BOOL
apc_class_conformsProxyClass(Class _Nonnull cls);

OBJC_EXPORT Class _Nullable
apc_class_unproxyClass(APCProxyClass _Nonnull cls);

OBJC_EXPORT Class _Nullable
apc_object_unproxyClass(id _Nonnull object);

OBJC_EXPORT APCProxyClass _Nullable
apc_instance_getProxyClass(APCProxyInstance* _Nonnull instance);

OBJC_EXPORT APCProxyClass _Nonnull
apc_object_hookWithProxyClass(id _Nonnull instance);

OBJC_EXPORT void
apc_instance_unhookFromProxyClass(APCProxyInstance* _Nonnull instance);

OBJC_EXPORT BOOL
apc_object_isProxyInstance(id _Nonnull object);

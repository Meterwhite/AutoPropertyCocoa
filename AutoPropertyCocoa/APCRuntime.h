//
//  APCRuntime.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCHookProperty.h"
#include <pthread.h>
#import "APCScope.h"

/**
 @apc_lockruntime_writing({
 
    //Unable to break points...
 });
 */
#define apc_lockruntime_writing(...)\
\
submacro_apc_keywordify \
\
apc_runtimelock_writing(^()__VA_ARGS__)

/**
 @apc_lockruntime_reading({
 
    //Unable to break points...
 });
 */
#define apc_lockruntime_reading(...)\
\
submacro_apc_keywordify \
\
apc_runtimelock_reading(^()__VA_ARGS__)


#pragma mark - For runtime lock

OBJC_EXTERN pthread_rwlock_t apc_runtimelock;

OBJC_EXPORT void
apc_runtimelock_writing(void(NS_NOESCAPE^ _Nonnull block)(void));

OBJC_EXPORT void
apc_runtimelock_reading(void(NS_NOESCAPE^ _Nonnull block)(void));

#pragma mark - For hook
OBJC_EXPORT void
apc_unhook_all(void);

OBJC_EXPORT void
apc_unhook_allClass(void);

OBJC_EXPORT void
apc_unhook_allInstance(void);

OBJC_EXPORT APCPropertyHook*  _Nullable
apc_lookups_propertyhook(Class  _Nullable cls
                        , NSString* _Nonnull property);

OBJC_EXPORT APCPropertyHook*  _Nullable
apc_lookup_propertyhook(Class  _Nullable cls
                        , NSString* _Nonnull property);

/** The second parameter 'to' is include. */
OBJC_EXPORT APCPropertyHook* _Nullable
apc_lookup_superPropertyhook_inRange(Class _Nonnull from
                                     , Class _Nonnull to
                                     , NSString* _Nonnull property);

/** The second parameter 'to' is include. */
OBJC_EXPORT APCPropertyHook* _Nullable
apc_lookup_implementationPropertyhook_inRange(Class _Nonnull from
                                              , Class _Nonnull to
                                              , NSString* _Nonnull property);

OBJC_EXPORT APCPropertyHook* _Nullable
apc_lookup_instancePropertyhook(APCProxyInstance* _Nonnull instance
                                , NSString* _Nonnull property);

OBJC_EXPORT APCPropertyHook* _Nullable
apc_propertyhook_rootHook(APCPropertyHook* _Nonnull hook);

OBJC_EXPORT void
apc_propertyhook_dispose_nolock(APCPropertyHook* _Nonnull hook);

#pragma mark - For property

OBJC_EXPORT __kindof APCHookProperty* _Nullable
apc_property_getSuperProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT NSArray<__kindof APCHookProperty*>* _Nullable
apc_property_getSuperPropertyList(APCHookProperty* _Nonnull p);

#pragma mark - For class

OBJC_EXPORT void
apc_registerProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT Class _Nullable
apc_class_getSuperclass(Class _Nonnull cls);

#pragma mark - For instance

OBJC_EXPORT void
apc_instance_setAssociatedProperty(APCProxyInstance* _Nonnull instance
                                   , APCHookProperty* _Nonnull p);

OBJC_EXPORT void
apc_instance_removeAssociatedProperty(APCProxyInstance* _Nonnull instance
                                      , APCHookProperty* _Nonnull p);

#pragma mark - Proxy class(For instance)

OBJC_EXPORT BOOL
apc_class_conformsProxyClass(Class _Nonnull cls);

OBJC_EXPORT void
apc_class_disposeProxyClass(APCProxyClass _Nonnull cls);

OBJC_EXPORT Class _Nullable
apc_class_unproxyClass(APCProxyClass _Nonnull cls);

OBJC_EXPORT APCProxyClass _Nullable
apc_instance_getProxyClass(APCProxyInstance* _Nonnull instance);

OBJC_EXPORT APCProxyClass _Nonnull
apc_object_hookWithProxyClass(id _Nonnull instance);

OBJC_EXPORT APCProxyClass _Nullable
apc_instance_unhookFromProxyClass(APCProxyInstance* _Nonnull instance);

OBJC_EXPORT BOOL
apc_object_isProxyInstance(id _Nonnull instance);

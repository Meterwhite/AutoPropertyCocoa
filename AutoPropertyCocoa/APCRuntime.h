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

OBJC_EXPORT __kindof APCHookProperty* _Nullable
apc_lookup_property(Class _Nonnull cls
                    , NSString* _Nonnull property
                    , SEL _Nonnull outlet);

OBJC_EXPORT __kindof APCHookProperty* _Nullable
apc_lookup_instanceProperty(APCProxyInstance* _Nonnull instance
                            , NSString* _Nonnull property
                            , SEL _Nonnull outlet);

OBJC_EXPORT APCPropertyHook* _Nullable
apc_propertyhook_rootHook(APCPropertyHook* _Nonnull hook);

OBJC_EXPORT void
apc_propertyhook_dispose_nolock(APCPropertyHook* _Nonnull hook);

__kindof APCHookProperty* _Nullable
apc_propertyhook_lookupSuperProperty(APCPropertyHook* _Nonnull hook, const char* _Nonnull ivar);

#pragma mark - For property

OBJC_EXPORT __kindof APCHookProperty* _Nullable
apc_property_getSuperProperty(APCHookProperty* _Nonnull p);

#pragma mark - For class

OBJC_EXPORT void
apc_registerProperty(APCHookProperty* _Nonnull p);

OBJC_EXPORT Class _Nullable
apc_class_getSuperclass(Class _Nonnull cls);

OBJC_EXPORT void
apc_class_unhook(Class _Nonnull cls);

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

OBJC_EXPORT Class _Nullable
apc_class_unproxyClass(APCProxyClass _Nonnull cls);

OBJC_EXPORT Class _Nullable
apc_object_unproxyClass(id _Nonnull obj);

OBJC_EXPORT APCProxyClass _Nullable
apc_instance_getProxyClass(APCProxyInstance* _Nonnull instance);

OBJC_EXPORT APCProxyClass _Nonnull
apc_object_hookWithProxyClass(id _Nonnull instance);

/**
 Unlike the object that is auto released,the 'ProxyClass' will be dispose immediately.
 */
OBJC_EXPORT void
apc_instance_unhookFromProxyClass(APCProxyInstance* _Nonnull instance);

OBJC_EXPORT BOOL
apc_object_isProxyInstance(id _Nonnull instance);

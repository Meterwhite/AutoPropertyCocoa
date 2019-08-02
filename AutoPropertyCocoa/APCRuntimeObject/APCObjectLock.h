//
//  APCObjectLock.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/30.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <pthread.h>


#pragma mark - safe instance

/**
 Instance are asynchronously bound, asynchronously unbound, and when accessing properties asynchronously.
 */
FOUNDATION_EXPORT void
apc_safe_instance(id _Nullable object
                  , void(NS_NOESCAPE^ _Nullable block)(id _Nullable object));

#pragma mark - read-writte lock

FOUNDATION_EXPORT pthread_rwlock_t* _Nullable
apc_object_get_rwlock(id _Nullable object);

FOUNDATION_EXPORT void
apc_object_rdlock(id _Nullable object
                  , void(NS_NOESCAPE^ _Nullable block)(void));

FOUNDATION_EXPORT void
apc_object_wrlock(id _Nullable object
                  , void(NS_NOESCAPE^ _Nullable block)(void));

#pragma mark - object lock

FOUNDATION_EXPORT NSLock* _Nullable
apc_object_get_lock(id _Nullable object);

FOUNDATION_EXPORT void
apc_object_objlock(id _Nullable object
                   , void(NS_NOESCAPE^ _Nullable block)(void));

//
//  NSObject+APCTriggerTransaction.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/1.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCUserEnvironmentSupportObject.h"
#import "APCScope.h"

@interface NSObject (APCTriggerProperty)


#pragma mark - Instance
#pragma mark - Getter

/**
 Bind a hook that triggers the call before the Getter method call.
 */
- (void)apc_willGet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;

- (void)apc_unbindWillGet:(NSString* _Nonnull)property;

/** Bind a hook that triggers a call after a Getter method call. */
- (void)apc_didGet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindDidGet:(nonnull NSString*)property;

/** Bind a hook that triggers a call when the user condition is met. */
- (void)apc_get:(nonnull NSString*)property bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindGetterUserCondition:(NSString* _Nonnull)property;

/** Bind a hook that triggers a call when matching the number of accesses */
- (void)apc_get:(nonnull NSString*)property bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindGetterAccessCountCondition:(NSString* _Nonnull)property;



#pragma mark - Setter
- (void)apc_willSet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;

- (void)apc_unbindWillSet:(nonnull NSString*)property;


- (void)apc_didSet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindDidSet:(nonnull NSString*)property;

- (void)apc_set:(nonnull NSString*)property bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindSetterUserCondition:(nonnull NSString*)property;


- (void)apc_set:(nonnull NSString*)property bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindSetterAccessCountCondition:(nonnull NSString*)property;

#pragma mark - Class
#pragma mark - Getter
+ (void)apc_willGet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindWillGet:(nonnull NSString*)property;

+ (void)apc_didGet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindDidGet:(nonnull NSString*)property;


+ (void)apc_get:(nonnull NSString*)property bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindGetterUserCondition:(NSString* _Nonnull)property;

+ (void)apc_get:(nonnull NSString*)property bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindGetterAccessCountCondition:(NSString* _Nonnull)property;



#pragma mark - Setter
+ (void)apc_willSet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindWillSet:(NSString* _Nonnull)property;

+ (void)apc_didSet:(nonnull NSString*)property bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindDidSet:(nonnull NSString*)property;


+ (void)apc_set:(nonnull NSString*)property bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindSetterUserCondition:(NSString* _Nonnull)property;


+ (void)apc_set:(nonnull NSString*)property bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindSetterAccessCountCondition:(nonnull NSString*)property;

@end

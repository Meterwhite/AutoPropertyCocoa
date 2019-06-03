//
//  NSObject+APCTriggerProperty.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCTriggerGetterProperty.h"
#import "APCScope.h"

@interface NSObject (APCTriggerProperty)


#pragma mark - Instance
#pragma mark - Getter

/**
 Bind a hook that triggers the call before the Getter method call.
 */
- (void)apc_frontOfPropertyGetter:(nonnull NSString*)property
                    bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;

- (void)apc_unbindFrontOfPropertyGetter:(NSString* _Nonnull)property;

/** Bind a hook that triggers a call after a Getter method call. */
- (void)apc_backOfPropertyGetter:(nonnull NSString*)property
                   bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindBackOfPropertyGetter:(nonnull NSString*)property;

/** Bind a hook that triggers a call when the user condition is met. */
- (void)apc_propertyGetter:(nonnull NSString*)property
         bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindUserConditionOfPropertyGetter:(NSString* _Nonnull)property;

/** Bind a hook that triggers a call when matching the number of accesses */
- (void)apc_propertyGetter:(nonnull NSString*)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindAccessCountConditionOfPropertyGetter:(NSString* _Nonnull)property;



#pragma mark - Setter
- (void)apc_frontOfPropertySetter:(nonnull NSString*)property
                    bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;

- (void)apc_unbindFrontOfPropertySetter:(nonnull NSString*)property;


- (void)apc_backOfPropertySetter:(nonnull NSString*)property
                   bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindBackOfPropertySetter:(nonnull NSString*)property;


- (void)apc_propertySetter:(nonnull NSString*)property
         bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindUserConditionOfPropertySetter:(nonnull NSString*)property;


- (void)apc_propertySetter:(nonnull NSString*)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;

- (void)apc_unbindAccessCountConditionOfPropertySetter:(nonnull NSString*)property;

#pragma mark - Class
#pragma mark - Getter
+ (void)apc_frontOfPropertyGetter:(nonnull NSString*)property
                    bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindFrontOfPropertyGetter:(nonnull NSString*)property;


+ (void)apc_backOfPropertyGetter:(nonnull NSString*)property
                   bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindBackOfPropertyGetter:(nonnull NSString*)property;


+ (void)apc_propertyGetter:(nonnull NSString*)property
         bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindUserConditionOfPropertyGetter:(NSString* _Nonnull)property;


+ (void)apc_propertyGetter:(nonnull NSString*)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindAccessCountConditionOfPropertyGetter:(NSString* _Nonnull)property;



#pragma mark - Setter
+ (void)apc_frontOfPropertySetter:(nonnull NSString*)property
                    bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindFrontOfPropertySetter:(NSString* _Nonnull)property;


+ (void)apc_backOfPropertySetter:(nonnull NSString*)property
                   bindWithBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindBackOfPropertySetter:(nonnull NSString*)property;


+ (void)apc_propertySetter:(nonnull NSString*)property
         bindUserCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindUserConditionOfPropertySetter:(NSString* _Nonnull)property;


+ (void)apc_propertySetter:(nonnull NSString*)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id_apc_t _Nonnull instance,id _Nullable value))block;
/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindAccessCountConditionOfPropertySetter:(nonnull NSString*)property;

@end

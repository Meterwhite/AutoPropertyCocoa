//
//  NSObject+APCTriggerProperty.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassPropertyMapperController.h"
#import "AutoTriggerPropertyInfo.h"
#import "APCScope.h"

@interface NSObject (APCTriggerProperty)

#pragma mark - Class

+ (void)apc_unbindTriggerAllProperties;

#pragma mark - Getter
+ (void)apc_frontOfPropertyGetter:(NSString* _Nonnull)property
                    bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance))block;
+ (void)apc_unbindFrontOfPropertyGetter:(NSString* _Nonnull)property;


+ (void)apc_backOfPropertyGetter:(NSString* _Nonnull)property
                   bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
+ (void)apc_unbindBackOfPropertyGetter:(NSString* _Nonnull)property;


+ (void)apc_propertyGetter:(NSString* _Nonnull)property
         bindUserCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
+ (void)apc_unbindUserConditionOfPropertyGetter:(NSString* _Nonnull)property;


+ (void)apc_propertyGetter:(NSString* _Nonnull)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
+ (void)apc_unbindAccessCountConditionOfPropertyGetter:(NSString* _Nonnull)property;



#pragma mark - Setter
+ (void)apc_frontOfPropertySetter:(NSString* _Nonnull)property
                    bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance))block;
+ (void)apc_unbindFrontOfPropertySetter:(NSString* _Nonnull)property;


+ (void)apc_backOfPropertySetter:(NSString* _Nonnull)property
                   bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
+ (void)apc_unbindBackOfPropertySetter:(NSString* _Nonnull)property;


+ (void)apc_propertySetter:(NSString* _Nonnull)property
         bindUserCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
+ (void)apc_unbindUserConditionOfPropertySetter:(NSString* _Nonnull)property;


+ (void)apc_propertySetter:(NSString* _Nonnull)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
+ (void)apc_unbindAccessCountConditionOfPropertySetter:(NSString* _Nonnull)property;

#pragma mark - Instance
- (void)apc_unbindTriggerAllProperties;
#pragma mark - Getter
- (void)apc_frontOfPropertyGetter:(NSString* _Nonnull)property
                    bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance))block;
- (void)apc_unbindFrontOfPropertyGetter:(NSString* _Nonnull)property;


- (void)apc_backOfPropertyGetter:(NSString* _Nonnull)property
                   bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)apc_unbindBackOfPropertyGetter:(NSString* _Nonnull)property;


- (void)apc_propertyGetter:(NSString* _Nonnull)property
         bindUserCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)apc_unbindUserConditionOfPropertyGetter:(NSString* _Nonnull)property;


- (void)apc_propertyGetter:(NSString* _Nonnull)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)apc_unbindAccessCountConditionOfPropertyGetter:(NSString* _Nonnull)property;



#pragma mark - Setter
- (void)apc_frontOfPropertySetter:(NSString* _Nonnull)property
                    bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance))block;
- (void)apc_unbindFrontOfPropertySetter:(NSString* _Nonnull)property;


- (void)apc_backOfPropertySetter:(NSString* _Nonnull)property
                   bindWithBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)apc_unbindBackOfPropertySetter:(NSString* _Nonnull)property;


- (void)apc_propertySetter:(NSString* _Nonnull)property
         bindUserCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)apc_unbindUserConditionOfPropertySetter:(NSString* _Nonnull)property;


- (void)apc_propertySetter:(NSString* _Nonnull)property
  bindAccessCountCondition:(BOOL(^ _Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))condition
                 withBlock:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)apc_unbindAccessCountConditionOfPropertySetter:(NSString* _Nonnull)property;
@end

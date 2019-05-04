//
//  NSObject+APCTriggerProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+APCTriggerProperty.h"
#import "APCTriggerGetterProperty.h"
#import "APCTriggerSetterProperty.h"

@implementation NSObject (APCTriggerProperty)

+ (void)apc_unbindTriggerAllProperties
{
//    [APCTriggerGetterProperty unhookClassAllProperties:self];
}

#pragma mark - Class
+ (void)apc_frontOfPropertyGetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterFrontTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindFrontOfPropertyGetter:(NSString*)property
{
//    APCTriggerGetterProperty* p = [APCTriggerGetterProperty cachedTargetClass:self property:property];
//    [p getterUnbindFrontTrigger];
}

+ (void)apc_backOfPropertyGetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterPostTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindBackOfPropertyGetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCTriggerGetterProperty cachedTargetClass:self property:property];
//    [p getterUnbindPostTrigger];
}

+ (void)apc_propertyGetter:(NSString *)property bindUserCondition:(BOOL (^)(id _Nonnull, id _Nullable))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterUserTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindUserConditionOfPropertyGetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCTriggerGetterProperty cachedTargetClass:self property:property];
//    [p getterUnbindUserTrigger];
}

+ (void)apc_propertyGetter:(NSString *)property bindAccessCountCondition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterCountTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindAccessCountConditionOfPropertyGetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCTriggerGetterProperty cachedTargetClass:self property:property];
//    [p getterUnbindCountTrigger];
}

+ (void)apc_frontOfPropertySetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterFrontTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindFrontOfPropertySetter:(NSString*)property
{
//    APCTriggerSetterProperty* p = [APCTriggerSetterProperty cachedTargetClass:self property:property];
//    [p setterUnbindFrontTrigger];
}

+ (void)apc_backOfPropertySetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterPostTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindBackOfPropertySetter:(NSString *)property
{
//    APCTriggerSetterProperty* p = [APCTriggerSetterProperty cachedTargetClass:self property:property];
//    [p setterUnbindPostTrigger];
}

+ (void)apc_propertySetter:(NSString *)property bindUserCondition:(BOOL (^)(id _Nonnull, id _Nullable))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterUserTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindUserConditionOfPropertySetter:(NSString *)property
{
//    APCTriggerSetterProperty* p = [APCTriggerSetterProperty cachedTargetClass:self property:property];
//    [p setterUnbindUserTrigger];
}

+ (void)apc_propertySetter:(NSString *)property bindAccessCountCondition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterCountTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindAccessCountConditionOfPropertySetter:(NSString *)property
{
//    APCTriggerSetterProperty* p = [APCTriggerSetterProperty cachedTargetClass:self property:property];
//    [p setterUnbindCountTrigger];
}


+ (void)apc_classSetTriggerProperty:(NSString*)propertyName
                             option:(APCPropertyTriggerOption)option
                          condition:(id)condition
                              block:(id)block
{
    if(option == APCPropertyNonTrigger) return;
    
#warning get it
    APCTriggerGetterProperty* propertyInfo;
    
    if(propertyInfo == nil){
        
        propertyInfo = [APCTriggerGetterProperty instanceWithProperty:propertyName
                                                              aClass:self];
    }
    
    if(((option & APCPropertyTriggerOfGetter)
        && (NO  == (propertyInfo.accessOption & APCPropertyGetValueEnable)))
       
       ||
       
       ((option & APCPropertyTriggerOfGetter)
        && (NO  == (propertyInfo.accessOption & APCPropertySetValueEnable)))){
        
           NSAssert(NO, @"APC: Do not have getter or setter.");
    }
    
    
    if(option & APCPropertyGetterFrontTrigger){
        [propertyInfo getterBindFrontTrigger:block];
    }
    if (option & APCPropertyGetterPostTrigger){
        [propertyInfo getterBindPostTrigger:block];
    }
    if (option & APCPropertyGetterUserTrigger){
        [propertyInfo getterBindUserTrigger:block condition:condition];
    }
    if (option & APCPropertyGetterCountTrigger){
        [propertyInfo getterBindCountTrigger:block condition:condition];
    }
    
//    if(option & APCPropertySetterFrontTrigger){
//        [propertyInfo setterBindFrontTrigger:block];
//    }
//    if (option & APCPropertySetterPostTrigger){
//        [propertyInfo setterBindPostTrigger:block];
//    }
//    if (option & APCPropertySetterUserTrigger){
//        [propertyInfo setterBindUserTrigger:block condition:condition];
//    }
//    if (option & APCPropertySetterCountTrigger){
//        [propertyInfo setterBindCountTrigger:block condition:condition];
//    }
    
    [propertyInfo associatedHook];
}

#pragma mark - Instance

- (void)apc_frontOfPropertyGetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterFrontTrigger
                            condition:nil
                                block:block];
}

- (void)apc_unbindFrontOfPropertyGetter:(NSString*)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p getterUnbindFrontTrigger];
}

- (void)apc_backOfPropertyGetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterPostTrigger
                            condition:nil
                                block:block];
}

- (void)apc_unbindBackOfPropertyGetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p getterUnbindPostTrigger];
}

- (void)apc_propertyGetter:(NSString *)property bindUserCondition:(BOOL (^)(id _Nonnull, id _Nullable))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterUserTrigger
                            condition:condition
                                block:block];
}

- (void)apc_unbindUserConditionOfPropertyGetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p getterUnbindUserTrigger];
}

- (void)apc_propertyGetter:(NSString *)property bindAccessCountCondition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertyGetterCountTrigger
                            condition:condition
                                block:block];
}

- (void)apc_unbindAccessCountConditionOfPropertyGetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p getterUnbindCountTrigger];
}

- (void)apc_frontOfPropertySetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterFrontTrigger
                            condition:nil
                                block:block];
}

- (void)apc_unbindFrontOfPropertySetter:(NSString*)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p setterUnbindFrontTrigger];
}

- (void)apc_backOfPropertySetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterPostTrigger
                            condition:nil
                                block:block];
}

- (void)apc_unbindBackOfPropertySetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p setterUnbindPostTrigger];
}

- (void)apc_propertySetter:(NSString *)property bindUserCondition:(BOOL (^)(id _Nonnull, id _Nullable))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterUserTrigger
                            condition:condition
                                block:block];
}

- (void)apc_unbindUserConditionOfPropertySetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p setterUnbindUserTrigger];
}

- (void)apc_propertySetter:(NSString *)property bindAccessCountCondition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:APCPropertySetterCountTrigger
                            condition:condition
                                block:block];
}

- (void)apc_unbindAccessCountConditionOfPropertySetter:(NSString *)property
{
//    APCTriggerGetterProperty* p = [APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property];
//    [p setterUnbindCountTrigger];
}

- (void)apc_classSetTriggerProperty:(NSString*)propertyName
                             option:(APCPropertyTriggerOption)option
                          condition:(id)condition
                              block:(id)block
{
    if(option == APCPropertyNonTrigger) return;
#warning <#message#>
    APCTriggerGetterProperty* propertyInfo;
    
    if(propertyInfo == nil){
        
        propertyInfo = [APCTriggerGetterProperty instanceWithProperty:propertyName
                                                           aInstance:self];
    }
    
    if(((option & APCPropertyTriggerOfGetter)
        && (NO  == (propertyInfo.accessOption & APCPropertyGetValueEnable)))
       
       ||
       
       ((option & APCPropertyTriggerOfGetter)
        && (NO  == (propertyInfo.accessOption & APCPropertySetValueEnable)))){
           
           NSAssert(NO, @"APC: Do not have getter or setter.");
       }
    
    
    if(option & APCPropertyGetterFrontTrigger){
        [propertyInfo getterBindFrontTrigger:block];
    }
    if (option & APCPropertyGetterPostTrigger){
        [propertyInfo getterBindPostTrigger:block];
    }
    if (option & APCPropertyGetterUserTrigger){
        [propertyInfo getterBindUserTrigger:block condition:condition];
    }
    if (option & APCPropertyGetterCountTrigger){
        [propertyInfo getterBindCountTrigger:block condition:condition];
    }
    
//    if(option & APCPropertySetterFrontTrigger){
//        [propertyInfo setterBindFrontTrigger:block];
//    }
//    if (option & APCPropertySetterPostTrigger){
//        [propertyInfo setterBindPostTrigger:block];
//    }
//    if (option & APCPropertySetterUserTrigger){
//        [propertyInfo setterBindUserTrigger:block condition:condition];
//    }
//    if (option & APCPropertySetterCountTrigger){
//        [propertyInfo setterBindCountTrigger:block condition:condition];
//    }
    
//    [propertyInfo hook];
}

@end

//
//  NSObject+APCTriggerProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCInstancePropertyCacheManager.h"
#import "NSObject+APCTriggerProperty.h"
#import "AutoTriggerPropertyInfo.h"

@implementation NSObject (APCTriggerProperty)

+ (void)apc_unbindTriggerAllProperties
{
    [AutoTriggerPropertyInfo unhookClassAllProperties:self];
}

#pragma mark - Class
+ (void)apc_frontOfPropertyGetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertyGetterFrontTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindFrontOfPropertyGetter:(NSString*)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p getterUnbindFrontTrigger];
}

+ (void)apc_backOfPropertyGetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertyGetterPostTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindBackOfPropertyGetter:(NSString *)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p getterUnbindPostTrigger];
}

+ (void)apc_propertyGetter:(NSString *)property bindUserCondition:(BOOL (^)(id _Nonnull, id _Nullable))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertyGetterUserTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindUserConditionOfPropertyGetter:(NSString *)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p getterUnbindUserTrigger];
}

+ (void)apc_propertyGetter:(NSString *)property bindAccessCountCondition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertyGetterCountTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindAccessCountConditionOfPropertyGetter:(NSString *)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p getterUnbindCountTrigger];
}

+ (void)apc_frontOfPropertySetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertySetterFrontTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindFrontOfPropertySetter:(NSString*)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p setterUnbindFrontTrigger];
}

+ (void)apc_backOfPropertySetter:(NSString *)property bindWithBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertyGetterPostTrigger
                            condition:nil
                                block:block];
}

+ (void)apc_unbindBackOfPropertySetter:(NSString *)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p setterUnbindPostTrigger];
}

+ (void)apc_propertySetter:(NSString *)property bindUserCondition:(BOOL (^)(id _Nonnull, id _Nullable))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertySetterUserTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindUserConditionOfPropertySetter:(NSString *)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p setterUnbindUserTrigger];
}

+ (void)apc_propertySetter:(NSString *)property bindAccessCountCondition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition withBlock:(void (^)(id _Nonnull, id _Nullable))block
{
    [self apc_classSetTriggerProperty:property
                               option:AutoPropertySetterCountTrigger
                            condition:condition
                                block:block];
}

+ (void)apc_unbindAccessCountConditionOfPropertySetter:(NSString *)property
{
    AutoTriggerPropertyInfo* p = [AutoTriggerPropertyInfo cachedWithClass:self propertyName:property];
    [p setterUnbindCountTrigger];
}


+ (void)apc_classSetTriggerProperty:(NSString*)propertyName
                             option:(AutoPropertyTriggerOption)option
                          condition:(id)condition
                              block:(id)block
{
    if(option == AutoPropertyNonTrigger) return;
    
    AutoTriggerPropertyInfo* propertyInfo = [AutoTriggerPropertyInfo infoWithPropertyName:propertyName
                                                                                   aClass:self];
    
    if(NO  == (propertyInfo.accessOption & AutoPropertyGetValueEnable)
       
       ||
       
       NO  == (propertyInfo.accessOption & AutoPropertySetValueEnable)){
        return;
    }
    
    
    if(option & AutoPropertyGetterFrontTrigger){
        [propertyInfo getterBindFrontTrigger:block];
    }
    if (option & AutoPropertyGetterPostTrigger){
        [propertyInfo getterBindPostTrigger:block];
    }
    if (option & AutoPropertyGetterUserTrigger){
        [propertyInfo getterBindUserTrigger:block condition:condition];
    }
    if (option & AutoPropertyGetterCountTrigger){
        [propertyInfo getterBindCountTrigger:block condition:condition];
    }
    
    if(option & AutoPropertySetterFrontTrigger){
        [propertyInfo setterBindFrontTrigger:block];
    }
    if (option & AutoPropertySetterPostTrigger){
        [propertyInfo setterBindPostTrigger:block];
    }
    if (option & AutoPropertySetterUserTrigger){
        [propertyInfo setterBindUserTrigger:block condition:condition];
    }
    if (option & AutoPropertySetterCountTrigger){
        [propertyInfo setterBindCountTrigger:block condition:condition];
    }
    
    [propertyInfo hook];
}

#pragma mark - Instance

- (void)apc_unbindTriggerAllProperties
{
    [[APCInstancePropertyCacheManager boundAllPropertiesForInstance:self] enumerateObjectsUsingBlock:^(__kindof AutoPropertyInfo * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([property isKindOfClass:[AutoTriggerPropertyInfo class]]){
            
            [property unhook];
        }
    }];
}

@end


#pragma mark - hook of getter
id _Nullable apc_trigger_getter(id _Nonnull _SELF, SEL _Nonnull _CMD)
{
    AutoTriggerPropertyInfo* triggerPropertyInfo;
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterFrontTrigger){
        
        [triggerPropertyInfo performGetterFrontTriggerBlock:_SELF];
    }
    
    id ret = [triggerPropertyInfo performOldPropertyFromTarget:_SELF];
    
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterPostTrigger){
        
        [triggerPropertyInfo performGetterPostTriggerBlock:_SELF value:ret];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterCountTrigger){
        
        if([triggerPropertyInfo performGetterCountConditionBlock:_SELF value:ret]){
            
            [triggerPropertyInfo performGetterCountTriggerBlock:_SELF value:ret];
        }
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterUserTrigger){
        
        if([triggerPropertyInfo performGetterUserConditionBlock:_SELF value:ret]){
            
            [triggerPropertyInfo performGetterUserTriggerBlock:_SELF value:ret];
        }
    }
    
    return ret;
}

apc_def_vGHook_and_impimage(apc_trigger_getter)

#pragma mark - hook of setter
void apc_trigger_setter(id _Nonnull _SELF, SEL _Nonnull _CMD, id _Nullable value)
{
    AutoTriggerPropertyInfo* triggerPropertyInfo;
    
    if(nil == (triggerPropertyInfo = [APCInstancePropertyCacheManager boundPropertyFromInstance:_SELF cmd:NSStringFromSelector(_CMD)]))
        
        if(nil == (triggerPropertyInfo = [AutoTriggerPropertyInfo cachedWithClass:[_SELF class] propertyName:NSStringFromSelector(_CMD)]))
            
            NSCAssert(NO, @"APC: Lose property info.");
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterFrontTrigger){
        
        [triggerPropertyInfo performSetterFrontTriggerBlock:_SELF value:value];
    }
    
    [triggerPropertyInfo performOldSetterFromTarget:_SELF withValue:value];
    
    [triggerPropertyInfo access];
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterPostTrigger){
        
        [triggerPropertyInfo performSetterPostTriggerBlock:_SELF value:value];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterCountTrigger){
        
        if([triggerPropertyInfo performSetterCountConditionBlock:_SELF value:value]){
            
            [triggerPropertyInfo performSetterCountTriggerBlock:_SELF value:value];
        }
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterUserTrigger){
        
        if([triggerPropertyInfo performSetterUserConditionBlock:_SELF value:value]){
            
            [triggerPropertyInfo performSetterUserTriggerBlock:_SELF value:value];
        }
    }
}

apc_def_vSHook_and_impimage(apc_trigger_setter)

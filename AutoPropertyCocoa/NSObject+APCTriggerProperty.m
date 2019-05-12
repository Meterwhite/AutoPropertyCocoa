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
#import "APCPropertyHook.h"
#import "APCRuntime.h"

@implementation NSObject (APCTriggerProperty)


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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerGetterProperty*   p       = hook.getterTrigger;
    [p getterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerGetterProperty*   p       = hook.getterTrigger;
    [p getterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerGetterProperty*   p       = hook.getterTrigger;
    [p getterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerGetterProperty*   p       = hook.getterTrigger;
    [p getterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerSetterProperty*   p       = hook.setterTrigger;
    [p setterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.setterTrigger = nil;
    }
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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerSetterProperty*   p       = hook.setterTrigger;
    [p setterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.setterTrigger = nil;
    }
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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerSetterProperty*   p       = hook.setterTrigger;
    [p setterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.setterTrigger = nil;
    }
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
    APCPropertyHook*            hook    = apc_lookup_propertyhook(self, property);
    APCTriggerSetterProperty*   p       = hook.setterTrigger;
    [p setterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.setterTrigger = nil;
    }
}


+ (void)apc_classSetTriggerProperty:(NSString*)property
                             option:(APCPropertyTriggerOption)option
                          condition:(id)condition
                              block:(id)block
{
    if(option == APCPropertyNonTrigger) return;
    
    APCPropertyHook* hook
    =
    apc_lookup_propertyhook(self, property);
    
    __kindof APCHookProperty* p = hook.getterTrigger;
    if(option & APCPropertyTriggerOfGetter){
        
        if(p == nil){
            
            p = [APCTriggerGetterProperty instanceWithProperty:property aClass:self];
            apc_registerProperty(p);
        }
        if(option & APCPropertyGetterFrontTrigger){
            [p getterBindFrontTrigger:block];
        }
        else if (option & APCPropertyGetterPostTrigger){
            [p getterBindPostTrigger:block];
        }
        else if (option & APCPropertyGetterUserTrigger){
            [p getterBindUserTrigger:block condition:condition];
        }
        else if (option & APCPropertyGetterCountTrigger){
            [p getterBindCountTrigger:block condition:condition];
        }
        
        return;
    }
    
    p = hook.getterTrigger;
    if(p == nil){
        
        p = [APCTriggerSetterProperty instanceWithProperty:property aClass:self];
        apc_registerProperty(p);
    }
    if(option & APCPropertySetterFrontTrigger){
        [p setterBindFrontTrigger:block];
    }
    else if (option & APCPropertySetterPostTrigger){
        [p setterBindPostTrigger:block];
    }
    else if (option & APCPropertySetterUserTrigger){
        [p setterBindUserTrigger:block condition:condition];
    }
    else if (option & APCPropertySetterCountTrigger){
        [p setterBindCountTrigger:block condition:condition];
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p    = hook.getterTrigger;
    [p getterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p    = hook.getterTrigger;
    [p getterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p    = hook.getterTrigger;
    [p getterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p    = hook.getterTrigger;
    [p getterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p    = hook.setterTrigger;
    [p setterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p    = hook.setterTrigger;
    [p setterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p    = hook.setterTrigger;
    [p setterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
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
    APCPropertyHook*          hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p    = hook.setterTrigger;
    [p setterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        hook.getterTrigger = nil;
    }
}

- (void)apc_classSetTriggerProperty:(NSString*)property
                             option:(APCPropertyTriggerOption)option
                          condition:(id)condition
                              block:(id)block
{
    if(option == APCPropertyNonTrigger) return;
    
    APCPropertyHook* hook
    =
    apc_lookup_instancePropertyhook(self, property);
    
    __kindof APCHookProperty* p = hook.getterTrigger;
    if(option & APCPropertyTriggerOfGetter){
        
        if(p == nil){
            
            p = [APCTriggerGetterProperty instanceWithProperty:property aInstance:self];
            apc_object_hookWithProxyClass(self);
            apc_instance_setAssociatedProperty(self, p);
        }
        if(option & APCPropertyGetterFrontTrigger){
            [p getterBindFrontTrigger:block];
        }
        else if (option & APCPropertyGetterPostTrigger){
            [p getterBindPostTrigger:block];
        }
        else if (option & APCPropertyGetterUserTrigger){
            [p getterBindUserTrigger:block condition:condition];
        }
        else if (option & APCPropertyGetterCountTrigger){
            [p getterBindCountTrigger:block condition:condition];
        }
        
        return;
    }
    
    p = hook.getterTrigger;
    if(p == nil){
        
        p = [APCTriggerSetterProperty instanceWithProperty:property aInstance:self];
        apc_object_hookWithProxyClass(self);
        apc_instance_setAssociatedProperty(self, p);
    }
    if(option & APCPropertySetterFrontTrigger){
        [p setterBindFrontTrigger:block];
    }
    else if (option & APCPropertySetterPostTrigger){
        [p setterBindPostTrigger:block];
    }
    else if (option & APCPropertySetterUserTrigger){
        [p setterBindUserTrigger:block condition:condition];
    }
    else if (option & APCPropertySetterCountTrigger){
        [p setterBindCountTrigger:block condition:condition];
    }
}

@end

//
//  NSObject+APCTriggerProperty.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/1.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "NSObject+APCTriggerProperty.h"
#import "APCTriggerGetterProperty.h"
#import "APCTriggerSetterProperty.h"
#import "APCPropertyHook.h"
#import "APCObjectLock.h"
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p != nil){
        
        [p getterUnbindFrontTrigger];
        if(p.triggerOption == APCPropertyNonTrigger){
            
            apc_disposeProperty(p);
        }
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p == nil) return;
    [p getterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_disposeProperty(p);
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p == nil) return;
    [p getterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_disposeProperty(p);
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p == nil) return;
    [p getterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_disposeProperty(p);
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_disposeProperty(p);
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_disposeProperty(p);
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_disposeProperty(p);
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
    APCPropertyHook* hook = apc_getPropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_disposeProperty(p);
    }
}

+ (void)apc_classSetTriggerProperty:(NSString*)property
                             option:(APCPropertyTriggerOption)option
                          condition:(id)condition
                              block:(id)block
{
    if(option == APCPropertyNonTrigger) return;
    
    APCPropertyHook* hook       = apc_getPropertyhook(self, property);
    NSLock*          lock       = apc_object_get_lock(self);
    BOOL             regneed    = NO;
    __kindof APCHookProperty*   p;
    if(option & APCPropertyTriggerOfGetter){
        
        
        p       = hook.getterTrigger;
        
        if((regneed = (p == nil))){
            
            [lock lock];
            
            if(nil == (p = hook.getterTrigger)){
                
                p = [APCTriggerGetterProperty instanceWithProperty:property aClass:self];
            }else{
                
                regneed = NO;
                [lock unlock];
            }
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
        
        if(regneed){
            
            apc_registerProperty(p);
            [lock unlock];
        }
        
        return;
    }
    
    p       = hook.setterTrigger;
    if((regneed = (p == nil))){
        
        [lock lock];
        
        if(nil == (p = hook.getterTrigger)){
            
            p = [APCTriggerSetterProperty instanceWithProperty:property aClass:self];
        }else{
            
            regneed = NO;
            [lock unlock];
        }
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
    
    if(regneed){
        
        apc_registerProperty(p);
        [lock unlock];
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p == nil) return;
    [p getterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p == nil) return;
    [p getterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p == nil) return;
    [p getterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerGetterProperty* p = hook.getterTrigger;
    if(p == nil) return;
    [p getterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook = apc_lookup_instancePropertyhook(self, property);
    APCTriggerSetterProperty* p = hook.setterTrigger;
    if(p == nil) return;
    [p setterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        apc_instance_removeAssociatedProperty(self, p);
    }
}

- (void)apc_classSetTriggerProperty:(NSString*)property
                             option:(APCPropertyTriggerOption)option
                          condition:(id)condition
                              block:(id)block
{
    if(option == APCPropertyNonTrigger) return;
    
    NSLock*             lock        = apc_object_get_lock(self);
    BOOL                regneed     = NO;
    APCPropertyHook*    hook;
    __kindof APCHookProperty* p;
    
    if(apc_object_isProxyInstance(self)){
        
        hook = apc_lookup_instancePropertyhook(self, property);
    }else if(option & APCPropertyTriggerOfGetter){
        
        goto CALL_NEW_GETTER_PROPERTY;
    }else{
        
        goto CALL_NEW_SETTER_PROPERTY;
    }
    
    if(option & APCPropertyTriggerOfGetter){
        
        p = hook.getterTrigger;
        
        if((regneed = (p == nil))){
            
        CALL_NEW_GETTER_PROPERTY:
            {
                [lock lock];
                if(nil == (p = hook.getterTrigger)){
                    
                    regneed = YES;
                    p = [APCTriggerGetterProperty instanceWithProperty:property aInstance:self];
                }else{
                    
                    regneed = NO;
                    [lock unlock];
                }
            }
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
        
        if(regneed){
            
            apc_object_hookWithProxyClass(self);
            apc_instance_setAssociatedProperty(self, p);
            [lock unlock];
        }
        
        return;
    }
    
    p = hook.setterTrigger;
    if((regneed = (p == nil))){
        
    CALL_NEW_SETTER_PROPERTY:
        {
            [lock lock];
            if(nil == (p = hook.getterTrigger)){
                
                regneed = YES;
                p = [APCTriggerSetterProperty instanceWithProperty:property aInstance:self];
            }else{
                
                regneed = NO;
                [lock unlock];
            }
        }
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
    
    if(regneed){
        
        apc_object_hookWithProxyClass(self);
        apc_instance_setAssociatedProperty(self, p);
        [lock unlock];
    }
}

@end

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
    APCTriggerGetterProperty* p = apc_lookup_property(self, property, @selector(getterTrigger));
    if(p != nil){
        
        [p getterUnbindFrontTrigger];
        if(p.triggerOption == APCPropertyNonTrigger){
            
            [p unhook];
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
    APCTriggerGetterProperty* p = apc_lookup_property(self, property, @selector(getterTrigger));
    if(p == nil) return;
    [p getterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerGetterProperty* p = apc_lookup_property(self, property, @selector(getterTrigger));
    if(p == nil) return;
    [p getterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerGetterProperty* p = apc_lookup_property(self, property, @selector(getterTrigger));
    if(p == nil) return;
    [p getterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_property(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_property(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_property(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_property(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    
    p = hook.setterTrigger;
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
    APCTriggerGetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(getterTrigger));
    if(p == nil) return;
    [p getterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerGetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(getterTrigger));
    if(p == nil) return;
    [p getterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerGetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(getterTrigger));
    if(p == nil) return;
    [p getterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerGetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(getterTrigger));
    if(p == nil) return;
    [p getterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindFrontTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindPostTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindUserTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    APCTriggerSetterProperty* p = apc_lookup_instanceProperty(self, property, @selector(setterTrigger));
    if(p == nil) return;
    [p setterUnbindCountTrigger];
    if(p.triggerOption == APCPropertyNonTrigger){
        
        [p unhook];
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
    
    p = hook.setterTrigger;
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

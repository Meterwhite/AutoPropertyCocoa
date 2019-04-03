//
//  AutoTriggerPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoHookPropertyInfo.h"

typedef NS_OPTIONS(NSUInteger, AutoPropertyTriggerOption) {
    
    AutoPropertyNonTrigger            =   0,
    
    AutoPropertyGetterFrontTrigger    =   1 << 0,
    
    AutoPropertyGetterPostTrigger     =   1 << 1,
    
    AutoPropertyGetterUserTrigger     =   1 << 2,
    
    AutoPropertyGetterCountTrigger    =   1 << 3,
    
    AutoPropertyTriggerOfGetter       =   AutoPropertyGetterFrontTrigger
                                        | AutoPropertyGetterPostTrigger
                                        | AutoPropertyGetterUserTrigger
                                        | AutoPropertyGetterCountTrigger,
    
    AutoPropertySetterFrontTrigger    =   1 << 4,
    
    AutoPropertySetterPostTrigger     =   1 << 5,
    
    AutoPropertySetterUserTrigger     =   1 << 6,
    
    AutoPropertySetterCountTrigger    =   1 << 7,
    
    AutoPropertyTriggerOfSetter       =   AutoPropertySetterFrontTrigger
                                        | AutoPropertySetterPostTrigger
                                        | AutoPropertySetterUserTrigger
                                        | AutoPropertySetterCountTrigger
};

@interface AutoTriggerPropertyInfo : AutoHookPropertyInfo<AutoPropertyHookProxyClassNameProtocol>

@property (nonatomic,assign,readonly) AutoPropertyTriggerOption triggerOption;

#pragma mark - getter trigger
- (void)getterBindFrontTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)getterBindPostTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)getterBindUserTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                    condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value))condition;
- (void)getterBindCountTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                     countBlock:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))block;

- (void)getterUnbindFrontTrigger;
- (void)getterUnbindPostTrigger;
- (void)getterUnbindUserTrigger;
- (void)getterUnbindCountTrigger;

- (void)performGetterFrontTriggerBlock:(id _Nonnull)_SELF;
- (void)performGetterPostTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (BOOL)performGetterConditionBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performGetterUserTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performGetterCountTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
#pragma mark - setter trigger
- (void)setterBindFrontTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)setterBindPostTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (BOOL)setterPerformConditionBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)setterBindUserTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                    condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value))condition;
- (void)setterBindCountTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                    countBlock:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))block;

- (void)setterUnbindFrontTrigger;
- (void)setterUnbindPostTrigger;
- (void)setterUnbindUserTrigger;
- (void)setterUnbindCountTrigger;

- (void)performSetterFrontTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performSetterPostTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performSetterUserTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performSetterCountTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
#pragma mark - Hook
- (void)tryUnhook;
- (void)unhook;
- (void)hook;

#pragma mark - Old
- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target;
- (void)performOldSetterFromTarget:(_Nonnull id)target withValue:(id _Nullable)value;

#pragma mark - Cache
+ (_Nullable instancetype)cachedWithClass:(Class _Nonnull)clazz
                             propertyName:(NSString* _Nonnull)propertyName;

@end

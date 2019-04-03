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
    
    AutoPropertyTriggerOfGetter       =   AutoPropertyGetterFrontTrigger
                                        | AutoPropertyGetterPostTrigger
                                        | AutoPropertyGetterUserTrigger,
    
    AutoPropertySetterFrontTrigger    =   1 << 3,
    
    AutoPropertySetterPostTrigger     =   1 << 4,
    
    AutoPropertySetterUserTrigger     =   1 << 5,
    
    AutoPropertyTriggerOfSetter       =   AutoPropertySetterFrontTrigger
                                        | AutoPropertySetterPostTrigger
                                        | AutoPropertySetterUserTrigger,
};

@interface AutoTriggerPropertyInfo : AutoHookPropertyInfo<AutoPropertyHookProxyClassNameProtocol>

@property (nonatomic,assign,readonly) AutoPropertyTriggerOption triggerOption;

#pragma mark - getter trigger
- (void)getterBindFrontTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)getterBindPostTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)getterBindUserTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                    condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value))condition;

- (void)getterPerformFrontTriggerBlock:(id _Nonnull)_SELF;
- (void)getterPerformPostTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (BOOL)getterPerformConditionBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)getterPerformUserTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;

- (void)getterUnbindFrontTrigger;
- (void)getterUnbindPostTrigger;
- (void)getterUnbindUserTrigger;
#pragma mark - setter trigger
- (void)setterBindFrontTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)setterBindPostTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (BOOL)setterPerformConditionBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)setterBindUserTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                    condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value))condition;
- (void)setterUnbindFrontTrigger;
- (void)setterUnbindPostTrigger;
- (void)setterUnbindUserTrigger;

- (void)setterPerformFrontTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)setterPerformPostTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)setterPerformUserTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;

#pragma mark - Hook
- (void)unhook;
- (void)hook;

#pragma mark - Old
- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target;
- (void)performOldSetterFromTarget:(_Nonnull id)target withValue:(id _Nullable)value;

#pragma mark - Cache
+ (_Nullable instancetype)cachedPropertyInfoByClass:(Class _Nonnull)clazz
                               propertyName:(NSString* _Nonnull)propertyName;

- (void)cacheForClass;

- (void)removeFromClassCache;

+ (void)removeCacheForClass:(Class _Nonnull)clazz;
@end

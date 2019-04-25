//
//  APCTriggerGetterProperty.h
//  APCPropertyCocoa
//
//  Created by Novo on 2019/3/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCHookProperty.h"

typedef NS_OPTIONS(NSUInteger, APCPropertyTriggerOption) {
    
    APCPropertyNonTrigger            =   0,
    
    APCPropertyGetterFrontTrigger    =   1 << 0,
    
    APCPropertyGetterPostTrigger     =   1 << 1,
    
    APCPropertyGetterUserTrigger     =   1 << 2,
    
    APCPropertyGetterCountTrigger    =   1 << 3,
    
    APCPropertyTriggerOfGetter       =   APCPropertyGetterFrontTrigger
                                        | APCPropertyGetterPostTrigger
                                        | APCPropertyGetterUserTrigger
                                        | APCPropertyGetterCountTrigger,
    
    APCPropertySetterFrontTrigger    =   1 << 4,
    
    APCPropertySetterPostTrigger     =   1 << 5,
    
    APCPropertySetterUserTrigger     =   1 << 6,
    
    APCPropertySetterCountTrigger    =   1 << 7,
    
    APCPropertyTriggerOfSetter       =   APCPropertySetterFrontTrigger
                                        | APCPropertySetterPostTrigger
                                        | APCPropertySetterUserTrigger
                                        | APCPropertySetterCountTrigger
};

@interface APCTriggerGetterProperty : APCHookProperty

@property (nonatomic,assign,readonly) APCPropertyTriggerOption triggerOption;

#pragma mark - getter trigger
- (void)getterBindFrontTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)getterBindPostTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)getterBindUserTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                    condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value))condition;
- (void)getterBindCountTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                     condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))condition;

- (void)getterUnbindFrontTrigger;
- (void)getterUnbindPostTrigger;
- (void)getterUnbindUserTrigger;
- (void)getterUnbindCountTrigger;

- (void)performGetterFrontTriggerBlock:(nonnull id)_SELF;
- (void)performGetterPostTriggerBlock:(nonnull id)_SELF value:(nonnull id)value;
- (BOOL)performGetterUserConditionBlock:(nonnull id)_SELF value:(nonnull id)value;
- (void)performGetterUserTriggerBlock:(nonnull id)_SELF value:(nonnull id)value;
- (void)performGetterCountTriggerBlock:(nonnull id)_SELF value:(nonnull id)value;
- (BOOL)performGetterCountConditionBlock:(nonnull id)_SELF value:(nonnull id)value;

#pragma mark - Hook
//- (void)hook;
//- (void)tryUnhook;
//+ (void)unhookClassAllProperties:(Class _Nonnull __unsafe_unretained)clazz;

#pragma mark - Old
- (_Nullable id)performOldGetterFromTarget:(nonnull id)target;
- (void)performOldSetterFromTarget:(nonnull id)target withValue:(nullable id)value;

#pragma mark - Cache
//+ (_Nullable instancetype)cachedTargetClass:(Class _Nonnull)clazz
//                                   property:(NSString* _Nonnull)property;
//
//+ (_Nullable instancetype)cachedFromAClass:(Class _Nonnull)aClazz
//                                  property:(NSString* _Nonnull)property;
@end

//
//  APCTriggerSetterProperty.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerGetterProperty.h"



@interface APCTriggerSetterProperty : APCHookProperty<APCPropertyHookProxyClassNameProtocol>

@property (nonatomic,assign,readonly) APCPropertyTriggerOption triggerOption;

#pragma mark - setter trigger
- (void)setterBindFrontTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)setterBindPostTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block;
- (void)setterBindUserTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                    condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value))condition;
- (void)setterBindCountTrigger:(void(^ _Nonnull)(id _Nonnull instance,id _Nullable value))block
                     condition:(BOOL(^_Nonnull)(id _Nonnull instance,id _Nullable value,NSUInteger count))condition;

- (void)setterUnbindFrontTrigger;
- (void)setterUnbindPostTrigger;
- (void)setterUnbindUserTrigger;
- (void)setterUnbindCountTrigger;

- (void)performSetterFrontTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performSetterPostTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (BOOL)performSetterUserConditionBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performSetterUserTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (BOOL)performSetterCountConditionBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
- (void)performSetterCountTriggerBlock:(id _Nonnull)_SELF value:(id _Nonnull)value;
@end



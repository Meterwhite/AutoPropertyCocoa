//
//  APCTriggerSetterProperty.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerGetterProperty.h"



@interface APCTriggerSetterProperty : APCHookProperty

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

- (void)performSetterFrontTriggerBlock:(nonnull id)_SELF value:(nonnull id)value;
- (void)performSetterPostTriggerBlock:(nonnull id)_SELF value:(nonnull id)value;
- (BOOL)performSetterUserConditionBlock:(nonnull id)_SELF value:(nonnull id)value;
- (void)performSetterUserTriggerBlock:(nonnull id)_SELF value:(nonnull id)value;
- (BOOL)performSetterCountConditionBlock:(nonnull id)_SELF value:(nonnull id)value;
- (void)performSetterCountTriggerBlock:(nonnull id)_SELF value:(nonnull id)value;
@end



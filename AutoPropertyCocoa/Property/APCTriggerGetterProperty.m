//
//  APCTriggerGetterProperty.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/3/30.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//
#import "APCUserEnvironmentSupportObject.h"
#import "APCTriggerGetterProperty.h"
#import "APCPropertyHook.h"
#import "APCScope.h"

@implementation APCTriggerGetterProperty
{
    void(^_block_fronttrigger)(id _Nonnull instance);
    void(^_block_posttrigger)(id _Nonnull instance,id _Nullable value);
    void(^_block_usertrigger)(id _Nonnull instance,id _Nullable value);
    BOOL(^_block_usercondition)(id _Nonnull instance,id _Nullable value);
    void(^_block_counttrigger)(id _Nonnull instance,id _Nullable value);
    BOOL(^_block_countcondition)(id _Nonnull instance,id _Nullable value,NSUInteger count);
}

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                              aClass:(Class)aClass
{
    if(self = [super initWithPropertyName:propertyName aClass:aClass]){
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _inlet          = @selector(setGetterTrigger:);
#pragma clang diagnostic pop
        _kindOfUserHook = APCPropertyHookKindOfIMP;
        _outlet         = @selector(getterTrigger);
        _triggerOption  = APCPropertyNonTrigger;
        _methodStyle    = APCMethodGetterStyle;
        _hooked_name    = _des_getter_name;
    }
    return self;
}

#pragma mark - getter
- (void)getterBindFrontTrigger:(void (^)(id _Nonnull))block
{
    _block_fronttrigger = [block copy];
    _triggerOption |= APCPropertyGetterFrontTrigger;
}

- (void)getterBindPostTrigger:(void (^)(id _Nonnull, id _Nullable))block
{
    _block_posttrigger = [block copy];
    _triggerOption |= APCPropertyGetterPostTrigger;
}

- (void)getterBindUserTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable))condition
{
    _block_usertrigger   = [block copy];
    _block_usercondition = [condition copy];
    _triggerOption |= APCPropertyGetterUserTrigger;
}

- (void)getterBindCountTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition
{
    _block_counttrigger   = [block copy];
    _block_countcondition = [condition copy];
    _triggerOption |= APCPropertyGetterCountTrigger;
}

- (void)getterUnbindFrontTrigger
{
    _block_fronttrigger = nil;
    _triggerOption &= ~APCPropertyGetterFrontTrigger;
}

- (void)getterUnbindPostTrigger
{
    _block_posttrigger = nil;
    _triggerOption &= ~APCPropertyGetterPostTrigger;
}

- (void)getterUnbindUserTrigger
{
    _block_usertrigger   = nil;
    _block_usercondition = nil;
    _triggerOption &= ~APCPropertyGetterUserTrigger;
}

- (void)getterUnbindCountTrigger
{
    _block_counttrigger   = nil;
    _block_countcondition = nil;
    _triggerOption &= ~APCPropertyGetterCountTrigger;
}

- (void)performGetterFrontTriggerBlock:(id)_SELF
{
    if(_block_fronttrigger){

        _block_fronttrigger(APCUserEnvironmentObject(_SELF, self));
    }
}

- (void)performGetterPostTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_posttrigger){
        
        _block_posttrigger(APCUserEnvironmentObject(_SELF, self), value);
    }
}

- (BOOL)performGetterUserConditionBlock:(id)_SELF value:(id)value
{
    if(_block_usercondition){
        
        return _block_usercondition(APCUserEnvironmentObject(_SELF, self), value);
    }
    return NO;
}

- (void)performGetterUserTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_usertrigger){
        
        _block_usertrigger(APCUserEnvironmentObject(_SELF, self), value);
    }
}

- (void)performGetterCountTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_counttrigger){
        
        _block_counttrigger(APCUserEnvironmentObject(_SELF, self), value);
    }
}

- (BOOL)performGetterCountConditionBlock:(id)_SELF value:(id)value
{
    if(_block_countcondition){
        
        return _block_countcondition(APCUserEnvironmentObject(_SELF, self), value, self.accessCount);
    }
    return NO;
}

@end

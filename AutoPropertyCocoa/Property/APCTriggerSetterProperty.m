//
//  APCTriggerSetterProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerSetterProperty.h"
#import "APCPropertyHook.h"

@implementation APCTriggerSetterProperty
{
    void(^_block_fronttrigger)(id _Nonnull instance,id _Nullable value);
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
        
        _kindOfUserHook     = APCPropertyHookKindOfIMP;
        _triggerOption  = APCPropertyNonTrigger;
        _methodStyle    = APCMethodSetterStyle;
        _hooked_name       = _des_setter_name;
    }
    return self;
}

#pragma mark - setter

- (void)setterBindFrontTrigger:(void (^)(id _Nonnull, id _Nullable))block
{
    _block_fronttrigger = [block copy];
    _triggerOption |= APCPropertySetterFrontTrigger;
}

- (void)setterBindPostTrigger:(void (^)(id _Nonnull, id _Nullable))block
{
    _block_posttrigger = [block copy];
    _triggerOption |= APCPropertySetterPostTrigger;
}

- (void)setterBindUserTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable))condition
{
    _block_usertrigger   = [block copy];
    _block_usercondition = [condition copy];
    _triggerOption |= APCPropertySetterUserTrigger;
}

- (void)setterBindCountTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition
{
    _block_counttrigger   = [block copy];
    _block_countcondition = [condition copy];
    _triggerOption |= APCPropertySetterCountTrigger;
}

- (void)setterUnbindFrontTrigger
{
    _block_fronttrigger = nil;
    _triggerOption &= ~APCPropertySetterFrontTrigger;
}

- (void)setterUnbindPostTrigger
{
    _block_posttrigger = nil;
    _triggerOption &= ~APCPropertySetterPostTrigger;
}

- (void)setterUnbindUserTrigger
{
    _block_usertrigger   = nil;
    _block_usercondition = nil;
    _triggerOption &= ~APCPropertySetterUserTrigger;
}

- (void)setterUnbindCountTrigger
{
    _block_counttrigger   = nil;
    _block_countcondition = nil;
    _triggerOption &= ~APCPropertySetterCountTrigger;
}

- (void)performSetterFrontTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_fronttrigger){
        
        _SELF
        =
        [[[APCUserEnvironmentSupport<APCTriggerSetterProperty*> alloc] initWithObject:_SELF message:self] setSuperMessagePerformerForAction:^(APCUserEnvironmentSupport<APCTriggerSetterProperty *> *uObject) {
            
            [[uObject superMessage] performSetterFrontTriggerBlock:_SELF value:value];
        }];
        _block_fronttrigger(_SELF,value);
    }
}

- (void)performSetterPostTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_posttrigger){
        
        _SELF
        =
        [[[APCUserEnvironmentSupport<APCTriggerSetterProperty*> alloc] initWithObject:_SELF message:self] setSuperMessagePerformerForAction:^(APCUserEnvironmentSupport<APCTriggerSetterProperty *> *uObject) {
            
            [[uObject superMessage] performSetterPostTriggerBlock:_SELF value:value];
        }];
        _block_posttrigger(_SELF, value);
    }
}

- (BOOL)performSetterUserConditionBlock:(id)_SELF value:(id)value
{
    if(_block_usercondition){
        
        _SELF
        =
        [[[APCUserEnvironmentSupport<APCTriggerSetterProperty*> alloc] initWithObject:_SELF message:self] setSuperMessagePerformerForAction:^(APCUserEnvironmentSupport<APCTriggerSetterProperty *> *uObject) {
            
            uObject.returnedBOOLValue
            =
            [[uObject superMessage] performSetterUserConditionBlock:_SELF value:value];
        }];
        return _block_usercondition(_SELF, value);
    }
    return NO;
}

- (void)performSetterUserTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_usertrigger){
        
        _SELF
        =
        [[[APCUserEnvironmentSupport<APCTriggerSetterProperty*> alloc] initWithObject:_SELF message:self] setSuperMessagePerformerForAction:^(APCUserEnvironmentSupport<APCTriggerSetterProperty *> *uObject) {
            
            [[uObject superMessage] performSetterUserTriggerBlock:_SELF value:value];
        }];
        _block_usertrigger(_SELF,value);
    }
}

- (BOOL)performSetterCountConditionBlock:(id)_SELF value:(id)value
{
    if(_block_countcondition){
        
        _SELF
        =
        [[[APCUserEnvironmentSupport<APCTriggerSetterProperty*> alloc] initWithObject:_SELF message:self] setSuperMessagePerformerForAction:^(APCUserEnvironmentSupport<APCTriggerSetterProperty *> *uObject) {
            
            [[uObject superMessage] performSetterCountConditionBlock:_SELF value:value];
        }];
        return _block_countcondition(_SELF, value, self.accessCount);
    }
    return NO;
}

- (void)performSetterCountTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_counttrigger){
        
        _SELF
        =
        [[[APCUserEnvironmentSupport<APCTriggerSetterProperty*> alloc] initWithObject:_SELF message:self] setSuperMessagePerformerForAction:^(APCUserEnvironmentSupport<APCTriggerSetterProperty *> *uObject) {
            
            [[uObject superMessage] performSetterCountTriggerBlock:_SELF value:value];
        }];
        _block_counttrigger(_SELF,value);
    }
}

static SEL _outlet = 0;
- (SEL)outlet
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _outlet = @selector(setterTrigger);
    });
    
    return _outlet;
}

static SEL _inlet = 0;
- (SEL)inlet
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inlet = @selector(setGetterTrigger:);
    });
    
    return _inlet;
}
@end

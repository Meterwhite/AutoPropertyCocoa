//
//  APCTriggerGetterProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/30.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "APCTriggerGetterProperty.h"
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
        
        _kindOfUserHook = APCPropertyHookKindOfIMP;
        _triggerOption  = APCPropertyNonTrigger;
        _methodStyle    = APCMethodGetterStyle;
        _hooked_name    = _des_getter_name;
    }
    return self;
}

#pragma mark - getter
- (void)getterBindFrontTrigger:(void (^)(id _Nonnull, id _Nullable))block
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
        
        _block_fronttrigger(_SELF);
    }
}

- (void)performGetterPostTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_posttrigger){
        
        _block_posttrigger(_SELF, value);
    }
}

- (BOOL)performGetterUserConditionBlock:(id)_SELF value:(id)value
{
    if(_block_usercondition){
        
        return _block_usercondition(_SELF, value);
    }
    return NO;
}

- (void)performGetterUserTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_usertrigger){
        
        _block_usertrigger(_SELF,value);
    }
}

- (void)performGetterCountTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_counttrigger){
        
        _block_counttrigger(_SELF,value);
    }
}

- (BOOL)performGetterCountConditionBlock:(id)_SELF value:(id)value
{
    if(_block_countcondition){
        
        return _block_countcondition(_SELF, value, self.accessCount);
    }
    return NO;
}

- (_Nullable id)performOldGetterFromTarget:(_Nonnull id)target
{
    return nil;
}

- (void)performOldSetterFromTarget:(_Nonnull id)target withValue:(id _Nullable)value
{

}

@end

//- (void)cacheToInstanceMapper
//{
//    [APCInstancePropertyCacheManager bindProperty:self
//                                       toInstance:_instance
//                                              cmd:_des_getter_name];
//
//    if(self.triggerOption & APCPropertyTriggerOfSetter){
//
//        [APCInstancePropertyCacheManager bindProperty:self
//                                           toInstance:_instance
//                                                  cmd:_des_setter_name];
//    }
//}
//
//- (void)removeFromInstanceCache
//{
//    [APCInstancePropertyCacheManager boundPropertyRemoveFromInstance:_instance
//                                                                 cmd:_des_getter_name];
//
//    if(NO == [APCInstancePropertyCacheManager boundContainsValidPropertyForInstance:_instance]){
//
//        [APCInstancePropertyCacheManager boundAllPropertiesRemoveFromInstance:_instance];
//    }
//}
//
//static APCClassPropertyMapperController* _cacheForClass;
//- (void)cacheToClassMapper
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        _cacheForClass     =   [APCClassPropertyMapperController cache];
//    });
//
//    [_cacheForClass addProperty:self];
//}
//
//+ (_Nullable instancetype)cachedTargetClass:(Class)clazz
//                                   property:(NSString*)property
//{
//    clazz = [APCTriggerGetterProperty unproxyClass:clazz];
//
//    return [_cacheForClass propertyForDesclass:clazz property:property];
//}
//
//+ (instancetype)cachedFromAClass:(Class)aClazz
//                        property:(NSString *)property
//{
//    aClazz = [APCTriggerGetterProperty unproxyClass:aClazz];
//
//    return [_cacheForClass searchFromTargetClass:aClazz property:property];
//}
//
//- (void)removeFromClassCache
//{
//    [_cacheForClass removeProperty:self];
//}

#pragma mark - APCPropertyMapperKeyProtocol
//- (NSSet<APCPropertyMapperkey *> *)propertyMapperkeys
//{
//    NSMutableSet* set = [NSMutableSet set];
//
//    [set addObject:[APCPropertyMapperkey keyWithClass:_des_class
//                                             property:_des_getter_name]];
//
//    if(self.triggerOption & APCPropertyTriggerOfSetter){
//
//        [set addObject:[APCPropertyMapperkey keyWithClass:_des_class
//                                                 property:_des_setter_name]];
//    }
//
//    return set;
//}

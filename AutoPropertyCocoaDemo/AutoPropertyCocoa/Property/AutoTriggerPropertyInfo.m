//
//  AutoTriggerPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassPropertyMapperCache.h"
#import "AutoTriggerPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "APCScope.h"

id    _Nullable apc_trigger_getter         (_Nullable id _self,SEL __cmd);
void* _Nullable apc_trigger_getter_impimage(NSString* eType);

id    _Nullable apc_trigger_setter         (_Nullable id _self,SEL __cmd);
void* _Nullable apc_trigger_setter_impimage(NSString* eType);

@implementation AutoTriggerPropertyInfo
{
    void(^_block_getter_fronttrigger)(id _Nonnull instance);
    void(^_block_getter_posttrigger)(id _Nonnull instance,id _Nullable value);
    void(^_block_getter_usertrigger)(id _Nonnull instance,id _Nullable value);
    BOOL(^_block_getter_usercondition)(id _Nonnull instance,id _Nullable value);
    
    void(^_block_setter_fronttrigger)(id _Nonnull instance,id _Nullable value);
    void(^_block_setter_posttrigger)(id _Nonnull instance,id _Nullable value);
    void(^_block_setter_usertrigger)(id _Nonnull instance,id _Nullable value);
    BOOL(^_block_setter_usercondition)(id _Nonnull instance,id _Nullable value);
}

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                              aClass:(Class __unsafe_unretained)aClass
{
    if(self = [super initWithPropertyName:propertyName aClass:aClass]){
        
        _kindOfHook = AutoPropertyHookKindOfIMP;
        _triggerOption = AutoPropertyNonTrigger;
    }
    return self;
}

- (void)getterBindFrontTrigger:(void (^)(id _Nonnull, id _Nullable))block
{
    _block_getter_fronttrigger = [block copy];
    _triggerOption |= AutoPropertyGetterFrontTrigger;
}

- (void)getterBindPostTrigger:(void (^)(id _Nonnull, id _Nullable))block
{
    _block_getter_posttrigger = [block copy];
    _triggerOption |= AutoPropertyGetterPostTrigger;
}

- (void)getterBindUserTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable))condition
{
    _block_getter_usertrigger   = [block copy];
    _block_getter_usercondition = [condition copy];
    _triggerOption |= AutoPropertyGetterUserTrigger;
}

- (void)getterUnbindFrontTrigger
{
    _block_getter_fronttrigger = nil;
    _triggerOption &= ~AutoPropertyGetterFrontTrigger;
}

- (void)getterUnbindPostTrigger
{
    _block_getter_posttrigger = nil;
    _triggerOption &= ~AutoPropertyGetterPostTrigger;
}

- (void)getterUnbindUserTrigger
{
    _block_getter_usertrigger   = nil;
    _block_getter_usercondition = nil;
    _triggerOption &= ~AutoPropertyGetterUserTrigger;
}
- (void)getterPerformFrontTriggerBlock:(id)_SELF
{
    if(_block_getter_fronttrigger){
        
        _block_getter_fronttrigger(_SELF);
    }
}

- (void)getterPerformPostTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_getter_posttrigger){
        
        _block_getter_posttrigger(_SELF, value);
    }
}

- (BOOL)getterPerformConditionBlock:(id)_SELF value:(id)value
{
    if(_block_getter_usercondition){
        
        return _block_getter_usercondition(_SELF, value);
    }
    return NO;
}

- (void)getterPerformUserTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_getter_usertrigger){
        
        _block_getter_usertrigger(_SELF,value);
    }
}

- (void)setterBindFrontTrigger:(void (^)(id _Nonnull, id _Nullable))block
{
    _block_setter_fronttrigger = [block copy];
    _triggerOption |= AutoPropertySetterFrontTrigger;
}

- (void)setterBindPostTrigger:(void (^)(id _Nonnull, id _Nullable))block
{
    _block_setter_posttrigger = [block copy];
    _triggerOption |= AutoPropertySetterPostTrigger;
}

- (void)setterBindUserTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable))condition
{
    _block_setter_usertrigger   = [block copy];
    _block_setter_usercondition = [condition copy];
    _triggerOption |= AutoPropertySetterUserTrigger;
}

- (void)setterUnbindFrontTrigger
{
    _block_setter_fronttrigger = nil;
    _triggerOption &= ~AutoPropertySetterFrontTrigger;
}

- (void)setterUnbindPostTrigger
{
    _block_setter_posttrigger = nil;
    _triggerOption &= ~AutoPropertySetterPostTrigger;
}

- (void)setterUnbindUserTrigger
{
    _block_setter_usertrigger   = nil;
    _block_setter_usercondition = nil;
    _triggerOption &= ~AutoPropertySetterUserTrigger;
}
- (void)setterPerformFrontTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_setter_fronttrigger){
        
        _block_setter_fronttrigger(_SELF,value);
    }
}

- (void)setterPerformPostTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_getter_posttrigger){
        
        _block_getter_posttrigger(_SELF, value);
    }
}

- (BOOL)setterPerformConditionBlock:(id)_SELF value:(id)value
{
    if(_block_setter_usercondition){
        
        return _block_setter_usercondition(_SELF, value);
    }
    return NO;
}

- (void)setterPerformUserTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_setter_usertrigger){
        
        _block_setter_usertrigger(_SELF,value);
    }
}

#pragma mark - hook
- (void)hook
{
    IMP newimp      =   nil;
    if(self.triggerOption & AutoPropertyTriggerOfGetter){
        
        if(self.kindOfValue == AutoPropertyValueKindOfBlock ||
           self.kindOfValue == AutoPropertyValueKindOfObject){
            
            newimp = (IMP)apc_trigger_getter;
        }else{
            
            newimp = (IMP)apc_trigger_getter_impimage(self.valueTypeEncoding);
        }
        [self hookPropertyWithImplementation:newimp option:AutoPropertyTriggerOfGetter];
    }
    
    if(self.triggerOption & AutoPropertyTriggerOfSetter){
        
        if(self.kindOfValue == AutoPropertyValueKindOfBlock ||
           self.kindOfValue == AutoPropertyValueKindOfObject){
            
            newimp = (IMP)apc_trigger_setter;
        }else{
            
            newimp = (IMP)apc_trigger_setter_impimage(self.valueTypeEncoding);
        }
        [self hookPropertyWithImplementation:newimp option:AutoPropertyTriggerOfSetter];
    }
    
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        [self cache];
    }else{
        
//        [self bindInstancePropertyInfo];
    }
    
}

- (void)hookPropertyWithImplementation:(IMP)implementation option:(NSUInteger)option
{
    _new_implementation = implementation;
    
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        ///AutoPropertyOwnerKindOfClass
        _old_implementation
        =
        class_replaceMethod(_des_class
                            , NSSelectorFromString(_des_property_name)
                            , _new_implementation
                            , [NSString stringWithFormat:@"%@@:", self.valueTypeEncoding].UTF8String);
        
        if(nil == _old_implementation && (_des_class != _src_class)){
            
            AutoTriggerPropertyInfo* pinfo_superclass
            =
            [_cacheForClass propertyForDesclass:_src_class property:_des_property_name];
            
            if(nil != pinfo_superclass){
                
                _old_implementation = pinfo_superclass->_old_implementation;
            }else{
                
                _old_implementation
                =
                class_getMethodImplementation(_src_class, NSSelectorFromString(_des_property_name));
            }
            
            
        }else{
            
            
        }
    }
}


- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target
{
    if(NO == (_new_implementation && _old_implementation)){
        
        return nil;
    }
    
    return
    
    apc_getterimp_boxinvok(target
                           , NSSelectorFromString(_des_property_name)
                           , _old_implementation
                           , self.valueTypeEncoding.UTF8String);
}

- (void)performOldSetterFromTarget:(_Nonnull id)target withValue:(id _Nullable)value
{
    if(NO == (_new_setter_implementation && _old_setter_implementation)){
        
        return;
    }
    
    apc_setterimp_boxinvok(target
                           , NSSelectorFromString(_des_setter_name)
                           , _old_setter_implementation
                           , self.valueTypeEncoding.UTF8String
                           , value);
}

- (void)unhook
{
#warning set
    if(_old_implementation && _new_implementation){
        
        if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
            
            _new_implementation = nil;
            
            class_replaceMethod(_des_class
                                , NSSelectorFromString(_des_property_name)
                                , _old_implementation
                                , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
        }
    }
    [self invalid];
}

#pragma mark - cache strategy

static APCClassPropertyMapperCache* _cacheForClass;
- (void)cache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cacheForClass     =   [APCClassPropertyMapperCache cache];
    });
    
    [_cacheForClass addProperty:self];
}

- (void)removeFromCache
{
    [_cacheForClass removeProperty:self];
}

#pragma mark - APCPropertyMapperKeyProtocol
- (NSSet<APCPropertyMapperkey *> *)propertyMapperkeys
{
    NSMutableSet* set = [NSMutableSet set];
    
    if(self.triggerOption & AutoPropertyTriggerOfGetter){
        
        [set addObject:[APCPropertyMapperkey keyWithClass:_des_class
                                                 property:_des_property_name]];
    }
    
    if(self.triggerOption & AutoPropertyTriggerOfSetter){
        
        [set addObject:[APCPropertyMapperkey keyWithClass:_des_class
                                                 property:_des_setter_name]];
    }
    
    return set;
}


@end

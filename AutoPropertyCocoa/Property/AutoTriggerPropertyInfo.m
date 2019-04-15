//
//  AutoTriggerPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/30.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "APCInstancePropertyCacheManager.h"
#import "APCClassPropertyMapperController.h"
#import "AutoTriggerPropertyInfo.h"
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
    void(^_block_getter_counttrigger)(id _Nonnull instance,id _Nullable value);
    BOOL(^_block_getter_countcondition)(id _Nonnull instance,id _Nullable value,NSUInteger count);
    
    void(^_block_setter_fronttrigger)(id _Nonnull instance,id _Nullable value);
    void(^_block_setter_posttrigger)(id _Nonnull instance,id _Nullable value);
    void(^_block_setter_usertrigger)(id _Nonnull instance,id _Nullable value);
    BOOL(^_block_setter_usercondition)(id _Nonnull instance,id _Nullable value);
    void(^_block_setter_counttrigger)(id _Nonnull instance,id _Nullable value);
    BOOL(^_block_setter_countcondition)(id _Nonnull instance,id _Nullable value,NSUInteger count);
}

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                              aClass:(Class)aClass
{
    if(self = [super initWithPropertyName:propertyName aClass:aClass]){
        
        _kindOfHook     = AutoPropertyHookKindOfIMP;
        _triggerOption  = AutoPropertyNonTrigger;
    }
    return self;
}

#pragma mark - getter
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

- (void)getterBindCountTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition
{
    _block_getter_counttrigger   = [block copy];
    _block_getter_countcondition = [condition copy];
    _triggerOption |= AutoPropertyGetterCountTrigger;
}

- (void)getterUnbindFrontTrigger
{
    _block_getter_fronttrigger = nil;
    _triggerOption &= ~AutoPropertyGetterFrontTrigger;
    [self tryUnhook];
}

- (void)getterUnbindPostTrigger
{
    _block_getter_posttrigger = nil;
    _triggerOption &= ~AutoPropertyGetterPostTrigger;
    [self tryUnhook];
}

- (void)getterUnbindUserTrigger
{
    _block_getter_usertrigger   = nil;
    _block_getter_usercondition = nil;
    _triggerOption &= ~AutoPropertyGetterUserTrigger;
    [self tryUnhook];
}

- (void)getterUnbindCountTrigger
{
    _block_getter_counttrigger   = nil;
    _block_getter_countcondition = nil;
    _triggerOption &= ~AutoPropertyGetterCountTrigger;
    [self tryUnhook];
}

- (void)performGetterFrontTriggerBlock:(id)_SELF
{
    if(_block_getter_fronttrigger){
        
        _block_getter_fronttrigger(_SELF);
    }
}

- (void)performGetterPostTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_getter_posttrigger){
        
        _block_getter_posttrigger(_SELF, value);
    }
}

- (BOOL)performGetterUserConditionBlock:(id)_SELF value:(id)value
{
    if(_block_getter_usercondition){
        
        return _block_getter_usercondition(_SELF, value);
    }
    return NO;
}

- (void)performGetterUserTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_getter_usertrigger){
        
        _block_getter_usertrigger(_SELF,value);
    }
}

- (void)performGetterCountTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_getter_counttrigger){
        
        _block_getter_counttrigger(_SELF,value);
    }
}

- (BOOL)performGetterCountConditionBlock:(id)_SELF value:(id)value
{
    if(_block_getter_countcondition){
        
        return _block_getter_countcondition(_SELF, value, self.accessCount);
    }
    return NO;
}

#pragma mark - setter

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

- (void)setterBindCountTrigger:(void (^)(id _Nonnull, id _Nullable))block condition:(BOOL (^)(id _Nonnull, id _Nullable, NSUInteger))condition
{
    _block_setter_counttrigger   = [block copy];
    _block_setter_countcondition = [condition copy];
    _triggerOption |= AutoPropertySetterCountTrigger;
}

- (void)setterUnbindFrontTrigger
{
    _block_setter_fronttrigger = nil;
    _triggerOption &= ~AutoPropertySetterFrontTrigger;
    [self tryUnhook];
}

- (void)setterUnbindPostTrigger
{
    _block_setter_posttrigger = nil;
    _triggerOption &= ~AutoPropertySetterPostTrigger;
    [self tryUnhook];
}

- (void)setterUnbindUserTrigger
{
    _block_setter_usertrigger   = nil;
    _block_setter_usercondition = nil;
    _triggerOption &= ~AutoPropertySetterUserTrigger;
    [self tryUnhook];
}

- (void)setterUnbindCountTrigger
{
    _block_setter_counttrigger   = nil;
    _block_setter_countcondition = nil;
    _triggerOption &= ~AutoPropertySetterCountTrigger;
    [self tryUnhook];
}

- (void)performSetterFrontTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_setter_fronttrigger){
        
        _block_setter_fronttrigger(_SELF,value);
    }
}

- (void)performSetterPostTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_setter_posttrigger){
        
        _block_setter_posttrigger(_SELF, value);
    }
}

- (BOOL)performSetterUserConditionBlock:(id)_SELF value:(id)value
{
    if(_block_setter_usercondition){
        
        return _block_setter_usercondition(_SELF, value);
    }
    return NO;
}

- (void)performSetterUserTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_setter_usertrigger){
        
        _block_setter_usertrigger(_SELF,value);
    }
}

- (BOOL)performSetterCountConditionBlock:(id)_SELF value:(id)value
{
    if(_block_setter_countcondition){
        
        return _block_setter_countcondition(_SELF, value, self.accessCount);
    }
    return NO;
}

- (void)performSetterCountTriggerBlock:(id)_SELF value:(id)value
{
    if(_block_setter_counttrigger){
        
        _block_setter_counttrigger(_SELF,value);
    }
}


#pragma mark - Hook
- (void)hook
{
    IMP newimp = nil;
    
    if(nil == _old_getter_implementation
       && self.triggerOption & AutoPropertyTriggerOfGetter){
        
        if(self.kindOfValue == AutoPropertyValueKindOfBlock
           || self.kindOfValue == AutoPropertyValueKindOfObject){
            
            newimp = (IMP)apc_trigger_getter;
        }else{
            
            newimp = (IMP)apc_trigger_getter_impimage(self.valueTypeEncoding);
        }
        [self hookPropertyWithImplementation:newimp option:AutoPropertyTriggerOfGetter];
        goto CACHE;
    }
    
    if(nil == _old_setter_implementation
       && self.triggerOption & AutoPropertyTriggerOfSetter){
        
        if(self.kindOfValue == AutoPropertyValueKindOfBlock
           || self.kindOfValue == AutoPropertyValueKindOfObject){
            
            newimp = (IMP)apc_trigger_setter;
        }else{
            
            newimp = (IMP)apc_trigger_setter_impimage(self.valueTypeEncoding);
        }
        [self hookPropertyWithImplementation:newimp option:AutoPropertyTriggerOfSetter];
        goto CACHE;
    }
    
    return;
    
CACHE:
    {
        
        if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
            
            [self cacheToClassMapper];
        }else{
            
            [self cacheToInstanceMapper];
        }
        return;
    }
}

- (void)hookPropertyWithImplementation:(IMP)implementation option:(NSUInteger)option
{
    
    NSMutableString*    methodEnc   = [NSMutableString string];
    NSString*           des_name    = nil;
    SEL                 des_sel     = nil;
    IMP                 oldIMP      = nil;
    if(option == AutoPropertyTriggerOfGetter){
        
        [methodEnc appendString:self.valueTypeEncoding];
        _new_getter_implementation = implementation;
        des_name = _des_method_name;
        des_sel = NSSelectorFromString(des_name);
    }
    [methodEnc appendString:@"@:"];
    if(option == AutoPropertyTriggerOfSetter){
        
        [methodEnc appendString:self.valueTypeEncoding];
        _new_setter_implementation = implementation;
        des_name = _des_setter_name;
        des_sel = NSSelectorFromString(des_name);
    }
    
    
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        oldIMP
        =
        class_replaceMethod(_des_class
                            , des_sel
                            , implementation
                            , methodEnc.UTF8String);
        
        if(nil == oldIMP){
            
            AutoTriggerPropertyInfo* pinfo_superclass
            =
            [_cacheForClass propertyForDesclass:_src_class property:des_name];
            
            if(nil != pinfo_superclass){
                
                oldIMP =
                (option == AutoPropertyTriggerOfGetter)
                ? pinfo_superclass->_old_getter_implementation
                : pinfo_superclass->_old_setter_implementation;
                
            }else{
                
                oldIMP = class_getMethodImplementation(_src_class, des_sel);
            }
        }
    }
    else{
        
        if(nil == _proxyClass){
            
            if(NO == [AutoTriggerPropertyInfo testingProxyClassInstance:_instance]){
                
                NSString *proxyClassName = self.proxyClassName;
                _proxyClass = objc_allocateClassPair(_des_class, proxyClassName.UTF8String, 0);
                if(nil != _proxyClass){
                    
                    objc_registerClassPair(_proxyClass);
                }else if(nil == (_proxyClass = objc_getClass(proxyClassName.UTF8String))){///Proxy already exists.
                    
                    NSAssert(_proxyClass, @"Can not register class(:%@) at runtime.",proxyClassName);
                }
                
                object_setClass(_instance, _proxyClass);
            }else{
                
                _proxyClass = [_instance class];
            }
        }
        
        oldIMP
        =
        class_replaceMethod(_proxyClass
                            , des_sel
                            , implementation
                            , methodEnc.UTF8String);
        if(nil == oldIMP){
            
            oldIMP = class_getMethodImplementation(_des_class, des_sel);
        }
    }
    
    if(option == AutoPropertyTriggerOfGetter){
        
        _old_getter_implementation         = oldIMP;
    }else{
        
        _old_setter_implementation  = oldIMP;
    }
}

- (_Nullable id)performOldSetterFromTarget:(_Nonnull id)target
{
    if(NO == (_new_getter_implementation && _old_getter_implementation)){
        
        return nil;
    }
    
    return
    
    apc_getterimp_boxinvok(target
                           , NSSelectorFromString(_des_method_name)
                           , _old_getter_implementation
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

+ (void)unhookClassAllProperties:(Class)clazz
{
    clazz  = [self unproxyClass:clazz];
    
    [[_cacheForClass propertiesForSrcclass:clazz] makeObjectsPerformSelector:@selector(unhook)];
}

- (void)tryUnhook
{
    if(_triggerOption == AutoPropertyNonTrigger){
        
        [self unhook];
    }
}

/**
 Only one hook,just remove all infomation.
 */
- (void)unhook
{
    
    [self invalid];
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        [self unhookForClass];
        [self removeFromClassCache];
    }else{
        
        if(NO == [AutoTriggerPropertyInfo testingProxyClassInstance:_instance]){
            ///Instance has been unbound by other threads.
            return;
        }
        [self unhookForInstance];
        [self removeFromInstanceCache];
    }
}

- (void)unhookForClass
{
    _new_getter_implementation = nil;
    
    NSUInteger count
    =
    (YES == (self.triggerOption & AutoPropertyTriggerOfGetter))
    +
    (YES == (self.triggerOption & AutoPropertyTriggerOfSetter));
    
    while (count--) {
        
        class_replaceMethod(_des_class
                            , NSSelectorFromString(count==1?_des_method_name:_des_setter_name)
                            , _old_getter_implementation
                            , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
    }
}

- (void)unhookForInstance
{
    object_setClass(_instance, _des_class);
    objc_disposeClassPair([_instance class]);
}

#pragma mark - cache strategy

- (void)cacheToInstanceMapper
{
    [APCInstancePropertyCacheManager bindProperty:self
                                       toInstance:_instance
                                              cmd:_des_method_name];
    
    if(self.triggerOption & AutoPropertyTriggerOfSetter){
        
        [APCInstancePropertyCacheManager bindProperty:self
                                           toInstance:_instance
                                                  cmd:_des_setter_name];
    }
}

- (void)removeFromInstanceCache
{
    [APCInstancePropertyCacheManager boundPropertyRemoveFromInstance:_instance
                                                                 cmd:_des_method_name];
    
    if(NO == [APCInstancePropertyCacheManager boundContainsValidPropertyForInstance:_instance]){
        
        [APCInstancePropertyCacheManager boundAllPropertiesRemoveFromInstance:_instance];
    }
}

static APCClassPropertyMapperController* _cacheForClass;
- (void)cacheToClassMapper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cacheForClass     =   [APCClassPropertyMapperController cache];
    });
    
    [_cacheForClass addProperty:self];
}

+ (_Nullable instancetype)cachedTargetClass:(Class)clazz
                                   property:(NSString*)property
{
    clazz = [AutoTriggerPropertyInfo unproxyClass:clazz];
    
    return [_cacheForClass propertyForDesclass:clazz property:property];
}

+ (instancetype)cachedFromAClass:(Class)aClazz
                        property:(NSString *)property
{
    aClazz = [AutoTriggerPropertyInfo unproxyClass:aClazz];
    
    return [_cacheForClass searchFromTargetClass:aClazz property:property];
}

- (void)removeFromClassCache
{
    [_cacheForClass removeProperty:self];
}

#pragma mark - APCPropertyMapperKeyProtocol
- (NSSet<APCPropertyMapperkey *> *)propertyMapperkeys
{
    NSMutableSet* set = [NSMutableSet set];
    
    [set addObject:[APCPropertyMapperkey keyWithClass:_des_class
                                             property:_des_method_name]];
    
    if(self.triggerOption & AutoPropertyTriggerOfSetter){
        
        [set addObject:[APCPropertyMapperkey keyWithClass:_des_class
                                                 property:_des_setter_name]];
    }
    
    return set;
}


#pragma mark - AutoPropertyHookProxyClassNameProtocol
- (NSString*)proxyClassName
{
    //Class+APCProxyClass.hash
    return [NSString stringWithFormat:@"%@%@.%lu"
            , NSStringFromClass(_des_class)
            , APCClassSuffixForTrigger
            , (unsigned long)[_instance hash]];
}

+ (Class)unproxyClass:(Class)clazz
{
    NSString* className = NSStringFromClass(clazz);
    
    if([className containsString:APCClassSuffixForTrigger]){
        
        className = [className substringToIndex:[className rangeOfString:@"+"].location];
        
        clazz = NSClassFromString(className);
    }
    return clazz;
}

+ (BOOL)testingProxyClassInstance:(id)instance
{
    return [NSStringFromClass([instance class]) containsString:APCClassSuffixForTrigger];
}

@end

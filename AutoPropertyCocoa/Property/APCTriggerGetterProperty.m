//
//  APCTriggerGetterProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/30.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "APCInstancePropertyCacheManager.h"
#import "APCClassPropertyMapperController.h"
#import "APCTriggerGetterProperty.h"
#import "APCScope.h"

id    _Nullable apc_trigger_getter         (_Nullable id _self,SEL __cmd);
void* _Nullable apc_trigger_getter_impimage(NSString* eType);

id    _Nullable apc_trigger_setter         (_Nullable id _self,SEL __cmd);
void* _Nullable apc_trigger_setter_impimage(NSString* eType);

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
        
        _kindOfUserHook     = APCPropertyHookKindOfIMP;
        _triggerOption  = APCPropertyNonTrigger;
        _methodStyle    = APCMethodGetterStyle;
        _hooked_name       = _des_getter_name;
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

#pragma mark - Hook
//- (void)hook
//{
//    IMP newimp = nil;
//
//    if(nil == _old_getter_implementation
//       && self.triggerOption & APCPropertyTriggerOfGetter){
//
//        if(self.kindOfValue == APCPropertyValueKindOfBlock
//           || self.kindOfValue == APCPropertyValueKindOfObject){
//
//            newimp = (IMP)apc_trigger_getter;
//        }else{
//
//            newimp = (IMP)apc_trigger_getter_impimage(self.valueTypeEncoding);
//        }
//        [self hookPropertyWithImplementation:newimp option:APCPropertyTriggerOfGetter];
//        goto CACHE;
//    }
//
//    if(nil == _old_setter_implementation
//       && self.triggerOption & APCPropertyTriggerOfSetter){
//
//        if(self.kindOfValue == APCPropertyValueKindOfBlock
//           || self.kindOfValue == APCPropertyValueKindOfObject){
//
//            newimp = (IMP)apc_trigger_setter;
//        }else{
//
//            newimp = (IMP)apc_trigger_setter_impimage(self.valueTypeEncoding);
//        }
//        [self hookPropertyWithImplementation:newimp option:APCPropertyTriggerOfSetter];
//        goto CACHE;
//    }
//
//    return;
//
//CACHE:
//    {
//
//        if(_kindOfOwner == APCPropertyOwnerKindOfClass){
//
//            [self cacheToClassMapper];
//        }else{
//
//            [self cacheToInstanceMapper];
//        }
//        return;
//    }
//}

//- (void)hookPropertyWithImplementation:(IMP)implementation option:(NSUInteger)option
//{

//    NSMutableString*    methodEnc   = [NSMutableString string];
//    NSString*           des_name    = nil;
//    SEL                 des_sel     = nil;
//    IMP                 oldIMP      = nil;
//    if(option == APCPropertyTriggerOfGetter){
//
//        [methodEnc appendString:self.valueTypeEncoding];
//        _new_getter_implementation = implementation;
//        des_name = _des_getter_name;
//        des_sel = NSSelectorFromString(des_name);
//    }
//    [methodEnc appendString:@"@:"];
//    if(option == APCPropertyTriggerOfSetter){
//
//        [methodEnc appendString:self.valueTypeEncoding];
//        _new_setter_implementation = implementation;
//        des_name = _des_setter_name;
//        des_sel = NSSelectorFromString(des_name);
//    }
//
//
//    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
//
//        oldIMP
//        =
//        class_replaceMethod(_des_class
//                            , des_sel
//                            , implementation
//                            , methodEnc.UTF8String);
//
//        if(nil == oldIMP){
//
//            APCTriggerGetterProperty* pinfo_superclass
//            =
//            [_cacheForClass propertyForDesclass:_src_class property:des_name];
//
//            if(nil != pinfo_superclass){
//
//                oldIMP =
//                (option == APCPropertyTriggerOfGetter)
//                ? pinfo_superclass->_old_getter_implementation
//                : pinfo_superclass->_old_setter_implementation;
//
//            }else{
//
//                oldIMP = class_getMethodImplementation(_src_class, des_sel);
//            }
//        }
//    }
//    else{
//
//        if(nil == _proxyClass){
//
//            if(NO == [APCTriggerGetterProperty testingProxyClassInstance:_instance]){
//
//                NSString *proxyClassName = self.proxyClassName;
//                _proxyClass = objc_allocateClassPair(_des_class, proxyClassName.UTF8String, 0);
//                if(nil != _proxyClass){
//
//                    objc_registerClassPair(_proxyClass);
//                }else if(nil == (_proxyClass = objc_getClass(proxyClassName.UTF8String))){///Proxy already exists.
//
//                    NSAssert(_proxyClass, @"Can not register class(:%@) at runtime.",proxyClassName);
//                }
//
//                object_setClass(_instance, _proxyClass);
//            }else{
//
//                _proxyClass = [_instance class];
//            }
//        }
//
//        oldIMP
//        =
//        class_replaceMethod(_proxyClass
//                            , des_sel
//                            , implementation
//                            , methodEnc.UTF8String);
//        if(nil == oldIMP){
//
//            oldIMP = class_getMethodImplementation(_des_class, des_sel);
//        }
//    }
//
//    if(option == APCPropertyTriggerOfGetter){
//
//        _old_getter_implementation         = oldIMP;
//    }else{
//
//        _old_setter_implementation  = oldIMP;
//    }
//}

- (_Nullable id)performOldGetterFromTarget:(_Nonnull id)target
{
    return nil;
//    if(NO == (_new_getter_implementation && _old_getter_implementation)){
//
//        return nil;
//    }
//
//    return
//
//    apc_getterimp_boxinvok(target
//                           , NSSelectorFromString(_des_getter_name)
//                           , _old_getter_implementation
//                           , self.valueTypeEncoding.UTF8String);
}

- (void)performOldSetterFromTarget:(_Nonnull id)target withValue:(id _Nullable)value
{
//    if(NO == (_new_setter_implementation && _old_setter_implementation)){
//
//        return;
//    }
//
//    apc_setterimp_boxinvok(target
//                           , NSSelectorFromString(_des_setter_name)
//                           , _old_setter_implementation
//                           , self.valueTypeEncoding.UTF8String
//                           , value);
}

//+ (void)unhookClassAllProperties:(Class)clazz
//{
//    clazz  = [self unproxyClass:clazz];
//
//    [[_cacheForClass propertiesForSrcclass:clazz] makeObjectsPerformSelector:@selector(unhook)];
//}

//- (void)tryUnhook
//{
//    if(_triggerOption == APCPropertyNonTrigger){
//
//        [self unhook];
//    }
//}

/**
 Only one hook,just remove all infomation.
 */
//- (void)unhook
//{
//
//    [self invalid];
//    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
//
//        [self unhookForClass];
//        [self removeFromClassCache];
//    }else{
//
//        if(NO == [APCTriggerGetterProperty testingProxyClassInstance:_instance]){
//            ///Instance has been unbound by other threads.
//            return;
//        }
//        [self unhookForInstance];
//        [self removeFromInstanceCache];
//    }
//}

//- (void)unhookForClass
//{
//    _new_getter_implementation = nil;
//    
//    NSUInteger count
//    =
//    (YES == (self.triggerOption & APCPropertyTriggerOfGetter))
//    +
//    (YES == (self.triggerOption & APCPropertyTriggerOfSetter));
//    
//    while (count--) {
//        
//        class_replaceMethod(_des_class
//                            , NSSelectorFromString(count==1?_des_getter_name:_des_setter_name)
//                            , _old_getter_implementation
//                            , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
//    }
//}

- (void)unhookForInstance
{
    object_setClass(_instance, _des_class);
    objc_disposeClassPair([_instance class]);
}

#pragma mark - cache strategy

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


#pragma mark - APCPropertyHookProxyClassNameProtocol
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

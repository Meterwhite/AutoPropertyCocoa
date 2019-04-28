//
//  APCPropertyHook.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerGetterProperty.h"
#import "APCTriggerSetterProperty.h"
#import "APCPropertyHook.h"
#import "APCLazyProperty.h"
#import <objc/message.h>
#import "APCRuntime.h"
#import "APCScope.h"

id _Nullable apc_propertyhook_getter(_Nullable id _SELF,SEL _Nonnull _CMD)
{
    APCPropertyHook* hook;
    NSString*        _CMD_s = NSStringFromSelector(_CMD);
    if(YES == apc_object_isProxyInstance(_SELF)){
        
        hook = apc_lookup_instancePropertyhook(_SELF, _CMD_s);
    }else if(nil == (hook = apc_lookup_propertyhook(object_getClass(_SELF), _CMD_s))){
        
        NSCAssert(NO, @"APC: BAD ACCESS.APC has lost this valid property.");
    }
    
    
    if(hook.isEmpty){
        
        return [apc_propertyhook_rootHook(hook) performOldGetterFromTarget:_SELF];
    }
    
    APCTriggerGetterProperty*   p_trigger   = hook.getterTrigger;
    APCLazyProperty*            p_lazy      = hook.lazyload;
    
    /** ----------------Future----------------- */
    if(p_trigger != nil){
        
        if(p_trigger.triggerOption & APCPropertyGetterFrontTrigger) {
            
            [p_trigger performGetterFrontTriggerBlock:_SELF];
        }
    }
    
    /** ----------------Happen----------------- */
    id val = [hook performOldGetterFromTarget:_SELF];
    
    
    /** ----------------Affect----------------- */
    if(p_lazy != nil){
        
        val = [p_lazy performLazyloadForTarget:_SELF oldValue:val];
        [p_lazy access];
    }
    
    /** ----------------Result----------------- */
    if(p_trigger != nil){
        
        if(p_trigger.triggerOption & APCPropertyGetterPostTrigger){
            
            [p_trigger performGetterPostTriggerBlock:_SELF value:val];
        }
        
        if(p_trigger.triggerOption & APCPropertyGetterUserTrigger){
            
            if(YES == [p_trigger performGetterUserConditionBlock:_SELF value:val]){
                
                [p_trigger performGetterUserTriggerBlock:_SELF value:val];
            }
        }
        
        if(p_trigger.triggerOption & APCPropertyGetterCountTrigger){
            
            if(YES == [p_trigger performGetterCountConditionBlock:_SELF value:val]){
                
                [p_trigger performGetterCountTriggerBlock:_SELF value:val];
            }
        }
        
        [p_trigger access];
    }
    
    return val;
}
apc_def_vGHook_and_impimage(apc_propertyhook_getter)

void apc_propertyhook_setter(_Nullable id _SELF,SEL _Nonnull _CMD,id _Nullable value)
{
    
}
apc_def_vSHook_and_impimage(apc_propertyhook_setter)


@implementation APCPropertyHook
{
#warning add lock
    const char*             _methodTypeEncoding;
    NSString*               _valueTypeEncoding;
    APCPropertyValueKind    _kindOfValue;
    APCPropertyOwnerKind    _kindOfOwner;
    APCMethodStyle          _methodStyle;
    _Atomic(void*)          _getterTrigger;
    _Atomic(void*)          _setterTrigger;
    _Atomic(void*)          _lazyload;
    __weak id               _instance;
    dispatch_semaphore_t    _l_lock;
    dispatch_semaphore_t    _r_lock;
    dispatch_semaphore_t    _w_lock;
}

+ (instancetype)hookWithProperty:(APCHookProperty *)property
{
    return [[self alloc] initWithProperty:property];
}

- (instancetype)initWithProperty:(__kindof APCHookProperty *)property
{
    self = [super init];
    if (self) {
        
        NSAssert((_hookclass == property->_des_class) && ([_hookMethod isEqualToString:property->_hooked_name])
                 , @"APC: Mismatched type or property.");
        
        NSAssert(property.inlet != nil, @"APC: Undefined behavior!");
        
        ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, property);
        
        _l_lock         = dispatch_semaphore_create(1);
        _source_class   = property->_src_class;
        _hookclass      = property->_des_class;
        _hookMethod     = property->_hooked_name;
        _kindOfValue    = property.kindOfValue;
        _kindOfOwner    = property.kindOfOwner;
        _methodStyle    = property.methodStyle;
        _valueTypeEncoding  = property.valueTypeEncoding;
        _methodTypeEncoding = property.methodTypeEncoding.UTF8String;
        
        if(_kindOfOwner == APCPropertyOwnerKindOfInstance){
            
            _instance = property->_instance;
        }
        
        [self hook];
    }
    return self;
}

- (Class)sourceclass
{
    return _source_class;
}

- (void)setLazyload:(APCLazyProperty *)lazyload
{
    void* desired = (void*)CFBridgingRetain(lazyload);
    while (YES) {
        
        void* expected = _lazyload;
        if(atomic_compare_exchange_strong(&_lazyload, &expected, desired)){
            
            if(desired == nil){
                
                ((__bridge APCLazyProperty *)expected).associatedHook = self;
                CFRelease(expected);
            }else{
                
                lazyload.associatedHook = self;
            }
            break;
        }
    }
}

- (APCLazyProperty *)lazyload
{
    APCLazyProperty *p = CFBridgingRelease(&_lazyload);
    if(p.enable == NO){
        
        return nil;
    }
    return p;
}

- (void)setGetterTrigger:(APCTriggerGetterProperty *)getterTrigger
{
    void* desired = (void*)CFBridgingRetain(getterTrigger);
    while (YES) {
        
        void* expected = _getterTrigger;
        if(atomic_compare_exchange_strong(&_getterTrigger, &expected, desired)){
            
            if(desired == nil){
                
                ((__bridge APCTriggerGetterProperty *)expected).associatedHook = self;
                CFRelease(expected);
            }else{
                
                getterTrigger.associatedHook = self;
            }
            break;
        }
    }
}

- (APCTriggerGetterProperty *)getterTrigger
{
    APCTriggerGetterProperty *p = CFBridgingRelease(_getterTrigger);
    if(p.enable == NO){
        
        return nil;
    }
    return p;
}

- (void)setSetterTrigger:(APCTriggerSetterProperty *)setterTrigger
{
    void* desired = (void*)CFBridgingRetain(setterTrigger);
    while (YES) {
        
        void* expected = _setterTrigger;
        if(atomic_compare_exchange_strong(&_setterTrigger, &expected, desired)){
            
            if(desired == nil){
                
                ((__bridge APCTriggerSetterProperty *)expected).associatedHook = self;
                CFRelease(expected);
            }else{
                
                setterTrigger.associatedHook = self;
            }
            break;
        }
    }
}

- (APCTriggerSetterProperty *)setterTrigger
{
    APCTriggerSetterProperty * p = CFBridgingRelease(_setterTrigger);
    if(p.enable == NO){
        
        return nil;
    }
    return p;
}

- (void)bindProperty:(__kindof APCHookProperty *)property
{
    
    NSAssert((_hookclass == property->_des_class) && ([_hookMethod isEqualToString:property->_hooked_name])
             , @"APC: Mismatched type or property.");
    
    NSAssert(property.inlet != nil, @"APC: Undefined behavior!");
    
    ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, property);
    
}

- (void)unbindProperty:(__kindof APCHookProperty *)property
{
    NSAssert((_hookclass == property->_des_class) && ([_hookMethod isEqualToString:property->_hooked_name])
             , @"APC: Mismatched type or property.");
    
    NSAssert(property.inlet != nil, @"APC: Undefined behavior!");

    [property invalid];
    
    @autoreleasepool {
        
        ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, nil);
        if(self.isEmpty){

            [self unhook];
        }
    }
}

- (BOOL)isEmpty
{
    return (_lazyload || _getterTrigger || _setterTrigger);
}

- (void)hook
{
    IMP newimp;
    if(_kindOfValue == APCPropertyValueKindOfBlock ||
       _kindOfValue == APCPropertyValueKindOfObject){
        
        newimp = (_methodStyle == APCMethodGetterStyle)
        ? (IMP)apc_propertyhook_getter
        : (IMP)apc_propertyhook_setter;
    }else{
        
        newimp = (_methodStyle == APCMethodGetterStyle)
        ? (IMP)apc_propertyhook_getter_impimage(_valueTypeEncoding)
        : (IMP)apc_propertyhook_setter_impimage(_valueTypeEncoding);
    }
    
    _new_implementation = newimp;
    
    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
        
        _old_implementation
        =
        class_replaceMethod(_hookclass
                            , NSSelectorFromString(_hookMethod)
                            , _new_implementation
                            , _methodTypeEncoding);
        if(nil == _old_implementation){
            
            ///Overwrite super class property with new property.
            ///Storing the implementation address of the super class
            
            ///Superclass and subclass used the same old implementation that is from superclass.
            
            APCPropertyHook* sourcehook
            = apc_lookup_firstPropertyhook_inRange(class_getSuperclass(_hookclass)
                                            , _source_class
                                            , _hookMethod);
            if(nil != sourcehook){
                
                _old_implementation = sourcehook->_old_implementation;
            }else{
                
                _old_implementation
                =
                class_getMethodImplementation(_source_class
                                              , NSSelectorFromString(_hookMethod));
            }
            
            NSAssert(_old_implementation, @"APC: Can not find original implementation.");
        }
    }else{
        
        if(NO == apc_object_isProxyInstance(_instance)){
            
            _proxyClass = apc_object_hookWithProxyClass(_instance);
        }else{
            
            _proxyClass = object_getClass(_instance);
        }
        
        _old_implementation
        =
        class_replaceMethod(_proxyClass
                            , NSSelectorFromString(_hookMethod)
                            , _new_implementation
                            , _methodTypeEncoding);
        if(nil == _old_implementation){
            
            APCPropertyHook* sourcehook
            = apc_lookup_firstPropertyhook_inRange(class_getSuperclass(_hookclass)
                                            , _source_class
                                            , _hookMethod);
            if(nil != sourcehook){
                
                _old_implementation = sourcehook->_old_implementation;
            }else{
                
                _old_implementation
                =
                class_getMethodImplementation(_source_class
                                              , NSSelectorFromString(_hookMethod));
            }
        }
    }
}

- (void)unhook
{
    if(nil == _old_implementation || nil == _new_implementation){
        
        return;
    }
    
    if(_kindOfOwner == APCPropertyOwnerKindOfClass)
    {
        _new_implementation = nil;
        
        class_replaceMethod(_hookclass
                            , NSSelectorFromString(_hookMethod)
                            , _old_implementation
                            , _methodTypeEncoding);
    }
    else
    {
        if(YES == apc_object_isProxyInstance(_instance)){
            
            apc_class_disposeProxyClass(apc_instance_unhookFromProxyClass(_instance));
        }
    }
}

- (void)dealloc
{
    _instance           = nil;
    
    if(_lazyload != nil){
        
        CFRelease(_lazyload);
    }
    
    if(_getterTrigger != nil){
        
        CFRelease(_getterTrigger);
    }
    
    if(_setterTrigger != nil){
        
        CFRelease(_setterTrigger);
    }
    
    if(_kindOfOwner == APCPropertyOwnerKindOfInstance){
        
        [self disposeRuntimeResource];
    }
}

- (void)disposeRuntimeResource
{
    if(_proxyClass != nil){
        
        apc_class_disposeProxyClass(_proxyClass);
    }
}

- (void)performOldSetterFromTarget:(id)target withValue:(id)value
{
    if(NO == (_new_implementation && _old_implementation)){
        
        return;
    }
    
    apc_setterimp_boxinvok(target
                           , NSSelectorFromString(_hookMethod)
                           , _old_implementation
                           , _valueTypeEncoding.UTF8String
                           , value);
}

- (id)performOldGetterFromTarget:(id)target
{
    if(NO == (_new_implementation && _old_implementation)){
        
        return nil;
    }
    
    return
    
    apc_getterimp_boxinvok(target
                           , NSSelectorFromString(_hookMethod)
                           , _old_implementation
                           , _valueTypeEncoding.UTF8String);
}
@end

// perform old
//    if(NO == (_new_getter_implementation && _old_getter_implementation)){
//
//        return nil;
//    }
//
//    [APCLazyloadOldLoopController joinLoop:target];
//
//    id ret
//    =
//    apc_getterimp_boxinvok(target
//                           , NSSelectorFromString(_des_getter_name)
//                           , _old_getter_implementation
//                           , self.valueTypeEncoding.UTF8String);
//
//    [APCLazyloadOldLoopController breakLoop:target];
//
//    return ret;

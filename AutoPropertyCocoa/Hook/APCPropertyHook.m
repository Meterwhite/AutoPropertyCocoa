//
//  APCPropertyHook.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerGetterProperty.h"
#import "APCTriggerSetterProperty.h"
#import "apc-objc-private.h"
#import "APCPropertyHook.h"
#import "APCLazyProperty.h"
#import <objc/message.h>
#import "APCExtScope.h"
#import "APCRuntime.h"
#import "APCScope.h"

id _Nullable apc_null_getter(id _Nullable _SELF,SEL _Nonnull _CMD)
{
    Class cls = object_getClass(_SELF);
    IMP imp;
    do {
        
        if(nil != (imp = class_itMethodImplementation_APC(cls, _CMD)))
            
            if(imp != (IMP)apc_null_getter)
                
                break;
    } while ((void)(imp = nil), nil != (cls = class_getSuperclass(cls)));
    
    if(nil != imp){
        
        return ((id(*)(id,SEL))imp)(_SELF, _CMD);
    }
    
    return nil;
}

id _Nullable apc_propertyhook_getter(id _Nullable _SELF,SEL _Nonnull _CMD)
{
    APCPropertyHook* hook;
    NSString*        _CMD_s = @((const char*)(const void*)_CMD);
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
    id val = nil;
    if(p_lazy != nil){
        
        val = [p_lazy performLazyloadForTarget:_SELF];
        [p_lazy access];
    }else{
        
        val = [hook performOldGetterFromTarget:_SELF];
    }
    /** ----------------Affect----------------- */
    //Nothing.
    
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

APC_Define_BasicValueHookOfGetter_Define_HookIMPMapper_UsingTemplate
(APCTemplate_NSNumber_HookOfGetter,APCTemplate_NSValue_HookOfGetter,
 apc_propertyhook_getter
)

void apc_null_setter(id _Nullable _SELF,SEL _Nonnull _CMD, id _Nullable value)
{
    Class cls = object_getClass(_SELF);
    IMP imp;
    do {
        
        if(nil != (imp = class_itMethodImplementation_APC(cls, _CMD)))
            
            if(imp != (IMP)apc_null_setter)
                
                break;
    } while ((void)(imp = nil), nil != (cls = class_getSuperclass(cls)));
    
    if(nil != imp){
        
        ((void(*)(id,SEL,id))imp)(_SELF, _CMD, value);
    }
}

void apc_propertyhook_setter(_Nullable id _SELF,SEL _Nonnull _CMD,id _Nullable value)
{
    
}
APC_Define_BasicValueHookOfSetter_Define_HookIMPMapper_UsingTemplate
(APCTemplate_NSNumber_HookOfSetter,APCTemplate_NSValue_HookOfSetter,
 apc_propertyhook_setter
 )

@implementation APCPropertyHook
{
    const char*             _methodTypeEncoding;
    NSString*               _valueTypeEncoding;
    APCPropertyValueKind    _kindOfValue;
    APCPropertyOwnerKind    _kindOfOwner;
    APCMethodStyle          _methodStyle;
    _Atomic(void*)          _getterTrigger;
    _Atomic(void*)          _setterTrigger;
    _Atomic(void*)          _lazyload;
    __weak id               _instance;
}

+ (instancetype)hookWithProperty:(APCHookProperty *)property
{
    return [[self alloc] initWithProperty:property];
}

- (instancetype)initWithProperty:(__kindof APCHookProperty *)property
{
    self = [super init];
    if (self) {
        
        NSAssert(property.inlet != nil, @"APC: Undefined behavior!");
        
        ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, property);
        
        _source_class   = property->_src_class;
        _hookclass      = property->_des_class;
        _hookMethod     = property->_hooked_name;
        _kindOfValue    = property.kindOfValue;
        _kindOfOwner    = property.kindOfOwner;
        _methodStyle    = property.methodStyle;
        _valueTypeEncoding  = property.valueTypeEncoding;
        _methodTypeEncoding = property.methodTypeEncoding.UTF8String;
        
        if(_kindOfOwner == APCPropertyOwnerKindOfInstance) {
            
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
                [self tryUnhook];
            }else{
                
                lazyload.associatedHook = self;
            }
            break;
        }
    }
}

- (APCLazyProperty *)lazyload
{
    APCLazyProperty *p = (__bridge APCLazyProperty *)(_lazyload);
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
                [self tryUnhook];
            }else{
                
                getterTrigger.associatedHook = self;
            }
            break;
        }
    }
}

- (APCTriggerGetterProperty *)getterTrigger
{
    APCTriggerGetterProperty *p = (__bridge APCTriggerGetterProperty *)(_getterTrigger);
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
                [self tryUnhook];
            }else{
                
                setterTrigger.associatedHook = self;
            }
            break;
        }
    }
}

- (APCTriggerSetterProperty *)setterTrigger
{
    APCTriggerSetterProperty * p = (__bridge APCTriggerSetterProperty *)(_setterTrigger);
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
    }
    [self tryUnhook];
}

- (BOOL)isEmpty
{
    return !(_lazyload || _getterTrigger || _setterTrigger);
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
        ? (IMP)apc_propertyhook_getter_HookIMPMapper(_valueTypeEncoding)
        : (IMP)apc_propertyhook_setter_HookIMPMapper(_valueTypeEncoding);
    }
    
    _new_implementation = newimp;
    
    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
        
        _old_implementation
        =
        class_replaceMethod(_hookclass
                            , NSSelectorFromString(_hookMethod)
                            , _new_implementation
                            , _methodTypeEncoding);
    }else{
        
        ///APCPropertyOwnerKindOfInstance
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
    }
}

- (void)tryUnhook
{
    if(self.isEmpty){
        
        [self unhook];
    }
}

- (void)unhook
{
    if(nil == _new_implementation)
    {
        return;
    }
    
    IMP newImp = _new_implementation;
    if(atomic_compare_exchange_strong(&_new_implementation, &newImp, nil))
    {
        if(_kindOfOwner == APCPropertyOwnerKindOfClass)
        {

//            class_replaceMethod(_hookclass
//                                , NSSelectorFromString(_hookMethod)
//                                , self.restoredImplementation
//                                , _methodTypeEncoding);
            
#if APCRealUnbindButNoRuntimelock
            
            class_removeMethod_APC_OBJC2_NONRUNTIMELOCK
            (_hookclass
             , NSSelectorFromString(_hookMethod));
#else
            
            
#endif
            
        }
        else
        {
            if(YES == apc_object_isProxyInstance(_instance))
            {
                apc_class_disposeProxyClass(apc_instance_unhookFromProxyClass(_instance));
            }
        }
    }
}

- (IMP)restoredImplementation
{
    /**
     . Is APC inheritance?
     . Self is source implementation?
     . Can search a hook that is source implementation?
     . Use source class implementation!
     */
    APCPropertyHook* hook
    = apc_lookup_superPropertyhook_inRange(_hookclass
                                           , _source_class
                                           , _hookMethod);
    if(hook != nil){
        
        return hook->_new_implementation;
    }
    
    
    if(_old_implementation){
        
        return _old_implementation;
    }
    
    hook =
    apc_lookup_implementationPropertyhook_inRange(apc_class_getSuperclass(_hookclass)
                                                  , _source_class
                                                  , _hookMethod);
    if(hook != nil){
        
        return hook->_old_implementation;
    }
    
    return
    
    class_getMethodImplementation(_source_class
                                  , NSSelectorFromString(_hookMethod));
}

- (IMP)oldImplementation
{
    if(_old_implementation){
        
        return _old_implementation;
    }
    
    APCPropertyHook* hook
    =
    apc_lookup_implementationPropertyhook_inRange(apc_class_getSuperclass(_hookclass)
                                                  , _source_class
                                                  , _hookMethod);
    if(hook != nil){
        
        return hook->_old_implementation;
    }
    
    return
    
    class_getMethodImplementation(_source_class
                                  , NSSelectorFromString(_hookMethod));
}

- (void)performOldSetterFromTarget:(id)target withValue:(id)value
{
    if(NO == (_new_implementation && _old_implementation)){
        
        return;
    }
    
    apc_setterimp_boxinvok(target
                           , NSSelectorFromString(_hookMethod)
                           , self.oldImplementation
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
                           , self.oldImplementation
                           , _valueTypeEncoding.UTF8String);
}


- (void)dealloc
{
    _instance = nil;
    
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
        _proxyClass = nil;
    }
}
@end

//
//  APCPropertyHook.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCTriggerGetterProperty.h"
#import "APCTriggerSetterProperty.h"
#import "apc-objc-extension.h"
#import "APCPropertyHook.h"
#import "APCLazyProperty.h"
#import <objc/message.h>
#import "apc-objc-os.h"
#import "APCExtScope.h"
#import "APCRuntime.h"
#import "APCScope.h"


id _Nullable apc_propertyhook_getter(id _Nullable _SELF,SEL _Nonnull _CMD)
{
    APCPropertyHook*    hook    =   nil;
    NSString*           cmdstr  =   @((const char*)(const void*)_CMD);
    if(YES == apc_object_isProxyInstance(_SELF)){
        
        hook = apc_lookup_instancePropertyhook(_SELF, cmdstr);
    }else if(nil == (hook = apc_lookup_propertyhook(object_getClass(_SELF), cmdstr))){
        
        @throw
        
        [NSException exceptionWithName:NSGenericException
                                reason:@"APC can not find any infomation about this  property."
                              userInfo:nil];
    }
    
    
    if(hook.isEmpty){
        ///If unbind in other threads.
        return [hook performOldGetterFromTarget:_SELF];
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
APCDefBasicValueGetterVersionAndHookIMPMapper(APCTemplate_NSNumber_HookOfGetter,
                                               APCTemplate_NSValue_HookOfGetter,
                                               apc_propertyhook_getter)

void apc_propertyhook_setter(_Nullable id _SELF,SEL _Nonnull _CMD,id _Nullable value)
{
    APCPropertyHook*    hook    =   nil;
    NSString*           cmdstr  =   @((const char*)(const void*)_CMD);
    if(YES == apc_object_isProxyInstance(_SELF)){
        
        hook = apc_lookup_instancePropertyhook(_SELF, cmdstr);
    }else if(nil == (hook = apc_lookup_propertyhook(object_getClass(_SELF), cmdstr))){
        
        @throw
        
        [NSException exceptionWithName:NSGenericException
                                reason:@"APC can not find any infomation about this property."
                              userInfo:nil];
    }
    
    
    if(hook.isEmpty){
        
        return [hook performOldSetterFromTarget:_SELF withValue:value];
    }
    
    APCTriggerSetterProperty*   p_trigger   = hook.setterTrigger;
    
    /** ----------------Future----------------- */
    if(p_trigger != nil){
        
        if(p_trigger.triggerOption & APCPropertySetterFrontTrigger) {
            
            [p_trigger performSetterFrontTriggerBlock:_SELF value:value];
        }
    }
    
    /** ----------------Happen----------------- */
    [hook performOldSetterFromTarget:_SELF withValue:value];
    
    /** ----------------Affect----------------- */
    //Nothing.
    
    /** ----------------Result----------------- */
    if(p_trigger != nil){
        
        if(p_trigger.triggerOption & APCPropertySetterPostTrigger){
            
            [p_trigger performSetterPostTriggerBlock:_SELF value:value];
        }
        
        if(p_trigger.triggerOption & APCPropertySetterUserTrigger){
            
            if(YES == [p_trigger performSetterUserConditionBlock:_SELF value:value]){
                
                [p_trigger performSetterUserTriggerBlock:_SELF value:value];
            }
        }
        
        if(p_trigger.triggerOption & APCPropertySetterCountTrigger){
            
            if(YES == [p_trigger performSetterCountConditionBlock:_SELF value:value]){
                
                [p_trigger performSetterCountTriggerBlock:_SELF value:value];
            }
        }
        
        [p_trigger access];
    }
}APCDefBasicValueSetterVersionAndHookIMPMapper(APCTemplate_NSNumber_HookOfSetter,
                                               APCTemplate_NSValue_HookOfSetter,
                                               apc_propertyhook_setter)


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
    
    return (id)0;
}APCDefBasicValueGetterVersionAndHookIMPMapper(APCTemplate_NSNumber_NullGetter,
                                               APCTemplate_NSValue_NullGetter,
                                               apc_null_getter)

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
}APCDefBasicValueGetterVersionAndHookIMPMapper(APCTemplate_NSNumber_NullSetter,
                                               APCTemplate_NSValue_NullSetter,
                                               apc_null_setter)


@implementation APCPropertyHook
{
    const char*             _methodTypeEncoding;
    NSString*               _valueTypeEncoding;
    APCPropertyValueKind    _kindOfValue;
    APCPropertyOwnerKind    _kindOfOwner;
    APCMethodStyle          _methodStyle;
    APCAtomicPtr            _getterTrigger;
    APCAtomicPtr            _setterTrigger;
    APCAtomicPtr            _lazyload;
    __weak id               _instance;
}
@synthesize hookclass = _hookclass;
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

- (__kindof APCPropertyHook *)superhook
{
    return _superhook;
}

- (APCPropertyOwnerKind)kindOfOwner
{
    return _kindOfOwner;
}

- (void)bindProperty:(__kindof APCHookProperty *)property
{
    
    NSAssert((_hookclass == property->_des_class) && ([_hookMethod isEqualToString:property->_hooked_name])
             , @"APC: Mismatched type or property.");
    
    NSAssert(property.inlet != nil, @"APC: Undefined behavior!");
    
    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
        
        apc_runtimelock_writer_t writing(apc_runtimelock);
        
        ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, property);
    }else{
        
        ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, property);
    }
}

- (void)unbindProperty:(__kindof APCHookProperty *)property
{
    @autoreleasepool {
        
        NSAssert((_hookclass == property->_des_class) && ([_hookMethod isEqualToString:property->_hooked_name])
                 , @"APC: Mismatched type or property.");
        
        NSAssert(property.inlet != nil, @"APC: Undefined behavior!");
        
        if(_kindOfOwner == APCPropertyOwnerKindOfClass){
            
            apc_runtimelock_writer_t writing(apc_runtimelock);
            ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, nil);
        }else{
            
            ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, nil);
        }
    }
}

- (void)setLazyload:(APCLazyProperty *)lazyload
{
    void* desired = (void*)CFBridgingRetain(lazyload);
    while (YES) {
        
        void* expected = _lazyload;
        if(atomic_compare_exchange_strong(&_lazyload, &expected, desired)){
            
            if(desired == nil){
                
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
    if(_lazyload != NULL){
        
        return (__bridge APCLazyProperty *)(_lazyload);
    }
    
    return apc_propertyhook_lookupSuperProperty(self, "_lazyload");
}

- (void)setGetterTrigger:(APCTriggerGetterProperty *)getterTrigger
{
    void* desired = (void*)CFBridgingRetain(getterTrigger);
    while (YES) {
        
        void* expected = _getterTrigger;
        if(atomic_compare_exchange_strong(&_getterTrigger, &expected, desired)){
            
            if(desired == nil){
                
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
    if(_getterTrigger != NULL){
        
        return (__bridge APCTriggerGetterProperty *)(_getterTrigger);
    }
    
    return apc_propertyhook_lookupSuperProperty(self, "_getterTrigger");
}

- (void)setSetterTrigger:(APCTriggerSetterProperty *)setterTrigger
{
    void* desired = (void*)CFBridgingRetain(setterTrigger);
    while (YES) {
        
        void* expected = _setterTrigger;
        if(atomic_compare_exchange_strong(&_setterTrigger, &expected, desired)){
            
            if(desired == nil){
                
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
    if(_setterTrigger != NULL){
        
        return (__bridge APCTriggerSetterProperty *)(_setterTrigger);
    }
    
    return apc_propertyhook_lookupSuperProperty(self, "_setterTrigger");
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
        
        APCProxyClass iProxyClass;
        if(NO == apc_object_isProxyInstance(_instance)){
            
            iProxyClass = apc_object_hookWithProxyClass(_instance);
        }else{
            
            iProxyClass = object_getClass(_instance);
        }
        
        _old_implementation
        =
        class_replaceMethod(iProxyClass
                            , NSSelectorFromString(_hookMethod)
                            , _new_implementation
                            , _methodTypeEncoding);
    }
    
    ///Delete the wrong _old_implementation.
    if(!apc_contains_objcruntimelock()){

        IMP cmp = (_methodStyle == APCMethodGetterStyle)
        ? (IMP)apc_null_getter_HookIMPMapper(_valueTypeEncoding)
        : (IMP)apc_null_setter_HookIMPMapper(_valueTypeEncoding);
        
        if(_old_implementation == cmp){
            
            _old_implementation = nil;
        }
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
    NSAssert(_new_implementation != nil, @"APC: Lost _new_implementation.");
    
    IMP newImp = _new_implementation;
    if(atomic_compare_exchange_strong(&_new_implementation, &newImp, nil))
    {
        if(_kindOfOwner == APCPropertyOwnerKindOfClass)
        {
            if(_old_implementation != nil){
                
                //Realized by itself
                class_replaceMethod(_hookclass
                                    , NSSelectorFromString(_hookMethod)
                                    , _old_implementation
                                    , _methodTypeEncoding);
            }else{
                
                ///Not realized by itself
                if(apc_contains_objcruntimelock()){
                    
                    class_removeMethod_APC_OBJC2
                    (self->_hookclass
                     , NSSelectorFromString(self->_hookMethod));
                }else{
                    
                    class_replaceMethod(_hookclass
                                        , NSSelectorFromString(_hookMethod)
                                        , self.restoredImplementation
                                        , _methodTypeEncoding);
                }
            }
            apc_propertyhook_dispose_nolock(self);
        }
        else
        {
            if(YES == apc_object_isProxyInstance(_instance))
            {
                apc_instance_unhookFromProxyClass(_instance);
            }
        }
    }
}

- (IMP)restoredImplementation
{
    if(_old_implementation){
        
        return _old_implementation;
    }
    
    if(_kindOfValue == APCPropertyValueKindOfObject ||
       _kindOfValue == APCPropertyValueKindOfBlock) {
        
        return (_methodStyle == APCMethodGetterStyle)
        ? (IMP)apc_null_getter : (IMP)apc_null_setter;
    }else{
        
        return  (_methodStyle == APCMethodGetterStyle)
        ? (IMP)apc_null_getter_HookIMPMapper(_valueTypeEncoding)
        : (IMP)apc_null_setter_HookIMPMapper(_valueTypeEncoding);
    }
}

- (IMP)oldImplementation
{
    if(_old_implementation){
        
        return _old_implementation;
    }
    
    APCPropertyHook* hook
    =
    apc_lookup_sourcePropertyhook_inRange(apc_class_getSuperclass(_hookclass)
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
    
    APCBoxedInvokeBasicValueSetterIMP(target
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
    
    APCBoxedInvokeBasicValueGetterIMP(target
                           , NSSelectorFromString(_hookMethod)
                           , self.oldImplementation
                           , _valueTypeEncoding.UTF8String);
}

- (void)dealloc
{
    if(_lazyload != nil){
        
        CFRelease(_lazyload);
        atomic_store(&_lazyload, NULL);
    }
    
    if(_getterTrigger != nil){
        
        CFRelease(_getterTrigger);
        atomic_store(&_getterTrigger, NULL);
    }
    
    if(_setterTrigger != nil){
        
        CFRelease(_setterTrigger);
        atomic_store(&_setterTrigger, NULL);
    }
    
    _instance   = nil;
    
    _superhook  = nil;
    
    APCDlog(@"Hook dealoc: %p", self);
}

@end

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
#import "APCExtScope.h"
#import "APCRuntime.h"
#import "APCScope.h"


id _Nullable apc_propertyhook_getter(id _Nullable _SELF,SEL _Nonnull _CMD)
{
    APCPropertyHook*    hook    =   nil;
    NSString*           cmdstr  =   @((const char*)(const void*)_CMD);
    do {
        
        if(apc_object_isProxyInstance(_SELF)){
            
            if(nil != (hook = apc_lookup_instancePropertyhook(_SELF, cmdstr))){
                
                break;
            }
        }
        
        if(nil != (hook = apc_lookup_propertyhook(object_getClass(_SELF), cmdstr))){
            
            break;
        }
        
        @throw
        
        [NSException exceptionWithName:NSGenericException
                                reason:@"APC: Can not find any infomation about this property.The data seems to have been deleted in other threads."
                              userInfo:nil];
    } while (0);
    
    
    if(hook.isGetterEmpty){
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
            
            if([p_trigger performGetterUserConditionBlock:_SELF value:val]){
                
                [p_trigger performGetterUserTriggerBlock:_SELF value:val];
            }
        }
        
        if(p_trigger.triggerOption & APCPropertyGetterCountTrigger){
            
            if([p_trigger performGetterCountConditionBlock:_SELF value:val]){
                
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
    do {
        
        if(apc_object_isProxyInstance(_SELF)){
            
            if(nil != (hook = apc_lookup_instancePropertyhook(_SELF, cmdstr))){
                
                break;
            }
        }
        
        if(nil != (hook = apc_lookup_propertyhook(object_getClass(_SELF), cmdstr))){
            
            break;
        }
        
        @throw
        
        [NSException exceptionWithName:NSGenericException
                                reason:@"APC: Can not find any infomation about this property.The data seems to have been deleted in other threads."
                              userInfo:nil];
    } while (0);
    
    
    if(hook.isSetterEmpty){
        
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
            
            if([p_trigger performSetterUserConditionBlock:_SELF value:value]){
                
                [p_trigger performSetterUserTriggerBlock:_SELF value:value];
            }
        }
        
        if(p_trigger.triggerOption & APCPropertySetterCountTrigger){
            
            if([p_trigger performSetterCountConditionBlock:_SELF value:value]){
                
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
//    const char*             _methodTypeEncoding;
    //    APCMethodStyle          _methodStyle;
    NSString*               _ori_name;
    NSString*               _getter_name;
    NSString*               _setter_name;
    NSString*               _valueTypeEncoding;
    APCPropertyValueKind    _kindOfValue;
    APCPropertyOwnerKind    _kindOfOwner;
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
//        _hookMethod     = property->_hooked_name;
        _kindOfValue    = property.kindOfValue;
        _kindOfOwner    = property.kindOfOwner;
        _valueTypeEncoding  = property.valueTypeEncoding;
        _ori_name       = property->_ori_property_name;
        _getter_name    = property->_des_getter_name;
        _setter_name    = property->_des_setter_name;
        
        if(_kindOfOwner == APCPropertyOwnerKindOfInstance) {
            
            _instance = property->_instance;
        }
        
        [self hook:property.methodStyle];
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

- (NSString *)propertyName
{
    return _ori_name;
}

- (void)bindProperty:(__kindof APCHookProperty *)property
{
    NSAssert(property.inlet != nil, @"APC: Undefined behavior!");
    
    ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, property);
    [self tryHook:property.methodStyle];
}

- (void)unbindProperty:(__kindof APCHookProperty *)property
{
    NSAssert(property.inlet != nil, @"APC: Undefined behavior!");
    
    ((void(*)(id,SEL,id))objc_msgSend)(self, property.inlet, nil);
    [self tryUnhook:property.methodStyle];
}

- (void)setLazyload:(APCLazyProperty *)lazyload
{
    void* desired = (void*)CFBridgingRetain(lazyload);
    while (YES) {
        
        void* expected = _lazyload;
        if(atomic_compare_exchange_strong(&_lazyload, &expected, desired)){
            
            if(desired == nil){
                
//                APCMethodStyle style = ((__bridge APCLazyProperty*)expected).methodStyle;
                CFRelease(expected);
//                [self tryUnhook:style];
            }else{
                
                lazyload.associatedHook = self;
//                [self tryHook:lazyload.methodStyle];
            }
            break;
        }
    }
}

- (APCLazyProperty *)lazyload
{
    if(_lazyload != nil){
        
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
                
//                APCMethodStyle style = ((__bridge APCTriggerGetterProperty*)expected).methodStyle;
                CFRelease(expected);
//                [self tryUnhook:style];
            }else{
                
                getterTrigger.associatedHook = self;
//                [self tryHook:getterTrigger.methodStyle];
            }
            break;
        }
    }
}

- (APCTriggerGetterProperty *)getterTrigger
{
    if(_getterTrigger != nil){
        
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
                
//                APCMethodStyle style = ((__bridge APCTriggerSetterProperty*)expected).methodStyle;
                CFRelease(expected);
//                [self tryUnhook:style];
            }else{
                
                setterTrigger.associatedHook = self;
//                [self tryHook:setterTrigger.methodStyle];
            }
            break;
        }
    }
}

- (APCTriggerSetterProperty *)setterTrigger
{
    if(_setterTrigger != nil){
        
        return (__bridge APCTriggerSetterProperty *)(_setterTrigger);
    }
    
    return apc_propertyhook_lookupSuperProperty(self, "_setterTrigger");
}

- (BOOL)isGetterEmpty
{
    return !(_lazyload || _getterTrigger);
}

- (BOOL)isSetterEmpty
{
    return !_setterTrigger;
}

- (BOOL)isEmpty
{
    return !(_lazyload || _getterTrigger || _setterTrigger);
}

- (void)tryHook:(APCMethodStyle)style
{
    NSAssert(style == APCMethodGetterStyle || style == APCMethodSetterStyle
             , @"APC: Not supported.");
    
    if((style == APCMethodGetterStyle && _new_implementation == nil)
       ||
       (style == APCMethodSetterStyle && _new_setter_implementation == nil)){
        
        [self hook:style];
    }
}

/**
 'G'/'S'
 */
- (void)hook:(APCMethodStyle)style
{
    const char* const  methodTypeEncoding = (style == APCMethodGetterStyle)
    ? APCGetterMethodEncoding
    : APCSetterMethodEncoding;
    
    NSString* method = style == APCMethodGetterStyle
    ? _getter_name
    : _setter_name;
    
    APCAtomicIMP*   newimp_ptr = (style == APCMethodGetterStyle)
    ? &_new_implementation
    : &_new_setter_implementation;
    
    IMP*            oldimp_ptr = (style == APCMethodGetterStyle)
    ? &_old_implementation
    : &_old_setter_implementation;
    
    IMP newimp;
    if(_kindOfValue == APCPropertyValueKindOfBlock ||
       _kindOfValue == APCPropertyValueKindOfObject){
        
        newimp = (style == APCMethodGetterStyle)
        ? (IMP)apc_propertyhook_getter
        : (IMP)apc_propertyhook_setter;
    }else{
        
        newimp = (style == APCMethodGetterStyle)
        ? (IMP)apc_propertyhook_getter_HookIMPMapper(_valueTypeEncoding)
        : (IMP)apc_propertyhook_setter_HookIMPMapper(_valueTypeEncoding);
    }
    
    *newimp_ptr = newimp;
    
    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
        
        *oldimp_ptr
        =
        class_replaceMethod(_hookclass
                            , NSSelectorFromString(method)
                            , newimp
                            , methodTypeEncoding);
    }else{
        
        APCProxyClass iProxyClass;
        if(!apc_object_isProxyInstance(_instance)){
            
            iProxyClass = apc_object_hookWithProxyClass(_instance);
        }else{
            
            iProxyClass = object_getClass(_instance);
        }
        
        *oldimp_ptr
        =
        class_replaceMethod(iProxyClass
                            , NSSelectorFromString(method)
                            , newimp
                            , methodTypeEncoding);
    }
    
    ///Delete the wrong _old_implementation.
    if(!apc_contains_objcruntimelock()){

        IMP cmp = (style == APCMethodGetterStyle)
        ? (IMP)apc_null_getter_HookIMPMapper(_valueTypeEncoding)
        : (IMP)apc_null_setter_HookIMPMapper(_valueTypeEncoding);
        
        if(*oldimp_ptr == cmp){
            
            *oldimp_ptr = nil;
        }
    }
}

- (void)unhook
{
    [self unhook:APCMethodGetterStyle];
    [self unhook:APCMethodSetterStyle];
}

- (void)tryUnhook:(APCMethodStyle)style
{
    NSAssert(style == APCMethodGetterStyle || style == APCMethodSetterStyle, @"APC: Not supported.");
    
    if(style == APCMethodGetterStyle){
        
        if(_lazyload || _getterTrigger) return;
    }
    [self unhook:style];
}

- (void)unhook:(APCMethodStyle)style
{
    const char* const  methodTypeEncoding = (style == APCMethodGetterStyle)
    ? APCGetterMethodEncoding
    : APCSetterMethodEncoding;
    
    APCAtomicIMP*   newimp_ptr = (style == APCMethodGetterStyle)
    ? &_new_implementation
    : &_new_setter_implementation;
    
    if(nil == (*newimp_ptr)) return;
    
    IMP*            oldimp_ptr = (style == APCMethodGetterStyle)
    ? &_old_implementation
    : &_old_setter_implementation;
    
    NSString* method = style == APCMethodGetterStyle
    ? _getter_name
    : _setter_name;
    
    Class unhookClass = (_kindOfOwner == APCPropertyOwnerKindOfClass)
    ? _hookclass
    : object_getClass(_instance);
    
    
    IMP newImp = *newimp_ptr;
    if(atomic_compare_exchange_strong(newimp_ptr, &newImp, nil))
    {
        if(*oldimp_ptr != nil){
            
            //Realized by itself
            class_replaceMethod(unhookClass
                                , NSSelectorFromString(method)
                                , *oldimp_ptr
                                , methodTypeEncoding);
        }else{
            
            ///Not realized by itself
            if(apc_contains_objcruntimelock()) {
                
                class_removeMethod_APC_OBJC2
                (unhookClass
                 , NSSelectorFromString(method));
            }else {
                
                class_replaceMethod(unhookClass
                                    , NSSelectorFromString(method)
                                    , [self restoredImplementation:style]
                                    , methodTypeEncoding);
            }
        }
    }
}

- (IMP)restoredImplementation:(APCMethodStyle)style
{
    if(style == APCMethodGetterStyle && _old_implementation){
        
        return _old_implementation;
    }else if (style == APCMethodSetterStyle && _old_setter_implementation){
        
        return _old_setter_implementation;
    }
    
    if(_kindOfValue == APCPropertyValueKindOfObject ||
       _kindOfValue == APCPropertyValueKindOfBlock) {
        
        return (style == APCMethodGetterStyle)
        ? (IMP)apc_null_getter : (IMP)apc_null_setter;
    }else{
        
        return  (style == APCMethodGetterStyle)
        ? (IMP)apc_null_getter_HookIMPMapper(_valueTypeEncoding)
        : (IMP)apc_null_setter_HookIMPMapper(_valueTypeEncoding);
    }
}

- (IMP)oldImplementation:(APCMethodStyle)style
{
    NSAssert(style == APCMethodGetterStyle || style == APCMethodSetterStyle, @"APC: Not supported.");
    
    NSString* method;
    
    if(style == APCMethodGetterStyle){
        
        if(_old_implementation){
            
            return _old_implementation;
        }
        method = _getter_name;
    }else{
        
        
        if (_old_setter_implementation){
            
            return _old_setter_implementation;
        }
        method = _setter_name;
        
    }
    
    Class tagCls = _kindOfOwner == APCPropertyOwnerKindOfClass
    ? apc_class_getSuperclass(_hookclass)
    : _hookclass;
    
    APCPropertyHook* hook
    =
    apc_lookup_sourcePropertyhook_inRange(tagCls, _source_class, method);
    if(hook != nil){
        
        return style == APCMethodGetterStyle
        ? hook->_old_implementation
        : hook->_old_setter_implementation;
    }
    
    return
    
    class_getMethodImplementation(_source_class
                                  , NSSelectorFromString(method));
}

- (void)performOldSetterFromTarget:(id)target withValue:(id)value
{
    APCBoxedInvokeBasicValueSetterIMP(target
                                      , NSSelectorFromString(_setter_name)
                                      , [self oldImplementation:APCMethodSetterStyle]
                                      , _valueTypeEncoding.UTF8String
                                      , value);
}

- (id)performOldGetterFromTarget:(id)target
{
    return
    
    APCBoxedInvokeBasicValueGetterIMP(target
                                      , NSSelectorFromString(_getter_name)
                                      , [self oldImplementation:APCMethodGetterStyle]
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

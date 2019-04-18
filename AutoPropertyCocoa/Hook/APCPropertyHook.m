//
//  APCPropertyHook.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyHook.h"
#import "APCLazyProperty.h"
#import "APCRuntime.h"
#import "APCScope.h"

id _Nullable apc_propertyhook_getter(_Nullable id _SELF,SEL _Nonnull _CMD)
{
    APCPropertyHook* hook;
    
    if(YES == apc_object_isProxyInstance(_SELF)){
        
        hook = apc_lookup_instancePropertyhook(_SELF, NSStringFromSelector(_CMD));
    }else{
        
        if(nil == (hook = apc_lookup_propertyhook(object_getClass(_SELF), NSStringFromSelector(_CMD)))){
            
            NSCAssert(NO, @"APC: BAD ACCESS.");
        }
    }
    
    if(hook.isEmpty){
        
        return [apc_propertyhook_rootHook(hook) performOldGetterFromTarget:_SELF];
    }
    
    
    return nil;
}
apc_def_vGHook_and_impimage(apc_propertyhook_getter)

void apc_propertyhook_setter(_Nullable id _SELF,SEL _Nonnull _CMD,id _Nullable value)
{
    
}
apc_def_vSHook_and_impimage(apc_propertyhook_setter)


@implementation APCPropertyHook
{
#warning add lock
    NSMutableArray<APCHookProperty *>* _boundProperties;
    APCHookProperty*                   _propertyInfo;
}

+ (instancetype)hookWithProperty:(APCHookProperty *)property
{
    return [[self alloc] initWithProperty:property];
}

- (instancetype)initWithProperty:(APCHookProperty *)property
{
    self = [super init];
    if (self) {
        
        _propertyInfo       =   property;
        _source_class       =   property->_des_class;
        _boundProperties    =   [NSMutableArray arrayWithObject:property];
        [self hook];
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable [_Nonnull])buffer count:(NSUInteger)len
{
    return [_boundProperties countByEnumeratingWithState:state objects:buffer count:len];
}

- (Class)sourceclass
{
    return _source_class;
}

- (Class)hookclass
{
    return _propertyInfo->_des_class;
}

- (NSString *)hookMethod
{
    return _propertyInfo->_hooked_name;
}

- (void)bindProperty:(APCHookProperty *)property
{
    NSAssert((_propertyInfo->_des_class == property->_des_class)
              && ([_propertyInfo->_des_getter_name isEqualToString:property->_hooked_name]), @"APC: Class name and property name are one by one mapped.");
    
    [_boundProperties addObject:property];
    [property bindingToHook:self];
}

- (void)unbindProperty:(APCHookProperty *)property
{
    NSAssert((_propertyInfo->_des_class == property->_des_class)
             && ([_propertyInfo->_des_getter_name isEqualToString:property->_hooked_name]), @"APC: Class name and property name are one by one mapped.");
    
    [property invalid];
    
    [_boundProperties removeObject:property];
    
    [property bindingToHook:nil];
    
    if(self.isEmpty){
        
        [self unhook];
    }
}

- (BOOL)isEmpty
{
    return [_boundProperties count];
}

- (NSArray<APCHookProperty *> *)boundProperties
{
    return [_boundProperties copy];
}

- (APCHookProperty*)boundPropertyForPropertyKind:(Class)propertyKind
{
    for (APCHookProperty* item in _boundProperties) {
        
        if(propertyKind == object_getClass(item)){
            
            return item;
        }
    }
    return nil;
}

- (void)hook
{
    IMP newimp;
    
    if(_propertyInfo.kindOfValue == APCPropertyValueKindOfBlock ||
       _propertyInfo.kindOfValue == APCPropertyValueKindOfObject){
        
        newimp = (_propertyInfo.methodStyle == APCMethodGetterStyle)
        ? (IMP)apc_propertyhook_getter
        : (IMP)apc_propertyhook_setter;
    }else{
        
        newimp = (_propertyInfo.methodStyle == APCMethodGetterStyle)
        ? (IMP)apc_propertyhook_getter_impimage(_propertyInfo.valueTypeEncoding)
        : (IMP)apc_propertyhook_setter_impimage(_propertyInfo.valueTypeEncoding);
    }
    
    _new_implementation = newimp;
    
    if(_propertyInfo.kindOfOwner == APCPropertyOwnerKindOfClass){
        
        _old_implementation
        =
        class_replaceMethod(_propertyInfo->_des_class
                            , NSSelectorFromString(_propertyInfo->_hooked_name)
                            , _new_implementation
                            , _propertyInfo.methodTypeEncoding.UTF8String);
        if(nil == _old_implementation){
            
            ///Overwrite super class property with new property.
            ///Storing the implementation address of the super class
            
            ///Superclass and subclass used the same old implementation that is from superclass.
            
            APCPropertyHook* sourcehook
            = apc_lookup_propertyhook_range(class_getSuperclass(_propertyInfo->_des_class)
                                            , _propertyInfo->_src_class
                                            , _propertyInfo->_hooked_name);
            if(nil != sourcehook){
                
                _old_implementation = sourcehook->_old_implementation;
            }else{
                
                _old_implementation
                =
                class_getMethodImplementation(_propertyInfo->_src_class
                                              , NSSelectorFromString(_propertyInfo->_hooked_name));
            }
            
            NSAssert(_old_implementation, @"APC: Can not find original implementation.");
        }
    }else{
        
        if(NO == apc_object_isProxyInstance(_propertyInfo->_instance)){
            
            _proxyClass = apc_object_hookWithProxyClass(_propertyInfo->_instance);
        }else{
            
            _proxyClass = object_getClass(_propertyInfo->_instance);
        }
        
        _old_implementation
        =
        class_replaceMethod(_proxyClass
                            , NSSelectorFromString(_propertyInfo->_hooked_name)
                            , _new_implementation
                            , _propertyInfo.methodTypeEncoding.UTF8String);
        if(nil == _old_implementation){
            
            APCPropertyHook* sourcehook
            = apc_lookup_propertyhook_range(class_getSuperclass(_propertyInfo->_des_class)
                                            , _propertyInfo->_src_class
                                            , _propertyInfo->_hooked_name);
            if(nil != sourcehook){
                
                _old_implementation = sourcehook->_old_implementation;
            }else{
                
                _old_implementation
                =
                class_getMethodImplementation(_propertyInfo->_src_class
                                              , NSSelectorFromString(_propertyInfo->_hooked_name));
            }
        }
    }
}

- (void)unhook
{
    if(nil == _old_implementation || nil == _new_implementation){
        
        return;
    }
    
    if(_propertyInfo.kindOfOwner == APCPropertyOwnerKindOfClass)
    {
        _new_implementation = nil;
        
        class_replaceMethod(_propertyInfo->_des_class
                            , NSSelectorFromString(_propertyInfo->_hooked_name)
                            , _old_implementation
                            , _propertyInfo.methodTypeEncoding.UTF8String);
    }
    else
    {
        if(YES == apc_object_isProxyInstance(_propertyInfo->_instance)){
            
            apc_class_disposeProxyClass(apc_instance_unhookFromProxyClass(_propertyInfo->_instance));
        }
    }
    
    _propertyInfo = nil;
}

- (void)dealloc
{
    if(_propertyInfo.kindOfOwner == APCPropertyOwnerKindOfInstance){
        
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
    
}

- (id)performOldGetterFromTarget:(id)target
{
    return nil;
}
@end


//
//  APCPropertyHook.m
//  AutoPropertyCocoaiOS
//
//  Created by MDLK on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyHook.h"
#import "APCScope.h"

id _Nullable apc_propertyhook_getter(_Nullable id _SELF,SEL _Nonnull _CMD)
{
    
    return nil;
}
apc_def_vGHook_and_impimage(apc_propertyhook_getter)

void apc_propertyhook_setter(_Nullable id _SELF,SEL _Nonnull _CMD,id _Nullable value)
{
    
}
apc_def_vSHook_and_impimage(apc_propertyhook_setter)


@implementation APCPropertyHook
{
    NSMutableArray<AutoHookPropertyInfo *>* _boundProperties;
    AutoHookPropertyInfo*                   _propertyInfo;
}

+ (instancetype)hookWithProperty:(AutoHookPropertyInfo *)property
{
    return [[self alloc] initWithProperty:property];
}

- (instancetype)initWithProperty:(AutoHookPropertyInfo *)property
{
    self = [super init];
    if (self) {
        
        _propertyInfo       =   property;
        _boundProperties    =   [NSMutableArray arrayWithObject:property];
        [self hook];
    }
    return self;
}

- (void)bindProperty:(AutoHookPropertyInfo *)property
{
    NSAssert((_propertyInfo->_des_class == property->_des_class)
              && ([_propertyInfo->_des_method_name isEqualToString:property->_des_method_name]), @"APC: Class name and property name are one by one mapped.");
    
    [_boundProperties addObject:property];
}

- (void)unbindProperty:(AutoHookPropertyInfo *)property
{
    NSAssert((_propertyInfo->_des_class == property->_des_class)
             && ([_propertyInfo->_des_method_name isEqualToString:property->_des_method_name]), @"APC: Class name and property name are one by one mapped.");
    
    [property invalid];
    
    [_boundProperties removeObject:property];
    
    if(self.isEmpty){
        
        [self unhook];
    }
}

- (BOOL)isEmpty
{
    return [_boundProperties count];
}

- (NSArray<AutoHookPropertyInfo *> *)boundProperties
{
    return [_boundProperties copy];
}

- (void)hook
{
//    AutoHookPropertyInfo* property = [_boundProperties firstObject];
    
    IMP newimp;
    if(_propertyInfo.kindOfValue == AutoPropertyValueKindOfBlock ||
       _propertyInfo.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = _propertyInfo.methodStyle==APCMethodGetterStyle
        ? (IMP)apc_propertyhook_getter
        : (IMP)apc_propertyhook_setter;
    }else{
        
        newimp = _propertyInfo.methodStyle==APCMethodGetterStyle
        ? (IMP)apc_propertyhook_getter_impimage(_propertyInfo.valueTypeEncoding)
        : (IMP)apc_propertyhook_setter_impimage(_propertyInfo.valueTypeEncoding);
    }
    
    _new_implementation = newimp;
    
    if(_propertyInfo.kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        _old_implementation
        =
        class_replaceMethod(_propertyInfo->_des_class
                            , NSSelectorFromString(_propertyInfo->_des_method_name)
                            , _new_implementation
                            , [NSString stringWithFormat:@"%@@:", _propertyInfo.valueTypeEncoding].UTF8String);
        if(nil == _old_implementation){
            
            ///Overwrite super class property with new property.
            ///Storing the implementation address of the super class
            
            ///Superclass and subclass used the same old implementation that is from superclass.
            
#warning 搜索APCRuntime...
            APCPropertyHook* superHook;
            
            if(nil != superHook){
                
                _old_implementation = superHook->_new_implementation;
            }else{
                
                _old_implementation
                =
                class_getMethodImplementation(_propertyInfo->_src_class
                                              , NSSelectorFromString(_propertyInfo->_des_method_name));
            }
            
            NSAssert(_old_implementation, @"APC: Can not find original implementation.");
        }
    }else{
        
        //...
    }
}

- (void)unhook
{
    if(nil == _old_implementation || nil == _new_implementation){
        
        return;
    }
    
    if(_propertyInfo.kindOfOwner == AutoPropertyOwnerKindOfClass)
    {
        _new_implementation = nil;
        
        class_replaceMethod(_propertyInfo->_des_class
                            , NSSelectorFromString(_propertyInfo->_des_method_name)
                            , _old_implementation
                            , [NSString stringWithFormat:@"%@@:",_propertyInfo.valueTypeEncoding].UTF8String);
    }
    else
    {
//        if(NO == [AutoLazyPropertyInfo testingProxyClassInstance:_instance]){
//            ///Instance has been unbound by other threads.
//            return;
//        }
        
//        [self unhookForInstance];
//        [self removeFromInstanceCache];
    }
    
    _propertyInfo = nil;
}

@end


//
//  APCPropertyHook.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyHook.h"
#import "APCHookProperty.h"
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
        _boundProperties    =   [NSMutableArray arrayWithObject:property];
        [self hook];
    }
    return self;
}

- (Class)hookclass
{
    return _propertyInfo->_des_class;
}

- (NSString *)hookMethod
{
    return _propertyInfo->_des_getter_name;
}

- (NSEnumerator<APCHookProperty *> *)propertyEnumerator
{
    return _boundProperties.objectEnumerator;
}

- (void)bindProperty:(APCHookProperty *)property
{
    NSAssert((_propertyInfo->_des_class == property->_des_class)
              && ([_propertyInfo->_des_getter_name isEqualToString:property->_des_getter_name]), @"APC: Class name and property name are one by one mapped.");
    
    [_boundProperties addObject:property];
    [property bindingToHook:self];
}

- (void)unbindProperty:(APCHookProperty *)property
{
    NSAssert((_propertyInfo->_des_class == property->_des_class)
             && ([_propertyInfo->_des_getter_name isEqualToString:property->_des_getter_name]), @"APC: Class name and property name are one by one mapped.");
    
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

- (void)hook
{
//    AutoHookPropertyInfo* property = [_boundProperties firstObject];
    
    IMP newimp;
    if(_propertyInfo.kindOfValue == APCPropertyValueKindOfBlock ||
       _propertyInfo.kindOfValue == APCPropertyValueKindOfObject){
#warning <#message#>
//        newimp = _propertyInfo.methodStyle==APCMethodGetterStyle
//        ? (IMP)apc_propertyhook_getter
//        : (IMP)apc_propertyhook_setter;
    }else{
        
//        newimp = _propertyInfo.methodStyle==APCMethodGetterStyle
//        ? (IMP)apc_propertyhook_getter_impimage(_propertyInfo.valueTypeEncoding)
//        : (IMP)apc_propertyhook_setter_impimage(_propertyInfo.valueTypeEncoding);
    }
    
    _new_implementation = newimp;
    
    if(_propertyInfo.kindOfOwner == APCPropertyOwnerKindOfClass){
        
        _old_implementation
        =
        class_replaceMethod(_propertyInfo->_des_class
                            , NSSelectorFromString(_propertyInfo->_des_getter_name)
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
                                              , NSSelectorFromString(_propertyInfo->_des_getter_name));
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
    
    if(_propertyInfo.kindOfOwner == APCPropertyOwnerKindOfClass)
    {
        _new_implementation = nil;
        
        class_replaceMethod(_propertyInfo->_des_class
                            , NSSelectorFromString(_propertyInfo->_des_getter_name)
                            , _old_implementation
                            , [NSString stringWithFormat:@"%@@:",_propertyInfo.valueTypeEncoding].UTF8String);
    }
    else
    {
//        if(NO == [APCLazyProperty testingProxyClassInstance:_instance]){
//            ///Instance has been unbound by other threads.
//            return;
//        }
        
//        [self unhookForInstance];
//        [self removeFromInstanceCache];
    }
    
    _propertyInfo = nil;
}

@end


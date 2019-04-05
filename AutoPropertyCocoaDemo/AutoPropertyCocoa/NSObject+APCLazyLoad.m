//
//  NSObject+AutoWorkPropery.m
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "APCInstancePropertyCacheManager.h"
#import "NSObject+APCLazyLoad.h"
#import "AutoLazyPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "APCScope.h"

//AutoLazyPropertyInfo* _Nullable apc_lazyLoadGetInstanceFromBoundCache(id instance,SEL _CMD);

@implementation NSObject(APCLazyLoad)

+ (void)apc_lazyLoadForProperty:(NSString *)property
{
    [self apc_classSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:nil];
}

+ (void)apc_lazyLoadForProperty:(NSString *)property initializeSelector:(SEL)selector
{
    [self apc_classSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:selector];
}

+ (void)apc_lazyLoadForProperty:(NSString *)property usingBlock:(id  _Nullable (^)(id _Nonnull))block
{
    [self apc_classSetLazyLoadProperty:property hookWithBlock:block hookWithSEL:nil];
}

+ (void)apc_lazyLoadForPropertyHooks:(NSDictionary *)propertyHooks
{
    [propertyHooks enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull property, id  _Nonnull hook, BOOL * _Nonnull stop) {
        
        if([hook isKindOfClass:[NSString class]]){
            
            [self apc_classSetLazyLoadProperty:property hookWithBlock:hook hookWithSEL:nil];
        }else{
            
            [self apc_classSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:NSSelectorFromString(hook)];
        }
    }];
}

+ (void)apc_unbindLazyLoadForProperty:(NSString *)property
{
    AutoLazyPropertyInfo* p = [AutoLazyPropertyInfo cachedWithClass:self property:property];
    
    [p unhook];
}

+ (void)apc_unbindLazyLoadAllProperties
{
    [AutoLazyPropertyInfo unhookClassAllProperties:self];
}

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
{
    [self apc_instanceSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:nil];
}

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
                    usingBlock:(id _Nullable(^)(id _Nonnull  _self))block
{
    [self apc_instanceSetLazyLoadProperty:property hookWithBlock:block hookWithSEL:nil];
}

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
                      selector:(_Nonnull SEL)selector
{
    [self apc_instanceSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:selector];
}

- (void)apc_lazyLoadForPropertyHooks:(NSDictionary* _Nonnull)propertyHooks
{
    [propertyHooks enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull property, id  _Nonnull hook, BOOL * _Nonnull stop) {
        
        if([hook isKindOfClass:[NSString class]]){
            
            [self apc_instanceSetLazyLoadProperty:property hookWithBlock:hook hookWithSEL:nil];
        }else{
            
            [self apc_instanceSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:NSSelectorFromString(hook)];
        }
    }];
}

- (void)apc_unbindLazyLoadForProperty:(NSString* _Nonnull)property
{
    [(AutoLazyPropertyInfo*)[APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property] unhook];
}

- (void)apc_unbindLazyLoadAllProperties
{
    [[APCInstancePropertyCacheManager boundAllPropertiesForInstance:self]
     makeObjectsPerformSelector:@selector(unhook)];
}


- (void)apc_instanceSetLazyLoadProperty:(NSString*)propertyName
                          hookWithBlock:(id)block
                            hookWithSEL:(SEL)aSelector
{
    AutoLazyPropertyInfo* propertyInfo = [AutoLazyPropertyInfo infoWithPropertyName:propertyName
                                                                     aInstance:self];
    
    if(NO  == (propertyInfo.accessOption & AutoPropertyGetValueEnable)
       
       ||
       
       NO  == (propertyInfo.accessOption & AutoPropertySetValueEnable)){
        return;
    }
    
    if(block){
        
        [propertyInfo hookUsingUserBlock:block];
    }else{
        
        [propertyInfo hookUsingUserSelector:aSelector];
    }
}


+ (void)apc_classSetLazyLoadProperty:(NSString*)propertyName
                       hookWithBlock:(id)block
                         hookWithSEL:(SEL)aSelector
{
    AutoLazyPropertyInfo* propertyInfo = [AutoLazyPropertyInfo infoWithPropertyName:propertyName
                                                                             aClass:self];
    
    if(NO  == (propertyInfo.accessOption & AutoPropertyGetValueEnable)
       
       ||
       
       NO  == (propertyInfo.accessOption & AutoPropertySetValueEnable)){
        return;
    }
    
    if(block){
    
        [propertyInfo hookUsingUserBlock:block];
    }else{
        
        [propertyInfo hookUsingUserSelector:aSelector];
    }
}

@end
/**
 Destination func.
 */
id _Nullable apc_lazy_property(_Nullable id _SELF,SEL _CMD)
{
    AutoLazyPropertyInfo* lazyPropertyInfo;
    
    if(nil == (lazyPropertyInfo = [APCInstancePropertyCacheManager boundPropertyFromInstance:_SELF cmd:NSStringFromSelector(_CMD)]))
        
        if(nil == (lazyPropertyInfo = [AutoLazyPropertyInfo cachedWithClass:[_SELF class] property:NSStringFromSelector(_CMD)]))
            
            NSCAssert(NO, @"APC: Lose property info.");
    
    
    ///Modified by other thread.
    if(lazyPropertyInfo.enable == NO){
        
        return [lazyPropertyInfo performOldPropertyFromTarget:_SELF];
    }
    
    id value = nil;
    ///Get value.(All returned value are boxed)
    if(lazyPropertyInfo.accessOption & AutoPropertyComponentOfGetter){
        
        value = [lazyPropertyInfo performOldPropertyFromTarget:_SELF];
    }else{
        
        value = [lazyPropertyInfo getIvarValueFromTarget:_SELF];
    }
    
    
    if(value == nil
       
       && (lazyPropertyInfo.kindOfValue == AutoPropertyValueKindOfBlock ||
           lazyPropertyInfo.kindOfValue == AutoPropertyValueKindOfObject))
    {
        ///Create default value.
        if(lazyPropertyInfo.kindOfHook == AutoPropertyHookKindOfSelector){
            
            value = [lazyPropertyInfo instancetypeNewObjectByUserSelector];
        }
        else{
            
            value = [lazyPropertyInfo performUserBlock:_SELF];
        }
        [lazyPropertyInfo setValue:value toTarget:_SELF];
    }
    else if (lazyPropertyInfo.accessCount == 0
             
             && (lazyPropertyInfo.kindOfValue != AutoPropertyValueKindOfBlock ||
                 lazyPropertyInfo.kindOfValue != AutoPropertyValueKindOfObject))
    {
        
        NSCAssert(lazyPropertyInfo.kindOfHook == AutoPropertyHookKindOfBlock
                  , @"APC: Basic-value only supportted be initialized by 'userblock'.");
        
        value = [lazyPropertyInfo performUserBlock:_SELF];
        [lazyPropertyInfo setValue:value toTarget:_SELF];
    }
    
    [lazyPropertyInfo access];
    
    return value;
}

/**
 defines
 :
 apc_lazy_property + _ + type encode
 apc_lazy_property + _ + impimage
 */
apc_def_vGHook_and_impimage(apc_lazy_property)

//
//  NSObject+AutoWorkPropery.m
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "NSObject+APCLazyLoad.h"
#import "AutoLazyPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "APCScope.h"

AutoLazyPropertyInfo* _Nullable apc_lazyLoadGetInstanceFromBindedCache(id instance,SEL _CMD);

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
    AutoLazyPropertyInfo* p = [AutoLazyPropertyInfo cachedInfoByClass:self propertyName:property];
    [p unhook];
    [p removeFromCache];
}

+ (void)apc_unbindLazyLoadAllPropertys
{
    [AutoLazyPropertyInfo removeCacheForClass:self];
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
    [apc_lazyLoadGetInstanceFromBindedCache(self , NSSelectorFromString(property))
     unhook];
}

- (void)apc_unbindLazyLoadAllPropertys
{
    [AutoLazyPropertyInfo unbindlazyLoadForInstance:self];
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

/**
 defines
 :
 apc_lazy_property + _ + type encode
 apc_lazy_property + _ + impimage
 */
apc_def_vGHook_and_impimage(apc_lazy_property)
/**
 Destination func.
 */
id _Nullable apc_lazy_property(_Nullable id _SELF,SEL _CMD)
{
    AutoLazyPropertyInfo* lazyPropertyInfo;
    
    if(nil == (lazyPropertyInfo = apc_lazyLoadGetInstanceFromBindedCache(_SELF,_CMD)))
        
        if(nil == (lazyPropertyInfo = [AutoLazyPropertyInfo cachedInfoByClass:[_SELF class] propertyName:NSStringFromSelector(_CMD)]))
            
            NSCAssert(NO, @"");
        
    
    ///If lazy-load of instance has been logically removed.Performing the old implementation.
    if(lazyPropertyInfo.enable == NO){
        
        NSCAssert(lazyPropertyInfo.kindOfOwner == AutoPropertyOwnerKindOfInstance
                  , @"APC: This property is invalid.");
        
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
@end

//
//  NSObject+AutoWorkPropery.m
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "NSObject+APCLazyLoad.h"
#import "APCLazyProperty.h"
#import "APCScope.h"


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
//    APCLazyProperty* p = [APCLazyProperty cachedTargetClass:self property:property];
//
//    [p unhook];
}

+ (void)apc_unbindLazyLoadAllProperties
{
//    [APCLazyProperty unhookClassAllProperties:self];
}

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
{
    [self apc_instanceSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:nil];
}

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
                    usingBlock:(id _Nullable(^)(id _Nonnull  instance))block
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
//    [(APCLazyProperty*)[APCInstancePropertyCacheManager boundPropertyFromInstance:self cmd:property] unhook];
}

- (void)apc_unbindLazyLoadAllProperties
{
//    [[APCInstancePropertyCacheManager boundAllPropertiesForInstance:self]
//     makeObjectsPerformSelector:@selector(unhook)];
}


- (void)apc_instanceSetLazyLoadProperty:(NSString*)propertyName
                          hookWithBlock:(id)block
                            hookWithSEL:(SEL)aSelector
{
#warning <#message#>
    APCLazyProperty* propertyInfo;
    
    if(propertyInfo == nil){
        
        propertyInfo = [APCLazyProperty instanceWithProperty:propertyName aInstance:self];
    }
    
    if(NO  == (propertyInfo.accessOption & APCPropertyGetValueEnable)
       
       ||
       
       NO  == (propertyInfo.accessOption & APCPropertySetValueEnable)){
        return;
    }
    
    if(block){
        
        [propertyInfo bindindUserBlock:block];
    }else{
        
        [propertyInfo bindingUserSelector:aSelector];
    }
}


+ (void)apc_classSetLazyLoadProperty:(NSString*)propertyName
                       hookWithBlock:(id)block
                         hookWithSEL:(SEL)aSelector
{
#warning <#message#>
    APCLazyProperty* propertyInfo;
    
    if(propertyInfo == nil){
        
        propertyInfo = [APCLazyProperty instanceWithProperty:propertyName aClass:self];
    }
    
    
    if(NO  == (propertyInfo.accessOption & APCPropertyGetValueEnable)
       
       ||
       
       NO  == (propertyInfo.accessOption & APCPropertySetValueEnable)){
        return;
    }
    
    if(block){
    
        [propertyInfo bindindUserBlock:block];
    }else{
        
        [propertyInfo bindingUserSelector:aSelector];
    }
}

@end
/**
 Destination.
 */
id _Nullable apc_lazy_property(_Nullable id _SELF,SEL _CMD)
{
    APCLazyProperty* lazyPropertyInfo;
    
//    if(nil == (lazyPropertyInfo = [APCInstancePropertyCacheManager boundPropertyFromInstance:_SELF cmd:NSStringFromSelector(_CMD)]))
        
        //Get info from _SELF.
        //The info tell me where does it search from.
//        if(nil == (lazyPropertyInfo = [APCLazyProperty cachedFromAClassByInstance:_SELF property:NSStringFromSelector(_CMD)]))
        
            NSCAssert(NO, @"APC: Lose property info.");
        
    
//    if(NO == lazyPropertyInfo.enable
//       || YES == [APCLazyloadOldLoopController testingIsInLoop:_SELF]){
//
//        return [lazyPropertyInfo performOldGetterFromTarget:_SELF];
//    }
    
    
    id                  value       = nil;
    ///Get value.(All returned value are boxed)
    if(lazyPropertyInfo.accessOption & APCPropertyComponentOfGetter){
        
        value = [lazyPropertyInfo performOldGetterFromTarget:_SELF];
    }else{
        
        value = [lazyPropertyInfo getIvarValueFromTarget:_SELF];
    }
    
    APCMemoryBarrier;
    
    NSUInteger   accessCount = lazyPropertyInfo.accessCount;
    if(value == nil
       
       && (lazyPropertyInfo.kindOfValue == APCPropertyValueKindOfBlock ||
           lazyPropertyInfo.kindOfValue == APCPropertyValueKindOfObject))
    {
        ///Create default value.
        if(lazyPropertyInfo.kindOfUserHook == APCPropertyHookKindOfSelector){
            
            value = [lazyPropertyInfo instancetypeNewObjectByUserSelector];
        }
        else{
            
            value = [lazyPropertyInfo performUserBlock:_SELF];
        }
        [lazyPropertyInfo setValue:value toTarget:_SELF];
    }
    else if (accessCount == 0
             
             && (lazyPropertyInfo.kindOfValue != APCPropertyValueKindOfBlock ||
                 lazyPropertyInfo.kindOfValue != APCPropertyValueKindOfObject))
    {
        
        NSCAssert(lazyPropertyInfo.kindOfUserHook == APCPropertyHookKindOfBlock
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

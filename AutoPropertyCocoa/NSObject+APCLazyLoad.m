//
//  NSObject+AutoWorkPropery.m
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "NSObject+APCLazyLoad.h"
#import "APCPropertyHook.h"
#import "APCLazyProperty.h"
#import "APCRuntime.h"
#import "APCScope.h"


@implementation NSObject(APCLazyLoad)

+ (void)apc_lazyLoadForProperty:(NSString *)property
{
    [self apc_classSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:nil];
}

+ (void)apc_lazyLoadForProperty:(NSString *)property selector:(SEL)selector
{
    [self apc_classSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:selector];
}

+ (void)apc_lazyLoadForProperty:(NSString *)property usingBlock:(id_apc_t  _Nullable (^)(id_apc_t _Nonnull))block
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
    apc_disposeProperty
    (
        apc_lookup_property(self, property, @selector(lazyload))
    );
}


- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
{
    [self apc_instanceSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:nil];
}

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
                    usingBlock:(id _Nullable(^)(id_apc_t _Nonnull  instance))block
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
    apc_instance_removeAssociatedProperty
    (
        self
        ,
        apc_lookup_instanceProperty(self, property, @selector(lazyload))
    );
}

- (void)apc_instanceSetLazyLoadProperty:(NSString*)property
                          hookWithBlock:(id)block
                            hookWithSEL:(SEL)aSelector
{
    APCLazyProperty* p = apc_lookup_instanceProperty(self, property, @selector(lazyload));
    
    if(p == nil){
        
        p = [APCLazyProperty instanceWithProperty:property aInstance:self];
        if(!apc_object_isProxyInstance(self)){
            
            apc_object_hookWithProxyClass(self);
        }
        apc_instance_setAssociatedProperty(self, p);
    }
    
    if(NO  == (p.accessOption & APCPropertyGetValueEnable)
       
       ||
       
       NO  == (p.accessOption & APCPropertySetValueEnable)){
        return;
    }
    
    if(block){
        
        [p bindindUserBlock:block];
    }else{
        
        [p bindingUserSelector:aSelector];
    }
}


+ (void)apc_classSetLazyLoadProperty:(NSString*)property
                       hookWithBlock:(id)block
                         hookWithSEL:(SEL)aSelector
{
    
    APCLazyProperty* p = apc_lookup_property(self, property, @selector(lazyload));
    
    if(p == nil){
        
        p = [APCLazyProperty instanceWithProperty:property aClass:self];
        apc_registerProperty(p);
    }
    
    if(NO  == (p.accessOption & APCPropertyGetValueEnable)
       
       ||
       
       NO  == (p.accessOption & APCPropertySetValueEnable)) {
        return;
    }
    
    if(block){
    
        [p bindindUserBlock:block];
    }else{
        
        [p bindingUserSelector:aSelector];
    }
}

@end

//
//  NSObject+AutoWorkPropery.m
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//
#import "NSObject+APCLazyLoad.h"
#import "APCPropertyHook.h"
#import "APCLazyProperty.h"
#import "APCObjectLock.h"
#import "APCRuntime.h"
#import "APCScope.h"


@implementation NSObject(APCLazyLoad)

+ (void)apc_lazyLoadForProperty:(NSString *)property
{
    [self apc_classSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:nil];
}

+ (void)apc_lazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array
{
    for (NSString* item in array.reverseObjectEnumerator) {
        
        [self apc_classSetLazyLoadProperty:item hookWithBlock:nil hookWithSEL:nil];
    }
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
    APCPropertyHook* hook   = apc_getPropertyhook(self, property);
    APCLazyProperty* p      = hook.lazyload;
    if(p != nil) {
        
        apc_disposeProperty(p);
    }
}


- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
{
    [self apc_instanceSetLazyLoadProperty:property hookWithBlock:nil hookWithSEL:nil];
}


- (void)apc_lazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array
{
    for (NSString* item in array.reverseObjectEnumerator) {
        
        [self apc_instanceSetLazyLoadProperty:item hookWithBlock:nil hookWithSEL:nil];
    }
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
    if(!apc_object_isProxyInstance(self)) return;
    APCPropertyHook* hook   = apc_lookup_instancePropertyhook(self, property);
    APCLazyProperty* p      = hook.lazyload;
    apc_instance_removeAssociatedProperty(self, p);
}

- (void)apc_unbindLazyLoadForPropertyArray:(NSArray<NSString *> *)array
{
    for (NSString* k in array.reverseObjectEnumerator) {
        
        [self apc_unbindLazyLoadForProperty:k];
    }
}

- (void)apc_instanceSetLazyLoadProperty:(NSString*)property
                          hookWithBlock:(id)block
                            hookWithSEL:(SEL)aSelector
{
    NSLock*             lock    = apc_object_get_lock(self);
    APCPropertyHook*    hook    = nil;
    APCLazyProperty*    p       = nil;
    
    [lock lock];
    {
        if(apc_object_isProxyInstance(self)){
            
            hook = apc_lookup_instancePropertyhook(self, property);
            p = hook.lazyload;
        }
        
        if(p == nil){
            
            p = [APCLazyProperty instanceWithProperty:property aInstance:self];
            if(!apc_object_isProxyInstance(self)){
                
                apc_object_hookWithProxyClass(self);
            }
            apc_instance_setAssociatedProperty(self, p);
        }
    }
    [lock unlock];
    
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
    NSLock* lock = apc_object_get_lock(self);
    NSAssert(lock, @"APC: Can not get object lock! mutiple-thread error.");
    
    [lock lock];
    APCLazyProperty* p = apc_getPropertyhook(self, property).lazyload;
    if(p == nil){
        
        p = [APCLazyProperty instanceWithProperty:property aClass:self];
        apc_registerProperty(p);
    }
    [lock unlock];
    
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

+ (void)apc_unbindLazyLoadForPropertyArray:(NSArray<NSString *> *)array
{
    for (NSString* k in array.reverseObjectEnumerator) {
        
        [self apc_unbindLazyLoadForProperty:k];
    }
}
@end

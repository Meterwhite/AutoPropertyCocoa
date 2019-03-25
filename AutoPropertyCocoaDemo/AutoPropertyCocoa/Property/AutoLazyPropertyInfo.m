//
//  AutoLazyPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by NOVO on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoLazyPropertyInfo.h"
#import "NSObject+APCLazyLoad.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "APCScope.h"


id    _Nullable apc_lazy_property       (_Nullable id _self,SEL __cmd);
void* _Nullable apc_lazy_property_impimage(NSString* eType);


@implementation AutoLazyPropertyInfo

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                              aClass:(Class __unsafe_unretained)aClass
{
    if(self = [super initWithPropertyName:propertyName aClass:aClass]){
        
        _des_property_name =
        
        self.propertyGetter
        ? NSStringFromSelector(self.propertyGetter)
        : _ogi_property_name;
    }
    return self;
}

- (void)hookUsingUserSelector:(SEL)aSelector
{
    _kindOfHook     =   AutoPropertyHookKindOfSelector;
    _userSelector   =   aSelector?:@selector(new);
    _userBlock      =   nil;
    IMP newimp      =   nil;
    if(self.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_lazy_property;
    }else{
        
        newimp = (IMP)apc_lazy_property_impimage(self.valueTypeEncoding);
    }
    
    [self hookPropertyWithImplementation:newimp];
}

- (void)hookUsingUserBlock:(id)block
{
    _kindOfHook     =   AutoPropertyHookKindOfBlock;
    _userSelector   =   nil;
    _userBlock      =   [block copy];
    IMP newimp      =   nil;
    if(self.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_lazy_property;
    }else{
        
        newimp = (IMP)apc_lazy_property_impimage(self.valueTypeEncoding);
    }
    [self hookPropertyWithImplementation:newimp];
}

const static char _keyForAPCLazyPropertyInstanceAssociatedPropertyInfo = '\0';

- (void)hookPropertyWithImplementation:(IMP)implementation
{
    _new_implementation = implementation;
    
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        ///AutoPropertyOwnerKindOfClass
        _old_implementation
        =
        class_replaceMethod(_des_class,
                            NSSelectorFromString(_des_property_name),
                            _new_implementation,
                            [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
#warning _old_implementation == nil => property is inherited from superclass
    }else{
        
        NSString *proxyClassName = apc_lazyLoadProxyClassName(_des_class);
        
        Class proxyClass = objc_allocateClassPair(_des_class, proxyClassName.UTF8String, 0);
        if(nil != proxyClass){
            
            objc_registerClassPair(proxyClass);
            
            _old_implementation
            =
            class_replaceMethod(proxyClass
                                , NSSelectorFromString(_des_property_name)
                                , _new_implementation
                                , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
            if(nil == _old_implementation){
                
                _old_implementation
                =
                class_getMethodImplementation(_des_class, NSSelectorFromString(_des_property_name));
            }
        }else if(nil == (proxyClass = objc_getClass(proxyClassName.UTF8String))){///Proxy already exists.
            
            NSAssert(proxyClass, @"Can not register class(:%@) at runtime.",proxyClassName);
        }
        
        ///Hook the isa point.
        object_setClass(_instance, proxyClass);
    }
    [self cache];
}

- (void)unhook
{
    if(_old_implementation && _new_implementation){
        
        if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
            
            _new_implementation = nil;
            class_replaceMethod(_des_class
                                , NSSelectorFromString(_des_property_name)
                                , _old_implementation
                                , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
        }else{
            
            [self invalid];
        }
    }
}


- (void)setValue:(id)value toTarget:(id)target
{
    if(self.accessOption & AutoPropertyComponentOfSetter){
        
        IMP imp = class_getMethodImplementation([target class]
                                                , self.propertySetter);
        
        NSAssert(imp
                 , @"APC: Can not find implementation named %@ in %@"
                 , NSStringFromSelector(self.propertySetter)
                 , [target class]);
        
        apc_setterimp_boxinvok(target
                               , self.propertySetter
                               , imp
                               , self.valueTypeEncoding.UTF8String
                               , value);
    }else{
        
        if(self.kindOfValue == AutoPropertyValueKindOfObject){
            
            object_setIvar(target, self.associatedIvar, value);
        }else{
            
            [target setValue:value forKey:@(ivar_getName(self.associatedIvar))];
        }
    }
}

#define apc_invok_bvOldIMP_toVal(type,val)\
\
type _val_t = ((type(*)(id, SEL))_old_implementation)\
(target, NSSelectorFromString(_des_property_name));\
val = [NSValue valueWithBytes:&_val_t objCType:self.valueTypeEncoding.UTF8String];

- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target
{
    if(NO == (_new_implementation && _old_implementation)){
        
        return nil;
    }
    
    return
    
    apc_getterimp_boxinvok(target
                           , NSSelectorFromString(_des_property_name)
                           , _old_implementation
                           , self.valueTypeEncoding.UTF8String);
}

static NSMutableDictionary* _cachedClassPropertyInfoMap;
- (void)cache
{
    if(_kindOfOwner == AutoPropertyOwnerKindOfInstance){
        ///Bind property info to instance.
        apc_lazyLoadSetInstanceAssociatedPropertyInfo(_instance
                                                      , NSSelectorFromString(_des_property_name)
                                                      , self);
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cachedClassPropertyInfoMap     =   [NSMutableDictionary dictionary];
    });
    
    @synchronized (_cachedClassPropertyInfoMap) {
        
        _cachedClassPropertyInfoMap[apc_lazyLoadKeyForClassPropertyMap(_src_class,_des_class,_des_property_name)] = self;
    }
}

- (void)removeFromCache
{
    @synchronized (_cachedClassPropertyInfoMap) {
        
        [_cachedClassPropertyInfoMap removeObjectForKey:apc_lazyLoadKeyForClassPropertyMap(_src_class,_des_class,_des_property_name)];
    }
}

+ (_Nullable instancetype)cachedInfoByClass:(Class)clazz
                               propertyName:(NSString*)propertyName
{
    ///Person,Man+APCProxyClassLazyLoad
    ///==
    ///Person,Man
    return
    
    [_cachedClassPropertyInfoMap objectForKey:apc_lazyLoadKeyForClassPropertyMap(srcClass,apc_lazyLoadInstanceGetSrcClass(desClass), propertyName)];
}

+ (void)removeAllCacheAndUnhookForClass:(Class)clazz
{
    @synchronized (_cachedClassPropertyInfoMap) {
        
        NSMutableArray* keysRm = [NSMutableArray array];
        NSEnumerator* enumerator = _cachedClassPropertyInfoMap.keyEnumerator;
        NSString* clzName = NSStringFromClass(clazz);
        NSString* key;
        while ((key = enumerator.nextObject)) {
            
            if(key.length < clzName.length){
                continue;
            }
            
            if((key.length == clzName.length
                && [key isEqualToString:clzName])
               
               || ([key rangeOfString:clzName].location == 0
                   && [key characterAtIndex:clzName.length] == '.')){
                   
                   [keysRm addObject:key];
                   [_cachedClassPropertyInfoMap[key] unhook];
               }
        }
        
        if(keysRm.count > 0){
            
            [_cachedClassPropertyInfoMap removeObjectsForKeys:keysRm];
        }
    }
}

+ (void)removeAllCacheAndUnhookForInstance:(id _Nonnull)instance
{
    if(apc_isLazyLoadInstance(instance) == NO){
        return;
    }
    
    [[apc_lazyLoadGetInstanceAssociatedMap(instance) allValues] makeObjectsPerformSelector:@selector(unhook)];
    
    apc_lazyLoadRemoveAllInstanceAssociatedPropertyInfo(instance);
    
    object_setClass(instance, apc_lazyLoadInstanceGetSrcClass([instance class]));
}



AutoLazyPropertyInfo* _Nullable apc_lazyLoadGetInstanceAssociatedPropertyInfo(id instance,SEL _CMD)
{
    NSMutableDictionary* map = apc_lazyLoadGetInstanceAssociatedMap(instance);
    return [map objectForKey:NSStringFromSelector(_CMD)];
}

static void apc_lazyLoadRemoveAllInstanceAssociatedPropertyInfo(id instance)
{
    objc_setAssociatedObject(instance
                             , &_keyForAPCLazyPropertyInstanceAssociatedPropertyInfo
                             , nil
                             , OBJC_ASSOCIATION_RETAIN);
}

static void apc_lazyLoadSetInstanceAssociatedPropertyInfo(id instance,SEL _CMD,id propertyInfo)
{
    NSMutableDictionary* map = apc_lazyLoadGetInstanceAssociatedMap(instance);
    @synchronized (map) {
        
        [map setObject:propertyInfo forKey:NSStringFromSelector(_CMD)];
    }
}

static NSMutableDictionary* _Nonnull apc_lazyLoadGetInstanceAssociatedMap(id instance)
{
    NSMutableDictionary* map =
    
    objc_getAssociatedObject(instance
                             , &_keyForAPCLazyPropertyInstanceAssociatedPropertyInfo);
    
    if(map == nil){
        
        static dispatch_semaphore_t semaphore;
        static dispatch_once_t onceTokenSemaphore;
        dispatch_once(&onceTokenSemaphore, ^{
            semaphore = dispatch_semaphore_create(1);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        {
            map = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(instance
                                     , &_keyForAPCLazyPropertyInstanceAssociatedPropertyInfo
                                     , map
                                     , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        dispatch_semaphore_signal(semaphore);
    }
    
    return map;
}

///Person/Man.age
///Person.age
///Person/Person+APCProxyClassLazyLoad.age
#warning 改成Person/Person+APCProxyClassLazyLoad.age

NS_INLINE Class apc_lazyLoadInstanceGetSrcClass(Class clazz)
{
    ///Person+APCProxyClassLazyLoad.age
    NSString* className = NSStringFromClass(clazz);
    
    if([className containsString:APCClassSuffixForLazyLoad]){
        
        className = [className substringToIndex:[className rangeOfString:@"/"].location];
        
        clazz = NSClassFromString(className);
    }
    return clazz;
}

static inline Class apc_lazyLoadGetDesClass(Class clazz)
{
    NSString* className = NSStringFromClass(clazz);
    
    NSUInteger from = [className rangeOfString:@"/"].location;
    from = (from == NSNotFound ? 0 : from + 1);
    NSUInteger to   = [className rangeOfString:@"."].location;
    className = [className substringWithRange:NSMakeRange(from, to - from)];
    return NSClassFromString(className);
}

NS_INLINE NSString* apc_lazyLoadProxyClassName(Class class){
    return [NSString stringWithFormat:@"%@%@",NSStringFromClass(class),APCClassSuffixForLazyLoad];
}

static inline NSString* apc_lazyLoadKeyForClassPropertyMap(Class srcClass,Class desClass,NSString* propertyName){
    
    if(srcClass == desClass){
        
        return [NSString stringWithFormat:@"%@.%@",NSStringFromClass(desClass),propertyName];
    }
    return [NSString stringWithFormat:@"%@/%@.%@",NSStringFromClass(srcClass),NSStringFromClass(desClass),propertyName];
}

NS_INLINE BOOL apc_isLazyLoadInstance(id _Nonnull instance)
{
    return [NSStringFromClass([instance class]) containsString:APCClassSuffixForLazyLoad];
}
@end

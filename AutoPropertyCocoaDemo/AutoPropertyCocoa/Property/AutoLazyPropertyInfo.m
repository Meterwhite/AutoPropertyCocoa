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
void* _Nullable apc_lazy_property_imp_byEnc(NSString* eType);


@implementation AutoLazyPropertyInfo
{
    IMP         _old_implementation;
    IMP         _new_implementation;
    NSString*   _des_property_name;
    SEL         _hooked_selector;
    id          _hooked_block;
}

- (id)hookedBlock
{
    return _hooked_block;
}

- (SEL)hookedSelector
{
    return _hooked_selector;
}

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                              aClass:(Class __unsafe_unretained)aClass
{
    if(self = [super initWithPropertyName:propertyName aClass:aClass]){
        
        _des_property_name =
        
        self.associatedGetter
        ? NSStringFromSelector(self.associatedGetter)
        : _org_property_name;
    }
    return self;
}

- (void)hookWithSelector:(SEL)aSelector
{
    _kindOfHook     =   AutoPropertyHookKindOfSelector;
    _hooked_selector=   aSelector?:@selector(new);
    _hooked_block   =   nil;
    IMP newimp      =   nil;
    if(self.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_lazy_property;
    }else{
        
        newimp = (IMP)apc_lazy_property_imp_byEnc(self.valueTypeEncoding);
    }
    
    [self hookPropertyWithImplementation:newimp];
}

- (void)hookUsingBlock:(id)block
{
    _kindOfHook     =   AutoPropertyHookKindOfBlock;
    _hooked_selector=   nil;
    _hooked_block   =   [block copy];
    IMP newimp      =   nil;
    if(self.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_lazy_property;
    }else{
        
        newimp = (IMP)apc_lazy_property_imp_byEnc(self.valueTypeEncoding);
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
        class_replaceMethod(_clazz,
                            NSSelectorFromString(_des_property_name),
                            _new_implementation,
                            [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
    }else{
        
        NSString *proxyClassName = APC_ProxyClassNameForLazyLoad(_clazz);
        
        Class proxyClass = objc_allocateClassPair(_clazz, proxyClassName.UTF8String, 0);
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
                class_getMethodImplementation(_clazz, NSSelectorFromString(_des_property_name));
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
    if(_old_implementation){
        
        if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
            
            _new_implementation = nil;
            class_replaceMethod(_clazz
                                , NSSelectorFromString(_des_property_name)
                                , _old_implementation
                                , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
            
            [self removeFromCache];
        }else{
            
            [self invalid];
        }
    }
}


#define apc_invok_bvSet_fromVal(type,value)\
\
type _val_t;\
[value getValue:&_val_t];\
((void (*)(id,SEL,type))objc_msgSend)(target,self.associatedSetter,_val_t);

- (void)setValue:(id)value toTarget:(id)target
{
    if(self.kvcOption & AutoPropertyKVCSetter){
        
        IMP imp = class_getMethodImplementation([target class]
                                                , self.associatedSetter);
        
        NSAssert(imp
                 , @"APC: Can not find implementation named %@ in %@"
                 , NSStringFromSelector(self.associatedSetter)
                 , [target class]);
        
        apc_setterimp_boxinvok(target
                               , self.associatedSetter
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
    
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    _cachedClassPropertyInfoMap[keyForCachedPropertyMap(_clazz,_des_property_name)] = self;
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeFromCache
{
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    [_cachedClassPropertyInfoMap removeObjectForKey:keyForCachedPropertyMap(_clazz,_des_property_name)];
    
    dispatch_semaphore_signal(semaphore);
}

+ (_Nullable instancetype)cachedInfoByClass:(Class)clazz
                               propertyName:(NSString*)propertyName;
{
    NSString* className = NSStringFromClass(clazz);
    
    if([className containsString:APCClassSuffixForLazyLoad]){
        
        className = [className substringToIndex:[className rangeOfString:@"/"].location];
        
        clazz = NSClassFromString(className);
    }
    return _cachedClassPropertyInfoMap[keyForCachedPropertyMap(clazz,propertyName)];
}


AutoLazyPropertyInfo* _Nullable apc_lazyLoadGetInstanceAssociatedPropertyInfo(id instance,SEL _CMD)
{
    NSMutableDictionary* map = apc_lazyLoadGetInstanceAssociatedMap(instance);
    return [map objectForKey:NSStringFromSelector(_CMD)];
}

//static void apc_lazyLoadRemoveInstanceAssociatedPropertyInfo(id instance,SEL _CMD)
//{
//    apc_lazyLoadSetInstanceAssociatedPropertyInfo(instance, _CMD, nil);
//}

//void apc_lazyLoadRemoveAllInstanceAssociatedPropertyInfo(id instance)
//{
//    objc_removeAssociatedObjects(instance);
//}

static void apc_lazyLoadSetInstanceAssociatedPropertyInfo(id instance,SEL _CMD,id propertyInfo)
{
    NSMutableDictionary* map = apc_lazyLoadGetInstanceAssociatedMap(instance);
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    {
        [map setObject:propertyInfo forKey:NSStringFromSelector(_CMD)];
    }
    dispatch_semaphore_signal(semaphore);
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
@end

//
//  AutoLazyPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by NOVO on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassPropertyMapperCache.h"
#import "AutoLazyPropertyInfo.h"
#import "NSObject+APCLazyLoad.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "APCScope.h"


id    _Nullable apc_lazy_property       (_Nullable id _self,SEL __cmd);
void* _Nullable apc_lazy_property_impimage(NSString* eType);


#pragma mark - Cache for instance

const static char _keyForAPCLazyLoadInstanceBindedCache = '\0';
static NSMutableDictionary* _Nonnull apc_lazyLoadInstanceBindedCache(id instance)
{
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSMutableDictionary* map = objc_getAssociatedObject(instance, &_keyForAPCLazyLoadInstanceBindedCache);
    if(map == nil){
        
        map = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(instance
                                 , &_keyForAPCLazyLoadInstanceBindedCache
                                 , map
                                 , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    dispatch_semaphore_signal(semaphore);
    
    return map;
}

AutoLazyPropertyInfo* _Nullable apc_lazyLoadGetInstanceFromBindedCache(id instance,SEL _CMD)
{
    NSMutableDictionary* map = apc_lazyLoadInstanceBindedCache(instance);
    return [map objectForKey:NSStringFromSelector(_CMD)];
}

static void apc_lazyLoadInstanceRemoveAllBindedCache(id instance)
{
    objc_setAssociatedObject(instance
                             , &_keyForAPCLazyLoadInstanceBindedCache
                             , nil
                             , OBJC_ASSOCIATION_RETAIN);
}

NS_INLINE void apc_lazyLoadInstanceSetObjectForBindedCache(id instance,SEL _CMD,id propertyInfo)
{
    NSMutableDictionary* map = apc_lazyLoadInstanceBindedCache(instance);
    @synchronized (map) {
        
        [map setObject:propertyInfo forKey:NSStringFromSelector(_CMD)];
    }
}

NS_INLINE BOOL apc_isLazyLoadInstance(id _Nonnull instance)
{
    return [NSStringFromClass([instance class]) containsString:APCClassSuffixForLazyLoad];
}

#pragma mark - Class name
/**
 Get original class from proxy class if need.
 :
 Class+APCProxyClassLazyLoad -> Class
 */
static Class apc_lazyLoadUnproxyClass(Class clazz)
{
    NSString* className = NSStringFromClass(clazz);
    
    if([className containsString:APCClassSuffixForLazyLoad]){
        
        className = [className substringToIndex:[className rangeOfString:@"+"].location];
        
        clazz = NSClassFromString(className);
    }
    return clazz;
}

/**
 Get proxy clas name with a common class.
 */
NS_INLINE NSString* apc_lazyLoadProxyClassName(Class class){
    return [NSString stringWithFormat:@"%@%@",NSStringFromClass(class),APCClassSuffixForLazyLoad];
}

#pragma mark - AutoLazyPropertyInfo

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
    _userSelector   =   aSelector?aSelector:@selector(new);
    _userBlock      =   nil;
    IMP newimp      =   nil;
    if(self.kindOfValue == AutoPropertyValueKindOfBlock ||
       self.kindOfValue == AutoPropertyValueKindOfObject){
        
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
    if(self.kindOfValue == AutoPropertyValueKindOfBlock ||
       self.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_lazy_property;
    }else{
        
        newimp = (IMP)apc_lazy_property_impimage(self.valueTypeEncoding);
    }
    [self hookPropertyWithImplementation:newimp];
}
/** Important */
- (void)hookPropertyWithImplementation:(IMP)implementation
{
    _new_implementation = implementation;
    
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        ///AutoPropertyOwnerKindOfClass
        _old_implementation
        =
        class_replaceMethod(_des_class
                            , NSSelectorFromString(_des_property_name)
                            , _new_implementation
                            , [NSString stringWithFormat:@"%@@:", self.valueTypeEncoding].UTF8String);
        
        if(nil == _old_implementation && (_des_class != _src_class)){
            
            ///Overwrite super class property with new property.
            ///Storing the implementation address of the super class
            
            ///Superclass and subclass used the same old implementation that is from superclass
            
            AutoLazyPropertyInfo* pinfo_superclass
            =
            [_cacheForClass propertyForDesclass:_src_class property:_des_property_name];
            
            if(nil != pinfo_superclass){
                
                ///From super class old imp.
                _old_implementation = pinfo_superclass->_old_implementation;
            }else{
                
                ///From super class new imp.
                _old_implementation
                =
                class_getMethodImplementation(_src_class, NSSelectorFromString(_des_property_name));
            }
//            NSAssert(_old_implementation, @"APC: _old_implementation can not be nil.");
        }
        
        [self cache];
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
        
        [self bindInstancePropertyInfo];
    }
}

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

- (void)unhook
{
    if(_old_implementation && _new_implementation){
        
        if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
            
            _new_implementation = nil;
            
            class_replaceMethod(_des_class
                                , NSSelectorFromString(_des_property_name)
                                , _old_implementation
                                , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
        }
    }
    [self invalid];
}

- (id _Nullable)instancetypeNewObjectByUserSelector
{
    Class clzz = self.propertyClass;
    NSMethodSignature *signature = [clzz methodSignatureForSelector:self.userSelector];
    
    NSAssert(signature, @"APC: Can not find %@ in class %@.",NSStringFromSelector(self.userSelector),NSStringFromClass(clzz));
    
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = clzz;
    invocation.selector = self.userSelector;
    [invocation invoke];
    if (signature.methodReturnLength) {
        
        id __unsafe_unretained returnValue;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

- (id)performUserBlock:(id)_SELF
{
    return _userBlock
    
    ? ((id(^)(id))_userBlock)(_SELF)
    
    : nil;
}

- (void)setValue:(id)value toTarget:(id)target
{
    NSAssert(self.accessOption & AutoPropertySetValueEnable, @"APC: Object %@ must have setter or _ivar.",target);
    
    if(YES == (self.accessOption & AutoPropertyAssociatedSetter) ||
       YES == (self.accessOption & AutoPropertyComponentOfSetter)){
        
        ///set value by setter
        IMP imp = class_getMethodImplementation([target class]
                                                , (nil != self.propertySetter)
                                                ? self.propertySetter
                                                : self.associatedSetter);
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
        
        ///set value to ivar
        if(self.kindOfValue == AutoPropertyValueKindOfBlock ||
           self.kindOfValue == AutoPropertyValueKindOfObject){
            
            object_setIvar(target, self.associatedIvar, value);
        }else{
            
            [target setValue:value forKey:@(ivar_getName(self.associatedIvar))];
        }
    }
}

#pragma mark - cache strategy

static APCClassPropertyMapperCache* _cacheForClass;
- (void)cache
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cacheForClass     =   [APCClassPropertyMapperCache cache];
    });
    
    
    [_cacheForClass addProperty:self];
}

- (void)removeFromCache
{
    [_cacheForClass removeProperty:self];
}

- (void)bindInstancePropertyInfo
{
    apc_lazyLoadInstanceSetObjectForBindedCache(_instance
                                                  , NSSelectorFromString(_des_property_name)
                                                  , self);
}

+ (_Nullable instancetype)cachedInfoByClass:(Class)clazz
                               propertyName:(NSString*)propertyName
{
    clazz = apc_lazyLoadUnproxyClass(clazz);
    
    return [_cacheForClass propertyForDesclass:clazz property:propertyName];
}

+ (void)removeCacheForClass:(Class)clazz
{
    clazz  = apc_lazyLoadUnproxyClass(clazz);
    
    [_cacheForClass removePropertiesWithSrcclass:clazz];
}

+ (void)unbindlazyLoadForInstance:(id _Nonnull)instance
{
    if(apc_isLazyLoadInstance(instance) == NO){
        return;
    }
    ///unhook instance
    [[apc_lazyLoadInstanceBindedCache(instance) allValues] makeObjectsPerformSelector:@selector(unhook)];
    ///remove from cache
    apc_lazyLoadInstanceRemoveAllBindedCache(instance);
    ///unhook class
    object_setClass(instance, apc_lazyLoadUnproxyClass([instance class]));
}

//- (BOOL)isEqual:(id)object
//{
//    if(self == object)
//
//        return YES;
//
//    return [self hash] == [object hash];
//}

//- (NSUInteger)hash
//{
//#define MAXALIGN (__alignof__(_Complex long double))
//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunreachable-code"
//
//    static int shift = (MAXALIGN==16 ? 4 : (MAXALIGN==8 ? 3 : 2));
//#pragma clang diagnostic pop
//
//    return (NSUInteger)((uintptr_t)self >> shift);
//}

@end



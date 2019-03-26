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
            _cacheForClass[apc_lazyLoadKeyForClassCache(_src_class, _src_class, _des_property_name)];
            
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
                                                , self.propertySetter?:self.associatedSetter);
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

static NSMutableDictionary* _cacheForClass;
- (void)cache
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cacheForClass     =   [NSMutableDictionary dictionary];
    });
    
    @synchronized (_cacheForClass) {
        
        _cacheForClass[apc_lazyLoadKeyForClassCache(_src_class,_des_class,_des_property_name)] = self;
    }
}

- (void)removeFromCache
{
    @synchronized (_cacheForClass) {
        
        [_cacheForClass removeObjectForKey:apc_lazyLoadKeyForClassCache(_src_class,_des_class,_des_property_name)];
    }
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
    NSEnumerator*   enumerator = _cacheForClass.keyEnumerator;
    NSString*       matched    = [NSString stringWithFormat:@"%@.%@",NSStringFromClass(clazz),propertyName];
    NSString*       key;
    NSUInteger      loc;
    while (nil != (key = enumerator.nextObject)) {
        
        loc = [key rangeOfString:matched].location;
        if(loc != NSNotFound){
            //   /a
            if((key.length == loc + matched.length)
               && ([key characterAtIndex:loc - 1] == '/')){
                
                return _cacheForClass[key];
            }
        }
    }
    
    return nil;
}

+ (void)removeCacheForClass:(Class)clazz
{
    clazz  = apc_lazyLoadUnproxyClass(clazz);
    @synchronized (_cacheForClass) {
        
        NSEnumerator*   enumerator  = _cacheForClass.keyEnumerator;
        NSString*       clzName     = NSStringFromClass(clazz);
        NSMutableArray* keysRm      = [NSMutableArray array];
        NSString*       key;
        NSUInteger      loc;
        while ((key = enumerator.nextObject)) {
            
            loc = [key rangeOfString:clzName].location;
            
            if(NSNotFound != loc){
                
                ///Match/Nomatch.p
                if(loc == 0
                   
                   ///Nomatch/Match.p and Match/Match.p
                   || ([key characterAtIndex:loc - 1] == '/'
                       && key.length > loc + clzName.length + 1
                       && [key characterAtIndex:loc + clzName.length] == '.')){
                    
                    [keysRm addObject:key];
                    [_cacheForClass[key] unhook];
                }
            }
        }
        
        if(keysRm.count > 0){
            
            [_cacheForClass removeObjectsForKeys:keysRm];
        }
    }
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


#pragma mark - cache for instance

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

NS_INLINE BOOL apc_isLazyLoadInstance(id _Nonnull instance)
{
    return [NSStringFromClass([instance class]) containsString:APCClassSuffixForLazyLoad];
}

#pragma mark - cache for class
/**
 Get original class from proxy class if need.
 :
 Class+APCProxyClassLazyLoad -> Class
 */
NS_INLINE Class apc_lazyLoadUnproxyClass(Class clazz)
{
    NSString* className = NSStringFromClass(clazz);
    
    if([className containsString:APCClassSuffixForLazyLoad]){
        
        className = [className substringToIndex:[className rangeOfString:@"+"].location];
        
        clazz = NSClassFromString(className);
    }
    return clazz;
}

//static inline Class apc_lazyLoadGetDesClass(Class clazz)
//{
//    NSString* className = NSStringFromClass(clazz);
//
//    NSUInteger from = [className rangeOfString:@"/"].location;
//    from = (from == NSNotFound ? 0 : from + 1);
//    NSUInteger to   = [className rangeOfString:@"."].location;
//    className = [className substringWithRange:NSMakeRange(from, to - from)];
//    return NSClassFromString(className);
//}

/**
 Get proxy clas name with a common class.
 */
NS_INLINE NSString* apc_lazyLoadProxyClassName(Class class){
    return [NSString stringWithFormat:@"%@%@",NSStringFromClass(class),APCClassSuffixForLazyLoad];
}

NS_INLINE NSString* apc_lazyLoadKeyForClassCache(Class srcClass,Class desClass,NSString* propertyName){
    
    return [NSString stringWithFormat:@"%@/%@.%@",NSStringFromClass(srcClass),NSStringFromClass(desClass),propertyName];
}

@end

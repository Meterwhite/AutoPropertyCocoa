//
//  APCLazyProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "NSObject+APCLazyLoad.h"
#import "APCLazyProperty.h"
#import "APCPropertyHook.h"
#import "APCRuntime.h"
#import "APCScope.h"

#pragma mark - APCLazyProperty

@implementation APCLazyProperty


- (instancetype)initWithPropertyName:(NSString *)propertyName aClass:(__unsafe_unretained Class)aClass
{
    if(self = [super initWithPropertyName:propertyName
                                   aClass:aClass]){
        
        
        _methodStyle    =   APCMethodGetterStyle;
        _hooked_name    =   _des_getter_name;
        if(self.kindOfOwner == APCPropertyOwnerKindOfClass){
            
            if(self.kindOfValue != APCPropertyValueKindOfObject
               && self.kindOfValue != APCPropertyValueKindOfBlock){
                
                NSAssert(NO, @"APC: Disable binding on basic-value type properties for class types.");
            }
        }
    }
    return self;
}

- (void)bindingUserSelector:(SEL)aSelector
{
    _kindOfUserHook =   APCPropertyHookKindOfSelector;
    _userSelector   =   aSelector?:@selector(new);
    _userBlock      =   nil;
}

- (void)bindindUserBlock:(id)block
{
    _kindOfUserHook =   APCPropertyHookKindOfBlock;
    _userBlock      =   [block copy];
    _userSelector   =   nil;
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
    NSAssert(self.accessOption & APCPropertySetValueEnable, @"APC: Object %@ must have setter or _ivar.",target);
    
    if((self.accessOption & APCPropertyAssociatedSetter)
       || (self.accessOption & APCPropertyComponentOfSetter)){
        
        ///Set value by setter
        IMP imp = class_getMethodImplementation([target class]
                                                , self.propertySetter ?: self.associatedSetter);
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
        
        ///Set value to ivar
        if(self.kindOfValue == APCPropertyValueKindOfBlock ||
           self.kindOfValue == APCPropertyValueKindOfObject){
            
            object_setIvar(target, self.associatedIvar, value);
        }else{
            
            [target setValue:value forKey:@(ivar_getName(self.associatedIvar))];
        }
    }
}

- (void)dealloc
{
    NSLog(@"");
}

@end


#pragma mark - Cache strategy

//- (void)cacheToInstanceMapper
//{
//    [APCInstancePropertyCacheManager bindProperty:self
//                                       toInstance:_instance
//                                              cmd:_des_getter_name];
//}
//
//- (void)removeFromInstanceCache
//{
//
//    [APCInstancePropertyCacheManager boundPropertyRemoveFromInstance:_instance
//                                                                 cmd:_des_getter_name];
//
//    if(NO == [APCInstancePropertyCacheManager boundContainsValidPropertyForInstance:_instance]){
//
//        [APCInstancePropertyCacheManager boundAllPropertiesRemoveFromInstance:_instance];
//    }
//}
//
//static APCClassPropertyMapperController* _cacheForClass;
//- (void)cacheToClassMapper
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        _cacheForClass     =   [APCClassPropertyMapperController cache];
//    });
//
//    [_cacheForClass addProperty:self];
//}
//
//- (void)removeFromClassCache
//{
//    [_cacheForClass removeProperty:self];
//}
//
//+ (_Nullable instancetype)cachedTargetClass:(Class)clazz
//                                   property:(NSString*)property
//{
//    clazz = [self unproxyClass:clazz];
//
//    return [_cacheForClass propertyForDesclass:clazz property:property];
//}
//
//+ (instancetype)cachedFromAClassByInstance:(id)instance property:(NSString *)property
//{
//
//    NSUInteger lenth = [APCLazyloadOldLoopController loopCount:instance];
//
//
//    if(lenth == 0){
//
//        return [self cachedFromAClass:[instance class] property:property];
//    }
//
//    APCLazyProperty*   p;
//    Class                   clazz = [instance class];
//    while (lenth) {
//
//        while ((clazz = [clazz superclass])) {
//
//            if(clazz == nil) return p;
//
//            if(nil != (p = [self cachedTargetClass:clazz property:property])){
//
//                --lenth;
//                break;
//            }
//        }
//    }
//
//    return p;
//}
//
//+ (_Nullable instancetype)cachedFromAClass:(Class)aClazz
//                                  property:(NSString*)property
//{
//    aClazz = [self unproxyClass:aClazz];
//
//    return [_cacheForClass searchFromTargetClass:aClazz property:property];
//}



//    IMP newimp      =   nil;
//    if(self.kindOfValue == APCPropertyValueKindOfBlock ||
//       self.kindOfValue == APCPropertyValueKindOfObject){
//
//        newimp = (IMP)apc_lazy_property;
//    }else{
//
//        newimp = (IMP)apc_lazy_property_impimage(self.valueTypeEncoding);
//    }
//
//    [self hookPropertyWithImplementation:newimp option:0];
//
//    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
//
//        [self cacheToClassMapper];
//    }else{
//
//        [self cacheToInstanceMapper];
//    }
//    IMP newimp      =   nil;
//    if(self.kindOfValue == APCPropertyValueKindOfBlock ||
//       self.kindOfValue == APCPropertyValueKindOfObject){
//
//        newimp = (IMP)apc_lazy_property;
//    }else{
//
//        newimp = (IMP)apc_lazy_property_impimage(self.valueTypeEncoding);
//    }
//    [self hookPropertyWithImplementation:newimp option:0];

//    ///Cache
//    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
//
//        [self cacheToClassMapper];
//    }else{
//
//        [self cacheToInstanceMapper];
//    }
/** Important */
//- (void)hookPropertyWithImplementation:(IMP)implementation option:(NSUInteger)option
//{
//    _new_getter_implementation = implementation;
//
//    if(_kindOfOwner == APCPropertyOwnerKindOfClass){
//
//        ///APCPropertyOwnerKindOfClass
//        _old_getter_implementation
//        =
//        class_replaceMethod(_des_class
//                            , NSSelectorFromString(_des_getter_name)
//                            , _new_getter_implementation
//                            , [NSString stringWithFormat:@"%@@:", self.valueTypeEncoding].UTF8String);
//
//        if(nil == _old_getter_implementation){
//
//            ///Overwrite super class property with new property.
//            ///Storing the implementation address of the super class
//
//            ///Superclass and subclass used the same old implementation that is from superclass.
//
//            APCLazyProperty* pinfo_superclass
//            =
//            [_cacheForClass propertyForDesclass:_src_class property:_des_getter_name];
//
//            if(nil != pinfo_superclass){
//
//                _old_getter_implementation = pinfo_superclass->_new_getter_implementation;
//            }else{
//
//                _old_getter_implementation
//                =
//                class_getMethodImplementation(_src_class
//                                              , NSSelectorFromString(_des_getter_name));
//            }
//
//            NSAssert(_old_getter_implementation, @"APC: Can not find original implementation.");
//        }
//    }
//    else{
//
//        Class proxyClass;
//        if(NO == [APCLazyProperty testingProxyClassInstance:_instance])
//        {
//
//            NSString *proxyClassName = self.proxyClassName;
//            proxyClass = objc_allocateClassPair(_des_class, proxyClassName.UTF8String, 0);
//            if(nil != proxyClass){
//
//                objc_registerClassPair(proxyClass);
//            }else if(nil == (proxyClass = objc_getClass(proxyClassName.UTF8String))){///Proxy already exists.
//
//                NSAssert(proxyClass, @"Can not register class(:%@) at runtime.",proxyClassName);
//            }
//
//            ///Hook the isa point.
//            object_setClass(_instance, proxyClass);
//        }else{
//
//            proxyClass = [_instance class];
//        }
//        _proxyClass = proxyClass;
//
//        _old_getter_implementation
//        =
//        class_replaceMethod(proxyClass
//                            , NSSelectorFromString(_des_getter_name)
//                            , _new_getter_implementation
//                            , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
//        if(nil == _old_getter_implementation){
//
//            _old_getter_implementation
//            =
//            class_getMethodImplementation(_des_class
//                                          , NSSelectorFromString(_des_getter_name));
//        }
//    }
//}

//- (void)unhook
//{
//    if(nil == _old_getter_implementation || nil == _new_getter_implementation){
//
//        return;
//    }
//
//    [self invalid];
//
//    if(_kindOfOwner == APCPropertyOwnerKindOfClass)
//    {
//        [self unhookForClass];
//        [self removeFromClassCache];
//    }
//    else
//    {
//        if(NO == [APCLazyProperty testingProxyClassInstance:_instance]){
//            ///Instance has been unbound by other threads.
//            return;
//        }
//
//        [self unhookForInstance];
//        [self removeFromInstanceCache];
//    }
//}

//+ (void)unhookClassAllProperties:(Class _Nonnull __unsafe_unretained)clazz
//{
//    clazz  = [self unproxyClass:clazz];
//
//    [[_cacheForClass propertiesForSrcclass:clazz] makeObjectsPerformSelector:@selector(unhook)];
//}

//- (void)unhookForClass
//{
//    _new_getter_implementation = nil;
//
//    class_replaceMethod(_des_class
//                        , NSSelectorFromString(_des_getter_name)
//                        , _old_getter_implementation
//                        , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
//}

//- (void)unhookForInstance
//{
//    if([APCInstancePropertyCacheManager boundContainsValidPropertyForInstance:_instance]){
//
//        _new_getter_implementation = nil;
//
//        class_replaceMethod([_instance class]
//                            , NSSelectorFromString(_des_getter_name)
//                            , _old_getter_implementation
//                            , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
//    }else{
//
//
//        object_setClass(_instance, _des_class);
//
//        objc_disposeClassPair(_proxyClass);
//    }
//}



//    if(NO == (_new_getter_implementation && _old_getter_implementation)){
//
//        return nil;
//    }
//
//    [APCLazyloadOldLoopController joinLoop:target];
//
//    id ret
//    =
//    apc_getterimp_boxinvok(target
//                           , NSSelectorFromString(_des_getter_name)
//                           , _old_getter_implementation
//                           , self.valueTypeEncoding.UTF8String);
//
//    [APCLazyloadOldLoopController breakLoop:target];
//
//    return ret;

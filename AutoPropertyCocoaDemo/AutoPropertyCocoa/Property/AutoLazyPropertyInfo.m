//
//  AutoLazyPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCInstancePropertyCacheManager.h"
#import "APCClassPropertyMapperCache.h"
#import "AutoLazyPropertyInfo.h"
#import "NSObject+APCLazyLoad.h"
#import <objc/runtime.h>
#import "APCScope.h"


id    _Nullable apc_lazy_property       (_Nullable id _self,SEL __cmd);
void* _Nullable apc_lazy_property_impimage(NSString* eType);


#pragma mark - AutoLazyPropertyInfo

@implementation AutoLazyPropertyInfo
{
    SEL         _userSelector;
    id          _userBlock;
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
    
    [self hookPropertyWithImplementation:newimp option:0];
    
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        [self cacheToClassMapper];
    }else{
        
        [self cacheToInstanceMapper];
    }
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
    [self hookPropertyWithImplementation:newimp option:0];
    
    ///Cache
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass){
        
        [self cacheToClassMapper];
    }else{
        
        [self cacheToInstanceMapper];
    }
}
/** Important */
- (void)hookPropertyWithImplementation:(IMP)implementation option:(NSUInteger)option
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
        
        if(nil == _old_implementation){
            
            ///Overwrite super class property with new property.
            ///Storing the implementation address of the super class
            
            ///Superclass and subclass used the same old implementation that is from superclass.
            
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
                class_getMethodImplementation(_src_class
                                              , NSSelectorFromString(_des_property_name));
            }
            
            NSAssert(_old_implementation, @"APC: Can not find old implementation.");
        }
    }
    else{
        
        Class proxyClass;
        if(NO == [AutoLazyPropertyInfo testingProxyClassInstance:_instance]){
            
            NSString *proxyClassName = self.proxyClassName;
            proxyClass = objc_allocateClassPair(_des_class, proxyClassName.UTF8String, 0);
            if(nil != proxyClass){
                
                objc_registerClassPair(proxyClass);
                
            }else if(nil == (proxyClass = objc_getClass(proxyClassName.UTF8String))){///Proxy already exists.
                
                NSAssert(proxyClass, @"Can not register class(:%@) at runtime.",proxyClassName);
            }
            
            ///Hook the isa point.
            object_setClass(_instance, proxyClass);
        }else{
            
            proxyClass = [_instance class];
        }
        
        _old_implementation
        =
        class_replaceMethod(proxyClass
                            , NSSelectorFromString(_des_property_name)
                            , _new_implementation
                            , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
        if(nil == _old_implementation){
            
            _old_implementation
            =
            class_getMethodImplementation(_des_class
                                          , NSSelectorFromString(_des_property_name));
        }
    }
}

- (void)unhook
{
    if(nil == _old_implementation || nil == _new_implementation){
        
        return;
    }
        
    [self invalid];
    
    if(_kindOfOwner == AutoPropertyOwnerKindOfClass)
    {
        [self unhookForClass];
        [self removeFromClassCache];
    }
    else
    {
        if(NO == [AutoLazyPropertyInfo testingProxyClassInstance:_instance]){
            ///Instance has been unbound by other threads.
            return;
        }
        
        [self unhookForInstance];
        [self removeFromInstanceCache];
    }
}

+ (void)unhookClassAllProperties:(Class _Nonnull __unsafe_unretained)clazz
{
    clazz  = [self unproxyClass:clazz];
    
    [[_cacheForClass propertiesForSrcclass:clazz] makeObjectsPerformSelector:@selector(unhook)];
}

- (void)unhookForClass
{
    _new_implementation = nil;
    
    class_replaceMethod(_des_class
                        , NSSelectorFromString(_des_property_name)
                        , _old_implementation
                        , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
}

- (void)unhookForInstance
{
    if([APCInstancePropertyCacheManager boundContainsValidPropertyForInstance:_instance]){
        
        _new_implementation = nil;
        
        class_replaceMethod([_instance class]
                            , NSSelectorFromString(_des_property_name)
                            , _old_implementation
                            , [NSString stringWithFormat:@"%@@:",self.valueTypeEncoding].UTF8String);
    }else{
        
        
        object_setClass(_instance, _des_class);
        
        objc_disposeClassPair([_instance class]);
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
        if(self.kindOfValue == AutoPropertyValueKindOfBlock ||
           self.kindOfValue == AutoPropertyValueKindOfObject){
            
            object_setIvar(target, self.associatedIvar, value);
        }else{
            
            [target setValue:value forKey:@(ivar_getName(self.associatedIvar))];
        }
    }
}

#pragma mark - Cache strategy

- (void)cacheToInstanceMapper
{
    [APCInstancePropertyCacheManager bindProperty:self
                                       toInstance:_instance
                                              cmd:_des_property_name];
}

- (void)removeFromInstanceCache
{
    
    [APCInstancePropertyCacheManager boundPropertyRemoveFromInstance:_instance
                                                                 cmd:_des_property_name];
    
    if(NO == [APCInstancePropertyCacheManager boundContainsValidPropertyForInstance:_instance]){
        
        [APCInstancePropertyCacheManager boundAllPropertiesRemoveFromInstance:_instance];
    }
}

static APCClassPropertyMapperCache* _cacheForClass;
- (void)cacheToClassMapper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cacheForClass     =   [APCClassPropertyMapperCache cache];
    });
    
    [_cacheForClass addProperty:self];
}

- (void)removeFromClassCache
{
    [_cacheForClass removeProperty:self];
}

+ (_Nullable instancetype)cachedWithClass:(Class)clazz
                                       property:(NSString*)property
{
    clazz = [self unproxyClass:clazz];
    
    return [_cacheForClass propertyForDesclass:clazz property:property];
}


#pragma mark - AutoPropertyHookProxyClassNameProtocol
- (NSString*)proxyClassName
{
    //Class+APCProxyClass.hash
    return [NSString stringWithFormat:@"%@%@.%lu"
            , NSStringFromClass(_des_class)
            , APCClassSuffixForLazyLoad
            , (unsigned long)[_instance hash]];
}
+ (Class)unproxyClass:(Class)clazz
{
    NSString* className = NSStringFromClass(clazz);
    
    if([className containsString:APCClassSuffixForLazyLoad]){
        
        className = [className substringToIndex:[className rangeOfString:@"+"].location];
        
        clazz = NSClassFromString(className);
    }
    return clazz;
}
+ (BOOL)testingProxyClassInstance:(id)instance
{
    return [NSStringFromClass([instance class]) containsString:APCClassSuffixForLazyLoad];
}
@end



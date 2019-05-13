//
//  APCLazyProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//
//#import "NSObject+APCLazyLoad.h"
#import "APCLazyProperty.h"
#import "APCPropertyHook.h"
#import "APCRuntime.h"
#import "APCScope.h"

@implementation APCLazyProperty

- (instancetype)initWithPropertyName:(NSString *)propertyName
                              aClass:(__unsafe_unretained Class)aClass
{
    if(self = [super initWithPropertyName:propertyName
                                   aClass:aClass]){
        
        _inlet          =   @selector(setLazyload:);
        _methodStyle    =   APCMethodGetterStyle;
        _outlet         =   @selector(lazyload);
        _hooked_name    =   _des_getter_name;
        if(self.kindOfOwner == APCPropertyOwnerKindOfClass){
            
            if(self.kindOfValue != APCPropertyValueKindOfObject
               && self.kindOfValue != APCPropertyValueKindOfBlock){
                
                NSAssert(NO, @"APC: Disable binding on basic-value property for class object.");
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
    Class               clzz = self.propertyClass;
    NSMethodSignature*  signature = [clzz methodSignatureForSelector:self.userSelector];
    
    NSAssert(signature, @"APC: Can not find %@ in class %@."
             , NSStringFromSelector(self.userSelector)
             , NSStringFromClass(clzz));
    
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
        
        APCBoxedInvokeBasicValueSetterIMP(target
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

#if DEBUG
- (void)dealloc
{
    NSLog(@"%s",__func__);
}
#endif

- (id)performLazyloadForTarget:(id)target
{
    /**
     Lazy-load is a complete override method
     , so super-propery should not be called here.
     */
    id v;
    ///Safe
    if(self.accessOption & APCPropertyComponentOfGetter){
        
        v = [self.associatedHook performOldGetterFromTarget:target];
    }else{
        
        v = [self getIvarValueFromTarget:target];
    }
    
    if(v == nil &&
       (self.kindOfValue == APCPropertyValueKindOfBlock ||
        self.kindOfValue == APCPropertyValueKindOfObject))
    {
        ///Create default value.
        if(self.kindOfUserHook == APCPropertyHookKindOfSelector)
        {
            v = [self instancetypeNewObjectByUserSelector];
        }
        else
        {
            v = [self performUserBlock:APCUserEnvironmentObject(target, self)];
        }
        [self setValue:v toTarget:target];
    }
    else if (self.accessCount == 0 &&
             (self.kindOfValue != APCPropertyValueKindOfBlock ||
              self.kindOfValue != APCPropertyValueKindOfObject))
    {
        
        NSCAssert(self.kindOfUserHook == APCPropertyHookKindOfBlock
                  , @"APC: Basic-value only supportted be initialized by 'userblock'.");
        
        v = [self performUserBlock:APCUserEnvironmentObject(target, self)];
        [self setValue:v toTarget:target];
    }
    return v;
}

@end

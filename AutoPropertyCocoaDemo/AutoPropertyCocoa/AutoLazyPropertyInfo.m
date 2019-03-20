//
//  AutoLazyPropertyInfo.m
//  AutoPropertyCocoaDemo
//
//  Created by NOVO on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+AutoPropertyCocoa.h"
#import "AutoPropertyCocoaConst.h"
#import "NSObject+APCExtension.h"
#import "AutoLazyPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>

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
        
        _des_property_name = self.associatedGetter
        ? NSStringFromSelector(self.associatedGetter)
        : _org_property_name;
    }
    return self;
}

- (void)hookSelector:(SEL)aSelector
{
    _hooked_selector = aSelector?:@selector(new);
    _hooked_block = nil;
    
    _hookType &= ~AutoPropertyHookByBlock;
    _hookType |= AutoPropertyHookBySelector;
    
    IMP newimp = nil;
    if(self.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_lazy_property;
    }else{
        
        newimp = (IMP)apc_lazy_property_imp_byEnc(self.valueTypeEncode);
    }
    
    [self bindGetterWithImplementation:newimp];
}

- (void)hookBlock:(id)block
{
    _hooked_selector = nil;
    _hooked_block = [block copy];
    _hookType &= ~AutoPropertyHookBySelector;
    _hookType |= AutoPropertyHookByBlock;
    
    IMP newimp = nil;
    if(self.kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_lazy_property;
    }else{
        
        newimp = (IMP)apc_lazy_property_imp_byEnc(self.valueTypeEncode);
    }
    [self bindGetterWithImplementation:newimp];
}

const static char _keyForAPCLazyPropertyInstanceAssociatedPropertyInfo = '\0';

- (void)bindGetterWithImplementation:(IMP)implementation
{
    _new_implementation = implementation;
    
    if(_hookType & AutoPropertyHookedToClass){
        
        
        ///AutoPropertyHookedToClass
        _old_implementation
        =
        class_replaceMethod(_clazz,
                            NSSelectorFromString(_des_property_name),
                            _new_implementation,
                            [NSString stringWithFormat:@"%@@:",self.valueTypeEncode].UTF8String);
        [self cache];
    }else{
        
        NSString *proxyClassName = [NSString stringWithFormat:@"APCLazyProperty_%@", NSStringFromClass(_clazz)];
        
        Class proxyClass = proxyClass = objc_allocateClassPair([self class], proxyClassName.UTF8String, 0);
        if(nil != proxyClass){
            
            objc_registerClassPair(proxyClass);
        }else if(nil == (proxyClass = objc_getMetaClass(proxyClassName.UTF8String))){
            
            NSAssert(proxyClass, @"Can not register class(:%@) at runtime.",proxyClassName);
        }
        
        Method method = class_getInstanceMethod(_clazz, NSSelectorFromString(_des_property_name));
        if(nil == method){
            
            if(NO == class_addMethod(proxyClass, NSSelectorFromString(_des_property_name), _new_implementation, "@@:")){
                
                NSAssert(NO, @"Can not add method to class(:%@).",proxyClassName);
            }
        }
        
        objc_setAssociatedObject(_instance
                                 , &_keyForAPCLazyPropertyInstanceAssociatedPropertyInfo
                                 , self
                                 , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        ///Hook the isa
        object_setClass(self, proxyClass);
    }
}

id _Nullable apc_getLazyPropertyInstanceAssociatedPropertyInfo(id _SELF)
{
    return objc_getAssociatedObject(_SELF, &_keyForAPCLazyPropertyInstanceAssociatedPropertyInfo);
}

- (void)unhook
{
    if(_old_implementation){
        
        _new_implementation = nil;
        
        class_replaceMethod(_clazz,
                            NSSelectorFromString(_des_property_name),
                            _old_implementation,
                            [NSString stringWithFormat:@"%@@:",self.valueTypeEncode].UTF8String);
    }
    
    [self removeFromCache];
}


#define apc_invok_bvSet_fromVal(type,value)\
\
type _val_t;\
[value getValue:&_val_t];\
((void (*)(id,SEL,type))objc_msgSend)(target,self.associatedSetter,_val_t);

- (void)setValue:(id)value toTarget:(id)target
{
    if(self.kvcOption & AutoPropertyKVCSetter){
        
        if(self.kindOfValue == AutoPropertyValueKindOfObject){
            
            ((void (*)(id,SEL,id))objc_msgSend)(target,self.associatedSetter,value);
        }else{
            
            if([self.valueTypeEncode isEqualToString:@"c"]){
                apc_invok_bvSet_fromVal(char,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"i"]){
                apc_invok_bvSet_fromVal(int,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"s"]){
                apc_invok_bvSet_fromVal(short,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"l"]){
                apc_invok_bvSet_fromVal(long,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"q"]){
                apc_invok_bvSet_fromVal(long long,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"C"]){
                apc_invok_bvSet_fromVal(unsigned char,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"I"]){
                apc_invok_bvSet_fromVal(unsigned int,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"S"]){
                apc_invok_bvSet_fromVal(unsigned short,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"L"]){
                apc_invok_bvSet_fromVal(unsigned long,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"Q"]){
                apc_invok_bvSet_fromVal(unsigned long long,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"f"]){
                apc_invok_bvSet_fromVal(float,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"d"]){
                apc_invok_bvSet_fromVal(double,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"B"]){
                apc_invok_bvSet_fromVal(BOOL,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"*"]){
                apc_invok_bvSet_fromVal(char*,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@"#"]){
                apc_invok_bvSet_fromVal(Class,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@":"]){
                apc_invok_bvSet_fromVal(SEL,value)
            }
            else if ([self.valueTypeEncode characterAtIndex:0] == '^'){
                apc_invok_bvSet_fromVal(void*,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@(@encode(APC_RECT))]){
                apc_invok_bvSet_fromVal(APC_RECT,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@(@encode(APC_POINT))]){
                apc_invok_bvSet_fromVal(APC_POINT,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@(@encode(APC_SIZE))]){
                apc_invok_bvSet_fromVal(APC_SIZE,value)
            }
            else if ([self.valueTypeEncode isEqualToString:@(@encode(NSRange))]){
                apc_invok_bvSet_fromVal(NSRange,value)
            }
            ///enc-m
        }
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
val = [NSValue valueWithBytes:&_val_t objCType:self.valueTypeEncode.UTF8String];

- (_Nullable id)performOldGetterFromTarget:(_Nonnull id)target
{
    if(NO == (_new_implementation && _old_implementation)){
        
        return nil;
    }
    
    id ret;
    
    if(self.kindOfValue == AutoPropertyValueKindOfObject){
        
        ret
        =
        ((id(*)(id, SEL))_old_implementation)
        
        (target, NSSelectorFromString(_des_property_name));
    }else{
        
        
        if([self.valueTypeEncode isEqualToString:@"c"]){
            apc_invok_bvOldIMP_toVal(char,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"i"]){
            apc_invok_bvOldIMP_toVal(int,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"s"]){
            apc_invok_bvOldIMP_toVal(short,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"l"]){
            apc_invok_bvOldIMP_toVal(long,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"q"]){
            apc_invok_bvOldIMP_toVal(long long,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"C"]){
            apc_invok_bvOldIMP_toVal(unsigned char,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"I"]){
            apc_invok_bvOldIMP_toVal(unsigned int,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"S"]){
            apc_invok_bvOldIMP_toVal(unsigned short,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"L"]){
            apc_invok_bvOldIMP_toVal(unsigned long,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"Q"]){
            apc_invok_bvOldIMP_toVal(unsigned long long,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"f"]){
            apc_invok_bvOldIMP_toVal(float,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"d"]){
            apc_invok_bvOldIMP_toVal(double,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"B"]){
            apc_invok_bvOldIMP_toVal(BOOL,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"*"]){
            apc_invok_bvOldIMP_toVal(char*,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@"#"]){
            apc_invok_bvOldIMP_toVal(Class,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@":"]){
            apc_invok_bvOldIMP_toVal(SEL,ret)
        }
        else if ([self.valueTypeEncode characterAtIndex:0] == '^'){
            apc_invok_bvOldIMP_toVal(void*,ret)
        }
        else if ([self.valueTypeEncode isEqualToString:@(@encode(CGRect))]){
            apc_invok_bvOldIMP_toVal(CGRect,ret)
        }
        ///enc-m
    }
    
    return ret;
}


/**
 Class.property or NSClass.0xAddress
 */
#define keyForCachedPropertyMap(class,propertyName)\
([NSString stringWithFormat:@"%@.%@",NSStringFromClass(class),propertyName])

static NSMutableDictionary* _cachedPropertyMap;
- (void)cache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cachedPropertyMap = [NSMutableDictionary dictionary];
    });
    
    static dispatch_semaphore_t signalSemaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        signalSemaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(signalSemaphore, DISPATCH_TIME_FOREVER);
    
    _cachedPropertyMap[keyForCachedPropertyMap(_clazz,_des_property_name)] = self;
    
    dispatch_semaphore_signal(signalSemaphore);
}

- (void)removeFromCache
{
    static dispatch_semaphore_t signalSemaphore;
    static dispatch_once_t onceTokenSemaphore;
    dispatch_once(&onceTokenSemaphore, ^{
        signalSemaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(signalSemaphore, DISPATCH_TIME_FOREVER);
    
    [_cachedPropertyMap removeObjectForKey:keyForCachedPropertyMap(_clazz,_des_property_name)];
    
    dispatch_semaphore_signal(signalSemaphore);
}

+ (_Nullable instancetype)cachedInfoByClass:(Class)clazz
                               propertyName:(NSString*)propertyName;
{
    return _cachedPropertyMap[keyForCachedPropertyMap(clazz,propertyName)];
}
@end

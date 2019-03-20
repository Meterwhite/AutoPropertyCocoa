//
//  NSObject+AutoWorkPropery.m
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//
#import "NSObject+AutoPropertyCocoa.h"
#import "AutoPropertyCocoaConst.h"
#import "AutoPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject(AutoProperyCocoa)

+ (void)apc_lazyPropertyForKey:(NSString *)key
{
    [self apc_autoClassProperty:key hookWithBlock:nil hookWithSEL:nil];
}

+ (void)apc_lazyPropertyForKey:(NSString *)key selector:(SEL)selector
{
    [self apc_autoClassProperty:key hookWithBlock:nil hookWithSEL:selector];
}

+ (void)apc_lazyPropertyForKey:(NSString *)key usingBlock:(id  _Nullable (^)(id _Nonnull))block
{
    [self apc_autoClassProperty:key hookWithBlock:block hookWithSEL:nil];
}

+ (void)apc_lazyPropertyForKeyHooks:(NSDictionary *)keyHooks
{
    [keyHooks enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, id  _Nonnull hook, BOOL * _Nonnull stop) {
        
        if([hook isKindOfClass:[NSString class]]){
            
            [self apc_autoClassProperty:key hookWithBlock:hook hookWithSEL:nil];
        }else{
            
            [self apc_autoClassProperty:key hookWithBlock:nil hookWithSEL:NSSelectorFromString(hook)];
        }
    }];
}

+ (void)apc_unbindLazyPropertyForKey:(NSString *)key
{
    [[AutoPropertyInfo cachedInfoByClass:self propertyName:key] unhook];
}


- (void)apc_autoClassProperty:(NSString*)propertyName
                hookWithBlock:(id)block
                  hookWithSEL:(SEL)aSelector
{
    NSString *oldClassName = NSStringFromClass([self class]);
    NSString *newClassName = [NSString stringWithFormat:@"APC_%@", oldClassName];
    
    Class NewClass = objc_allocateClassPair([self class], newClassName.UTF8String, 0);
    
    BOOL b = class_addMethod(NewClass, NSSelectorFromString(propertyName), (IMP)apc_property, "@@:");
//    class_replaceMethod(NewClass, NSSelectorFromString(propertyName), (IMP)apc_property, "@@:");
    
    objc_registerClassPair(NewClass);
    
    object_setClass(self, NewClass);
    
    
}


+ (void)apc_autoClassProperty:(NSString*)propertyName
                hookWithBlock:(id)block
                  hookWithSEL:(SEL)aSelector
{
    AutoPropertyInfo* propertyInfo = [AutoPropertyInfo infoWithPropertyName:propertyName
                                                                     aClass:self];
    
    if((propertyInfo.kvcOption & (AutoPropertyKVCSetter | AutoPropertyKVCIVar)) == NO){
        //can not set
        return;
    }
    
    if((propertyInfo.kvcOption & (AutoPropertyKVCGetter | AutoPropertyKVCIVar)) == NO){
        //can not get
        return;
    }
    
    if(block){
    
        [propertyInfo hookBlock:block];
    }else{
        
        [propertyInfo hookSelector:aSelector];
    }
}


/**
 This func is actually called.
 */
id _Nullable apc_property(_Nullable id _SELF,SEL _CMD)
{
    AutoPropertyInfo* propertyInfo = [AutoPropertyInfo cachedInfoByClass:[_SELF class]
                                                        propertyName:NSStringFromSelector(_CMD)];
    
    if(propertyInfo == nil){
        //@throw
        return nil;
    }
    
    id value = nil;
    
    ///Get value.All returned value are boxed;
    if(propertyInfo.kvcOption & AutoPropertyKVCGetter){
        
        value = [propertyInfo performOldGetterFromTarget:_SELF];
    }else{
        
        value = [propertyInfo getIvarValueFromTarget:_SELF];
    }
    
    
    
    if(value == nil
       && propertyInfo.kindOfValue == AutoPropertyValueKindOfObject)
    {
        
        ///Create default value.
        Class clzz = propertyInfo.associatedClass;
        if(propertyInfo.hookType == AutoPropertyHookBySelector)
        {
            NSMethodSignature *signature = [clzz methodSignatureForSelector:propertyInfo.hookedSelector];
            if (signature == nil) {
                //
            }
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.target = clzz;
            invocation.selector = propertyInfo.hookedSelector;
            [invocation invoke];
            id __unsafe_unretained returnValue;
            if (signature.methodReturnLength) {
                
                [invocation getReturnValue:&returnValue];
                value = returnValue;
            }
        }
        else
        {
            id(^block_def_val)(id _SELF) = propertyInfo.hookedBlock;
            if(block_def_val){
                
                value = block_def_val(_SELF);
            }
        }
        
        [propertyInfo setValue:value toTarget:_SELF];
    }
    else if (propertyInfo.accessCount == 0
             && propertyInfo.kindOfValue != AutoPropertyValueKindOfObject)
    {
        if(propertyInfo.hookType != AutoPropertyHookByBlock){
            //@thorw
        }
        
        id(^block_def_val)(id _SELF) = propertyInfo.hookedBlock;
        if(block_def_val){
            
            value = block_def_val(_SELF);
        }
        
        [propertyInfo setValue:value toTarget:_SELF];
    }
    
    [propertyInfo access];
    
    return value;
}


/**
 This getter returns the basic-value.
 */
#define apc_property_def(enc,type)\
    \
type apc_property_##enc(_Nullable id _SELF,SEL _CMD)\
{   \
    NSValue* value = apc_property(_SELF, _CMD);\
    \
    type ret;\
    [value getValue:&ret];\
    \
    return ret;\
}\

apc_property_def(c,char)
apc_property_def(i,int)
apc_property_def(s,short)
apc_property_def(l,long)
apc_property_def(q,long long)
apc_property_def(C,unsigned char)
apc_property_def(I,unsigned int)
apc_property_def(S,unsigned short)
apc_property_def(L,unsigned long)
apc_property_def(Q,unsigned long long)
apc_property_def(f,float)
apc_property_def(d,double)
apc_property_def(B,BOOL)
apc_property_def(chars,char*)
apc_property_def(class,Class)
apc_property_def(sel,SEL)
apc_property_def(prt,void*)
apc_property_def(rect,APC_RECT)
apc_property_def(point,APC_POINT)
apc_property_def(size,APC_SIZE)
apc_property_def(range,NSRange)
///enc-m

void* _Nullable apc_property_imp_byEnc(NSString* enc)
{
    if([enc isEqualToString:@"c"]){
        return apc_property_c;
    }
    else if ([enc isEqualToString:@"i"]){
        return apc_property_i;
    }
    else if ([enc isEqualToString:@"s"]){
        return apc_property_s;
    }
    else if ([enc isEqualToString:@"l"]){
        return apc_property_l;
    }
    else if ([enc isEqualToString:@"q"]){
        return apc_property_q;
    }
    else if ([enc isEqualToString:@"C"]){
        return apc_property_C;
    }
    else if ([enc isEqualToString:@"I"]){
        return apc_property_I;
    }
    else if ([enc isEqualToString:@"S"]){
        return apc_property_S;
    }
    else if ([enc isEqualToString:@"L"]){
        return apc_property_L;
    }
    else if ([enc isEqualToString:@"Q"]){
        return apc_property_Q;
    }
    else if ([enc isEqualToString:@"f"]){
        return apc_property_f;
    }
    else if ([enc isEqualToString:@"d"]){
        return apc_property_d;
    }
    else if ([enc isEqualToString:@"B"]){
        return apc_property_B;
    }
    else if ([enc isEqualToString:@"*"]){
        return apc_property_chars;
    }
    else if ([enc isEqualToString:@"#"]){
        return apc_property_class;
    }
    else if ([enc isEqualToString:@":"]){
        return apc_property_sel;
    }
    else if ([enc characterAtIndex:0] == '^'){
        return apc_property_prt;
    }
    else if ([enc isEqualToString:@(@encode(APC_RECT))]){
        return apc_property_rect;
    }
    else if ([enc isEqualToString:@(@encode(APC_POINT))]){
        return apc_property_point;
    }
    else if ([enc isEqualToString:@(@encode(APC_SIZE))]){
        return apc_property_size;
    }
    else if ([enc isEqualToString:@(@encode(NSRange))]){
        return apc_property_range;
    }
    ///enc-m
    return nil;
}
@end

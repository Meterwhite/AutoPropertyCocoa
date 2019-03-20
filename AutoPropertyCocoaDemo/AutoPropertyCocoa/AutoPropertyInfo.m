//
//  AutoPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+AutoPropertyCocoa.h"
#import "AutoPropertyCocoaConst.h"
#import "NSObject+APCExtension.h"
#import "AutoPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>

id    _Nullable apc_property       (_Nullable id _self,SEL __cmd);
void* _Nullable apc_property_imp_byEnc(NSString* eType);

@implementation AutoPropertyInfo
{
    NSString*   _org_property_name;
    NSString*   _des_property_name;
    Class       _clazz;
    IMP         _old_implementation;
    IMP         _new_implementation;
    SEL         _hooked_selector;
    id          _hooed_block;
}

+ (_Nullable instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                        aClass:(Class __unsafe_unretained)aClass
                                      instance:(id _Nonnull)instance
{
    return [[self alloc] initWithPropertyName:propertyName aClass:aClass instance:instance];
}

+ (instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                          aClass:(Class __unsafe_unretained)aClass
{
    return [[self alloc] initWithPropertyName:propertyName aClass:aClass];
}
- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                              aClass:(Class __unsafe_unretained)aClass
                            instance:(id _Nonnull)instance
{
    if(self = [super init]){
        
    }
    return self;
}

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                      aClass:(Class __unsafe_unretained)aClass
{
    if(self = [super init]){
        
        objc_property_t property = class_getProperty(aClass, propertyName.UTF8String);
        if(property == nil){
            return nil;
        }
        _org_property_name                 = propertyName;
        _clazz                  = aClass;
        NSString*   attr_str    = @(property_getAttributes(property));
        NSArray*    attr_cmps   = [attr_str componentsSeparatedByString:@","];
        NSUInteger  dotLoc      = [attr_str rangeOfString:@","].location;
        NSString*   code        = nil;
        NSUInteger  loc         = 1;
        
        
        if (dotLoc == NSNotFound) {
            code = [attr_str substringFromIndex:loc];
        } else {
            code = [attr_str substringWithRange:NSMakeRange(loc, dotLoc - loc)];
        }
        
        if (code.length == 0) {
            
            return nil;
        }
        
        _valueTypeEncode = code;
        if (code.length > 3 && [code hasPrefix:@"@\""]) {
            
            _kindOfValue = AutoPropertyValueKindOfObject;
            code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
            NSUInteger protocolLoc = [code rangeOfString:@"<"].location;
            if(protocolLoc == NSNotFound){
                
                //Class
                _hasKindOfClass     = YES;
                _associatedClass    = NSClassFromString((_programmingType = code));
            }else if([code characterAtIndex:code.length-1] == '>'){
                
                //?<Protocol>
                
                if(protocolLoc == 0){
                    
                    //id<AProtocol>
                    _programmingType = AWProgramingType_id;
                }else{
                    
                    //AClass<AProtocol>
                    _hasKindOfClass = YES;
                    _programmingType = [code substringToIndex:protocolLoc];
                    _associatedClass = NSClassFromString(code);
                }
            }
        }
        else if ([code isEqualToString:@"@"]){
            //id
            _programmingType = AWProgramingType_id;
            _kindOfValue = AutoPropertyValueKindOfObject;
        }else if ([code characterAtIndex:0] == '^'){
            //no more about detail info.
            _programmingType = AWProgramingType_point;
            _kindOfValue = AutoPropertyValueKindOfPoint;
        }else if([code isEqualToString:@"@?"]){
            //NSBlock
            _programmingType = AWProgramingType_NSBlock;
            _kindOfValue = AutoPropertyValueKindOfBlock;
        }else if([code isEqualToString:@"*"]){
            //point
            _programmingType = AWProgramingType_chars;
            _kindOfValue = AutoPropertyValueKindOfChars;
        }else if([code isEqualToString:@":"]){
            //SEL
            _programmingType = AWProgramingType_SEL;
            _kindOfValue = AutoPropertyValueKindOfSEL;
        }else if(code.length > 3
                 && [code characterAtIndex:0] == '{'
                 && [code characterAtIndex:code.length-1] == '}'
                 && [code containsString:@"="]){
            //structual
            code = [[code substringFromIndex:1] componentsSeparatedByString:@"="].firstObject;
            _programmingType = code;
            _kindOfValue = AutoPropertyValueKindOfStructure;
        }else if ([code isEqualToString:@"c"]){
            //char
            _programmingType = AWProgramingType_char;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"C"]){
            //unsigned char
            _programmingType = AWProgramingType_unsignedchar;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"i"]){
            //int
            _programmingType = AWProgramingType_int;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"I"]){
            //unsigned int
            _programmingType = AWProgramingType_unsignedint;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"s"]){
            //short
            _programmingType = AWProgramingType_short;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"S"]){
            //unsigned short
            _programmingType =  AWProgramingType_unsignedshort;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"l"]){
            //long
            _programmingType = AWProgramingType_long;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"L"]){
            //unsigned long
            _programmingType = AWProgramingType_unsignedlong;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"q"]){
            //long long
            _programmingType = AWProgramingType_longlong;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"Q"]){
            //unsigned long long
            _programmingType = AWProgramingType_unsignedlonglong;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"f"]){
            //float
            _programmingType = AWProgramingType_float;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"d"]){
            //double
            _programmingType = AWProgramingType_double;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"B"]){
            //bool
            _programmingType = AWProgramingType_bool;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }
        
        ///readonly
        _isReadonly = [attr_cmps containsObject:@"R"];
        
        ///memory management type
        if([attr_cmps containsObject:@"&"]){
            
            //strong
            if([attr_cmps containsObject:@"N"]){
                
                _policy = OBJC_ASSOCIATION_RETAIN;
            }else{
                
                _policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
            }
        }
        else if([attr_cmps containsObject:@"C"]){
            
            //copy
            if([attr_cmps containsObject:@"N"]){
                
                _policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
            }else{
                
                _policy = OBJC_ASSOCIATION_COPY;
            }
        }else if([attr_cmps containsObject:@"W"]){
            
            //weak
            _policy = OBJC_ASSOCIATION_ASSIGN;
        }else{
            
            //assign
            _policy = OBJC_ASSOCIATION_ASSIGN;
        }
        
        NSString* var_name  = attr_cmps.lastObject;
        _kvcOption          = AutoPropertyKVCDisable;
        for (NSString* item in attr_cmps) {
            
            if([item characterAtIndex:0] == 'G'){
                
                _associatedGetter   = NSSelectorFromString([item substringFromIndex:1]);
                _kvcOption          |= AutoPropertyKVCGetter;
            }else if([item characterAtIndex:0] == 'S'){
                
                _associatedSetter   = NSSelectorFromString([item substringFromIndex:1]);
                _kvcOption          |= AutoPropertyKVCSetter;
            }else if ([item characterAtIndex:0] == 'V'){
                
                _associatedIvar     = class_getInstanceVariable(aClass, [var_name substringFromIndex:1].UTF8String);
                _kvcOption          |= AutoPropertyKVCIVar;
            }
        }
    }
    
    _des_property_name = _associatedGetter
    ? NSStringFromSelector(_associatedGetter)
    : _org_property_name;
    
    return self;
}


- (void)bindGetterWithImplementation:(IMP)implementation
{
    _new_implementation = implementation;
    
    _old_implementation
    =
    class_replaceMethod(_clazz,
                        NSSelectorFromString(_des_property_name),
                        implementation,
                        [NSString stringWithFormat:@"%@@:",_valueTypeEncode].UTF8String);
    [self cache];
}

- (void)hookSelector:(SEL)aSelector
{
    _hooked_selector = aSelector?:@selector(new);
    _hooed_block = nil;
    _hookType = AutoPropertyHookBySelector;
    
    IMP newimp = nil;
    if(_kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_property;
    }else{
        
        newimp = (IMP)apc_property_imp_byEnc(_valueTypeEncode);
    }
    
    [self bindGetterWithImplementation:newimp];
}

- (SEL)hookedSelector
{
    return _hooked_selector;
}

- (void)hookBlock:(id)block
{
    _hooked_selector = nil;
    _hooed_block = [block copy];
    _hookType = AutoPropertyHookByBlock;
    
    IMP newimp = nil;
    if(_kindOfValue == AutoPropertyValueKindOfObject){
        
        newimp = (IMP)apc_property;
    }else{
        
        newimp = (IMP)apc_property_imp_byEnc(_valueTypeEncode);
    }
    [self bindGetterWithImplementation:newimp];
}

- (id)hookedBlock
{
    return _hooed_block;
}

- (void)unhook
{
    if(_old_implementation){
        
        _new_implementation = nil;
        
        class_replaceMethod(_clazz,
                            NSSelectorFromString(_des_property_name),
                            _old_implementation,
                            [NSString stringWithFormat:@"%@@:",_valueTypeEncode].UTF8String);
    }
    
    [self removeFromCache];
}

- (id)getIvarValueFromTarget:(id)target
{
    if(_kindOfValue == AutoPropertyValueKindOfObject){
        
        return object_getIvar(target , _associatedIvar);
    }
    else{
        
        return [target valueForKey:@(ivar_getName(_associatedIvar))];
    }
}

#define apc_invok_bvSet_fromVal(type,value)\
    \
type _val_t;\
[value getValue:&_val_t];\
((void (*)(id,SEL,type))objc_msgSend)(target,_associatedSetter,_val_t);

- (void)setValue:(id)value toTarget:(id)target
{
    if(_kvcOption & AutoPropertyKVCSetter){
        
        if(_kindOfValue == AutoPropertyValueKindOfObject){
            
            ((void (*)(id,SEL,id))objc_msgSend)(target,_associatedSetter,value);
        }else{
            
            if([_valueTypeEncode isEqualToString:@"c"]){
                apc_invok_bvSet_fromVal(char,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"i"]){
                apc_invok_bvSet_fromVal(int,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"s"]){
                apc_invok_bvSet_fromVal(short,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"l"]){
                apc_invok_bvSet_fromVal(long,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"q"]){
                apc_invok_bvSet_fromVal(long long,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"C"]){
                apc_invok_bvSet_fromVal(unsigned char,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"I"]){
                apc_invok_bvSet_fromVal(unsigned int,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"S"]){
                apc_invok_bvSet_fromVal(unsigned short,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"L"]){
                apc_invok_bvSet_fromVal(unsigned long,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"Q"]){
                apc_invok_bvSet_fromVal(unsigned long long,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"f"]){
                apc_invok_bvSet_fromVal(float,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"d"]){
                apc_invok_bvSet_fromVal(double,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"B"]){
                apc_invok_bvSet_fromVal(BOOL,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"*"]){
                apc_invok_bvSet_fromVal(char*,value)
            }
            else if ([_valueTypeEncode isEqualToString:@"#"]){
                apc_invok_bvSet_fromVal(Class,value)
            }
            else if ([_valueTypeEncode isEqualToString:@":"]){
                apc_invok_bvSet_fromVal(SEL,value)
            }
            else if ([_valueTypeEncode characterAtIndex:0] == '^'){
                apc_invok_bvSet_fromVal(void*,value)
            }
            else if ([_valueTypeEncode isEqualToString:@(@encode(APC_RECT))]){
                apc_invok_bvSet_fromVal(APC_RECT,value)
            }
            else if ([_valueTypeEncode isEqualToString:@(@encode(APC_POINT))]){
                apc_invok_bvSet_fromVal(APC_POINT,value)
            }
            else if ([_valueTypeEncode isEqualToString:@(@encode(APC_SIZE))]){
                apc_invok_bvSet_fromVal(APC_SIZE,value)
            }
            else if ([_valueTypeEncode isEqualToString:@(@encode(NSRange))]){
                apc_invok_bvSet_fromVal(NSRange,value)
            }
            ///enc-m
        }
    }else{
        
        if(_kindOfValue == AutoPropertyValueKindOfObject){
            
            object_setIvar(target, _associatedIvar, value);
        }else{
            
            [target setValue:value forKey:@(ivar_getName(_associatedIvar))];
        }
    }
}

#define apc_invok_bvOldIMP_toVal(type,val)\
    \
type _val_t = ((type(*)(id, SEL))_old_implementation)\
    (target, NSSelectorFromString(_des_property_name));\
val = [NSValue valueWithBytes:&_val_t objCType:_valueTypeEncode.UTF8String];

- (_Nullable id)performOldGetterFromTarget:(_Nonnull id)target
{
    if(NO == (_new_implementation && _old_implementation)){
        
        return nil;
    }
    
    id ret;
    
    if(_kindOfValue == AutoPropertyValueKindOfObject){
        
        ret
        =
        ((id(*)(id, SEL))_old_implementation)
        
            (target, NSSelectorFromString(_des_property_name));
    }else{
        
        
        if([_valueTypeEncode isEqualToString:@"c"]){
            apc_invok_bvOldIMP_toVal(char,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"i"]){
            apc_invok_bvOldIMP_toVal(int,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"s"]){
            apc_invok_bvOldIMP_toVal(short,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"l"]){
            apc_invok_bvOldIMP_toVal(long,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"q"]){
            apc_invok_bvOldIMP_toVal(long long,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"C"]){
            apc_invok_bvOldIMP_toVal(unsigned char,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"I"]){
            apc_invok_bvOldIMP_toVal(unsigned int,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"S"]){
            apc_invok_bvOldIMP_toVal(unsigned short,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"L"]){
            apc_invok_bvOldIMP_toVal(unsigned long,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"Q"]){
            apc_invok_bvOldIMP_toVal(unsigned long long,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"f"]){
            apc_invok_bvOldIMP_toVal(float,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"d"]){
            apc_invok_bvOldIMP_toVal(double,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"B"]){
            apc_invok_bvOldIMP_toVal(BOOL,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"*"]){
            apc_invok_bvOldIMP_toVal(char*,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@"#"]){
            apc_invok_bvOldIMP_toVal(Class,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@":"]){
            apc_invok_bvOldIMP_toVal(SEL,ret)
        }
        else if ([_valueTypeEncode characterAtIndex:0] == '^'){
            apc_invok_bvOldIMP_toVal(void*,ret)
        }
        else if ([_valueTypeEncode isEqualToString:@(@encode(CGRect))]){
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

- (void)access
{
    ++_accessCount;
}


- (NSString *)debugDescription
{
    return [self description];
}

- (NSString *)description
{
    NSString* policyDes;
    switch (self.policy) {
        case OBJC_ASSOCIATION_ASSIGN:
            policyDes = @"atomic,weak";
            break;
        case OBJC_ASSOCIATION_COPY:
            policyDes = @"atomic,copy";
            break;
        case OBJC_ASSOCIATION_RETAIN:
            policyDes = @"atomic,strong";
            break;
        case OBJC_ASSOCIATION_COPY_NONATOMIC:
            policyDes = @"nonatomic,copy";
            break;
        case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
            policyDes = @"nonatomic,strong";
            break;
    }
    
    
    NSMutableString* getterSetterDes = [NSMutableString string];
    if(self.associatedGetter){
        
        [getterSetterDes appendString:@",getter="];
        [getterSetterDes appendString:NSStringFromSelector(self.associatedGetter)];
    }
    if (self.associatedSetter){
        
        [getterSetterDes appendString:@",setter="];
        [getterSetterDes appendString:NSStringFromSelector(self.associatedSetter)];
    }
    
    NSMutableString* ivarDes = [NSMutableString string];
    if(_associatedIvar != nil){
        
        [ivarDes appendString:@"("];
        [ivarDes appendString:@(ivar_getName(_associatedIvar))];
        [ivarDes appendString:@")"];
    }
    
    return
    
    [NSString stringWithFormat:
     @"@property(%@%@)"
     "%@ -> %@%@;"
     ,policyDes,getterSetterDes
     ,self.programmingType,_org_property_name,ivarDes];
}

@end

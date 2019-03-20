//
//  AutoPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyCocoaConst.h"
#import "AutoPropertyInfo.h"

@implementation AutoPropertyInfo

//- (AutoPropertyHookType)hookType
//{
//    return _hookType;
//}
//
//- (AutoPropertyValueKind)kindOfValue
//{
//    return _kindOfValue;
//}

+ (_Nullable instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                      aInstance:(id _Nonnull)aInstance
{
    return [[self alloc] initWithPropertyName:propertyName aInstance:aInstance];
}

+ (instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                          aClass:(Class __unsafe_unretained)aClass
{
    return [[self alloc] initWithPropertyName:propertyName aClass:aClass];
}
- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                            aInstance:(id _Nonnull)aInstance
{
    if(self = [self initWithPropertyName:propertyName aClass:[self class]]){
        
        _hookType &=    ~AutoPropertyHookedToClass;
        _hookType |=    AutoPropertyHookedToInstance;
        _instance =     aInstance;
    }
    return self;
}

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                      aClass:(Class __unsafe_unretained)aClass
{
    if(self = [super init]){
        
        objc_property_t property = class_getProperty(aClass, propertyName.UTF8String);
        if(property == nil){
            
            while (nil != (aClass = class_getSuperclass(aClass)))
                if(nil != (property = class_getProperty(aClass, propertyName.UTF8String)))
                    break;
            ///@throw
            NSAssert(property, @"property do not exist.");
        }
        _hookType               |= AutoPropertyHookedToClass;
        _org_property_name      = propertyName;
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
    
//    _des_property_name = _associatedGetter
//    ? NSStringFromSelector(_associatedGetter)
//    : _org_property_name;
    
    return self;
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

//
//  AutoPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyInfo.h"
#import "APCScope.h"

@implementation AutoPropertyInfo

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
    if(self = [self initWithPropertyName:propertyName aClass:[aInstance class]]){
        
        _kindOfOwner = AutoPropertyOwnerKindOfInstance;
        _instance    =  aInstance;
        _enable      =  YES;
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
            NSAssert(property, @"Can not find property.");
        }
        _kindOfOwner            = AutoPropertyOwnerKindOfClass;
        _ogi_property_name      = propertyName;
        _clazz                  = aClass;
        _enable                 = YES;
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
        
        _valueAttibute  = code;
        _valueTypeEncoding      = code;
        if (code.length > 3 && [code hasPrefix:@"@\""]) {
            
            _valueTypeEncoding = @"@";
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
                    _programmingType = APCProgramingType_id;
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
            _programmingType = APCProgramingType_id;
            _kindOfValue = AutoPropertyValueKindOfObject;
        }else if ([code characterAtIndex:0] == '^'){
            //no more about detail info.
            _programmingType = APCProgramingType_point;
            _kindOfValue = AutoPropertyValueKindOfPoint;
        }else if([code isEqualToString:@"@?"]){
            //NSBlock
            _programmingType = APCProgramingType_NSBlock;
            _kindOfValue = AutoPropertyValueKindOfBlock;
        }else if([code isEqualToString:@"*"]){
            //point
            _programmingType = APCProgramingType_chars;
            _kindOfValue = AutoPropertyValueKindOfChars;
        }else if([code isEqualToString:@":"]){
            //SEL
            _programmingType = APCProgramingType_SEL;
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
            _programmingType = APCProgramingType_char;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"C"]){
            //unsigned char
            _programmingType = APCProgramingType_unsignedchar;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"i"]){
            //int
            _programmingType = APCProgramingType_int;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"I"]){
            //unsigned int
            _programmingType = APCProgramingType_unsignedint;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"s"]){
            //short
            _programmingType = APCProgramingType_short;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"S"]){
            //unsigned short
            _programmingType =  APCProgramingType_unsignedshort;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"l"]){
            //long
            _programmingType = APCProgramingType_long;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"L"]){
            //unsigned long
            _programmingType = APCProgramingType_unsignedlong;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"q"]){
            //long long
            _programmingType = APCProgramingType_longlong;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"Q"]){
            //unsigned long long
            _programmingType = APCProgramingType_unsignedlonglong;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"f"]){
            //float
            _programmingType = APCProgramingType_float;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"d"]){
            //double
            _programmingType = APCProgramingType_double;
            _kindOfValue = AutoPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"B"]){
            //bool
            _programmingType = APCProgramingType_bool;
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
                
                _associatedGetter   =  NSSelectorFromString([item substringFromIndex:1]);
                _kvcOption          |= AutoPropertyKVCGetter;
            }else if([item characterAtIndex:0] == 'S'){
                
                _associatedSetter   =  NSSelectorFromString([item substringFromIndex:1]);
                _kvcOption          |= AutoPropertyKVCSetter;
            }else if ([item characterAtIndex:0] == 'V'){
                
                _associatedIvar     =  class_getInstanceVariable(aClass, [var_name substringFromIndex:1].UTF8String);
                _kvcOption          |= AutoPropertyKVCIVar;
            }
        }
    }
    
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

- (void)invalid
{
    _enable      = NO;
    _accessCount = 0;
}

- (void)access
{
    if(_enable){
        
        ++_accessCount;
    }
}

- (NSString *)debugDescription
{
    return [self description];
}

- (NSString *)description
{
    ///@property(@policy,@getter,@setter)@programmingType -> @property(@ivar)
    
    NSMutableString* des = [NSMutableString stringWithString:@"@property("];
    
    switch (self.policy) {
        case OBJC_ASSOCIATION_ASSIGN:
            [des appendString:@"atomic,weak"];
            break;
        case OBJC_ASSOCIATION_COPY:
            [des appendString:@"atomic,copy"];
            break;
        case OBJC_ASSOCIATION_RETAIN:
            [des appendString:@"atomic,strong"];
            break;
        case OBJC_ASSOCIATION_COPY_NONATOMIC:
            [des appendString:@"nonatomic,copy"];
            break;
        case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
            [des appendString:@"nonatomic,strong"];
            break;
    }
    
    if(self.associatedGetter){
        
        [des appendFormat:@",getter=%@",NSStringFromSelector(self.associatedGetter)];
    }
    if (self.associatedSetter){
        
        [des appendFormat:@",setter=%@",NSStringFromSelector(self.associatedSetter)];
    }
    
    [des appendFormat:@")%@ -> %@",self.programmingType,_ogi_property_name];
    
    if(_associatedIvar != nil){

        [des appendFormat:@"(%@)",@(ivar_getName(_associatedIvar))];
    }
    
    return [des copy];
}

@end

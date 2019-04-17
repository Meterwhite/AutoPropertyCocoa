//
//  APCProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSString+APCExtension.h"
#import "APCProperty.h"
#import "APCScope.h"

@implementation APCProperty
{
    volatile APCAtomicUInteger _accessCount;
}

+ (instancetype)instanceWithProperty:(NSString*)propertyName
                           aInstance:(id)aInstance
{
    return [[self alloc] initWithPropertyName:propertyName aInstance:aInstance];
}

+ (instancetype)instanceWithProperty:(NSString*)propertyName
                              aClass:(Class)aClass
{
    return [[self alloc] initWithPropertyName:propertyName aClass:aClass];
}
- (instancetype)initWithPropertyName:(NSString*)propertyName
                           aInstance:(id)aInstance
{
    if(self = [self initWithPropertyName:propertyName aClass:[aInstance class]]){
        
        _kindOfOwner = APCPropertyOwnerKindOfInstance;
        _instance    = aInstance;
    }
    return self;
}

- (instancetype)initWithPropertyName:(NSString*)propertyName
                      aClass:(Class)aClass
{
    if(self = [super init]){
        
        _kindOfOwner        =   APCPropertyOwnerKindOfClass;
        _ori_property_name  =   propertyName;
        _des_getter_name =      propertyName;
        _des_class          =   aClass;
        _enable             =   YES;
        _hashcode           =   0;
        objc_property_t*        p_list;
        NSString*               attr_str;
        unsigned int            count;
        do {
            
            p_list = class_copyPropertyList(aClass, &count);
            while (count--) {
                
                if([propertyName isEqualToString:@(property_getName(p_list[count]))]){
                    
                    _src_class         =    aClass;
                    attr_str          = @(property_getAttributes(p_list[count]));
                }
            }
        } while (nil != (aClass = class_getSuperclass(aClass)));
        
        NSAssert(_des_class, @"APC: Can not find a property named %@.",propertyName);
        
        
        NSArray*    attr_cmps   = [attr_str componentsSeparatedByString:@","];
        NSUInteger  dotLoc      = [attr_str rangeOfString:@","].location;
        NSString*   code        = nil;
        NSUInteger  loc         = 1;
        
        
        if (dotLoc == NSNotFound) {
            code = [attr_str substringFromIndex:loc];
        } else {
            code = [attr_str substringWithRange:NSMakeRange(loc, dotLoc - loc)];
        }
        
        NSAssert(code.length > 0, @"APC: Property %@ is disable.",propertyName);
        
        _valueAttibute      = [code copy];
        _valueTypeEncoding  = [code copy];
        if (code.length > 3 && [code hasPrefix:@"@\""]) {
            
            _valueTypeEncoding = @"@";
            _kindOfValue = APCPropertyValueKindOfObject;
            code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
            NSUInteger protocolLoc = [code rangeOfString:@"<"].location;
            if(protocolLoc == NSNotFound){
                
                //Class
                _hasKindOfClass = YES;
                _propertyClass  = NSClassFromString((_programmingType = code));
            }else if([code characterAtIndex:code.length-1] == '>'){
                
                //?<Protocol>
                
                if(protocolLoc == 0){
                    
                    //id<AProtocol>
                    _programmingType = APCProgramingType_id;
                }else{
                    
                    //AClass<AProtocol>
                    _hasKindOfClass = YES;
                    _programmingType= [code substringToIndex:protocolLoc];
                    _propertyClass  = NSClassFromString(code);
                }
            }
        }
        else if ([code isEqualToString:@"@"]){
            //id
            _programmingType = APCProgramingType_id;
            _kindOfValue = APCPropertyValueKindOfObject;
        }else if ([code characterAtIndex:0] == '^'){
            //no more about detail info.
            _programmingType = APCProgramingType_point;
            _kindOfValue = APCPropertyValueKindOfPoint;
        }else if([code isEqualToString:@"@?"]){
            //NSBlock
            _programmingType = APCProgramingType_NSBlock;
            _kindOfValue = APCPropertyValueKindOfBlock;
        }else if([code isEqualToString:@"*"]){
            //point
            _programmingType = APCProgramingType_chars;
            _kindOfValue = APCPropertyValueKindOfChars;
        }else if([code isEqualToString:@":"]){
            //SEL
            _programmingType = APCProgramingType_SEL;
            _kindOfValue = APCPropertyValueKindOfSEL;
        }else if(code.length > 3
                 && [code characterAtIndex:0] == '{'
                 && [code characterAtIndex:code.length-1] == '}'
                 && [code containsString:@"="]){
            //structual
            code = [[code substringFromIndex:1] componentsSeparatedByString:@"="].firstObject;
            _programmingType = code;
            _kindOfValue = APCPropertyValueKindOfStructure;
        }else if ([code isEqualToString:@"c"]){
            //char
            _programmingType = APCProgramingType_char;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"C"]){
            //unsigned char
            _programmingType = APCProgramingType_unsignedchar;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"i"]){
            //int
            _programmingType = APCProgramingType_int;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"I"]){
            //unsigned int
            _programmingType = APCProgramingType_unsignedint;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"s"]){
            //short
            _programmingType = APCProgramingType_short;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"S"]){
            //unsigned short
            _programmingType =  APCProgramingType_unsignedshort;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"l"]){
            //long
            _programmingType = APCProgramingType_long;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"L"]){
            //unsigned long
            _programmingType = APCProgramingType_unsignedlong;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"q"]){
            //long long
            _programmingType = APCProgramingType_longlong;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"Q"]){
            //unsigned long long
            _programmingType = APCProgramingType_unsignedlonglong;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"f"]){
            //float
            _programmingType = APCProgramingType_float;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"d"]){
            //double
            _programmingType = APCProgramingType_double;
            _kindOfValue = APCPropertyValueKindOfNumber;
        }else if ([code isEqualToString:@"B"]){
            //bool
            _programmingType = APCProgramingType_bool;
            _kindOfValue = APCPropertyValueKindOfNumber;
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
        _accessOption          = APCPropertyKVCDisable;
        for (NSString* item in attr_cmps) {
            
            if([item characterAtIndex:0] == 'G'){
                
                _des_getter_name= [item substringFromIndex:1];
                _propertyGetter   =  NSSelectorFromString(_des_getter_name);
                _accessOption     |= APCPropertyComponentOfGetter;
            }else if([item characterAtIndex:0] == 'S'){
                
                _des_setter_name  =  [item substringFromIndex:1];
                _propertySetter   =  NSSelectorFromString(_des_setter_name);
                _accessOption     |= APCPropertyComponentOfSetter;
            }else if ([item characterAtIndex:0] == 'V'){
                
                _associatedIvar   =  class_getInstanceVariable(_des_class, [var_name substringFromIndex:1].UTF8String);
                _accessOption     |= APCPropertyComponentOfIVar;
            }
        }
    }
    
    
    ///AssociatedSetter
    if(NO == (_accessOption & APCPropertyComponentOfSetter)){
        
        unsigned int count;
        Method* m_list = class_copyMethodList(_des_class, &count);
        NSMutableArray* methodNames = [NSMutableArray array];
        while (count--) {
            
            [methodNames addObject:NSStringFromSelector(method_getName(m_list[count]))];
        }
        if(methodNames.count > 0){
            
            if([methodNames containsObject:_ori_property_name.apc_kvcAssumedSetterName1]){
                
                _des_setter_name    =   _ori_property_name.apc_kvcAssumedSetterName1;
                _associatedSetter   =   NSSelectorFromString(_des_setter_name);
                _accessOption       |=  APCPropertyAssociatedSetter;
            }else if ([methodNames containsObject:_ori_property_name.apc_kvcAssumedSetterName2]){
                
                _des_setter_name    =   _ori_property_name.apc_kvcAssumedSetterName2;
                _associatedSetter   =   NSSelectorFromString(_des_setter_name);
                _accessOption       |=  APCPropertyAssociatedSetter;
            }
        }
        free(m_list);
    }
    
    ///Ivar
    if(NO == (_accessOption & APCPropertyComponentOfIVar)){
        
        unsigned int count;
        Ivar* ivar_list = class_copyIvarList(_des_class, &count);
        NSUInteger flag = 0;//[0,4]
        while (count--) {
            
            if([@(ivar_getName(ivar_list[count])) isEqualToString:_ori_property_name.apc_kvcAssumedIvarName1]){
                
                _associatedIvar = ivar_list[count];
                _accessOption   |= APCPropertyAssociatedIVar;
                break;
            }else if (flag < 3
                      && [@(ivar_getName(ivar_list[count])) isEqualToString:_ori_property_name.apc_kvcAssumedIvarName2]){
                
                _associatedIvar = ivar_list[count];
                _accessOption   |= APCPropertyAssociatedIVar;
                flag = 3;
            }else if (flag < 2
                      && [@(ivar_getName(ivar_list[count])) isEqualToString:_ori_property_name.apc_kvcAssumedIvarName3]){
                
                _associatedIvar = ivar_list[count];
                _accessOption   |= APCPropertyAssociatedIVar;
                flag = 2;
            }else if (flag < 1
                      && [@(ivar_getName(ivar_list[count])) isEqualToString:_ori_property_name.apc_kvcAssumedIvarName4]){
                
                _associatedIvar = ivar_list[count];
                _accessOption   |= APCPropertyAssociatedIVar;
                flag = 1;
            }
        }
        
        free(ivar_list);
    }
    
    return self;
}

- (id)getIvarValueFromTarget:(id)target
{
    if(self.kindOfValue == APCPropertyValueKindOfBlock ||
       self.kindOfValue == APCPropertyValueKindOfObject){
        
        return object_getIvar(target , _associatedIvar);
    }
    else{
        
        return [target valueForKey:@(ivar_getName(_associatedIvar))];
    }
}

- (void)invalid
{
    _enable      = NO;
    atomic_store(&_accessCount, 0);
}

- (void)access
{
#ifndef __STDC_NO_ATOMICS__
    
    atomic_fetch_add(&_accessCount, 1);
#else
    
    ++_accessCount;
#endif
}

- (NSUInteger)accessCount
{
    
#ifndef __STDC_NO_ATOMICS__
    
    return atomic_load(&_accessCount);
#else
    
    return _accessCount;
#endif
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
            [des appendString:@"atomic"];
            if(self.kindOfValue == APCPropertyValueKindOfBlock ||
               self.kindOfValue == APCPropertyValueKindOfObject){
                
                [des appendString:@",weak"];
            }else{
                
                [des appendString:@",assign"];
            }
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
    
    if(self.propertyGetter){
        
        [des appendFormat:@",getter=%@",NSStringFromSelector(self.propertyGetter)];
    }
    if (self.propertySetter){
        
        [des appendFormat:@",setter=%@",NSStringFromSelector(self.propertySetter)];
    }
    
    [des appendFormat:@")%@ -> %@",self.programmingType,_ori_property_name];
    
    if(_associatedIvar != nil){

        [des appendFormat:@"(%@)",@(ivar_getName(_associatedIvar))];
    }
    
    return [des copy];
}

- (BOOL)isEqual:(id)object
{
    if(self == object)
        
        return YES;
    
    return [self hash] == [object hash];
}

- (NSUInteger)hash
{
    if(_hashcode == 0){
        
        _hashcode = [[NSString stringWithFormat:@"%@/%@.%@"
                      , NSStringFromClass(_src_class)
                      , NSStringFromClass(_des_class)
                      , _ori_property_name]
                     
                     hash];
    }
    return _hashcode;
}
@end

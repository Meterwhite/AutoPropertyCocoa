//
//  AutoPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyMapperkey.h"
#import "APCScope.h"

typedef NS_OPTIONS (NSUInteger,AutoPropertyAccessOptions){
    
    AutoPropertyKVCDisable          =   0,
    ///Getter from property attributes.
    AutoPropertyComponentOfGetter   =   1   <<  0,
    
    AutoPropertyComponentOfSetter   =   1   <<  1,
    
    AutoPropertyComponentOfIVar     =   1   <<  2,
    ///Setter from property list.
    AutoPropertyAssociatedSetter    =   1   <<  3,
    ///Ivar from ivar list.
    AutoPropertyAssociatedIVar      =   1   <<  4,
    
    AutoPropertySetValueEnable      =   AutoPropertyComponentOfSetter
                                        | AutoPropertyAssociatedSetter
                                        | AutoPropertyComponentOfIVar,
    
    AutoPropertyGetValueEnable      =   AutoPropertyComponentOfGetter
                                        | AutoPropertyComponentOfIVar,
};

typedef NS_OPTIONS(NSUInteger,AutoPropertyValueKind){

    AutoPropertyValueKindOfObject        =   1,
    ///C number
    AutoPropertyValueKindOfNumber        =   2,
    
    AutoPropertyValueKindOfStructure     =   3,
    
    AutoPropertyValueKindOfSEL           =   4,
    
    AutoPropertyValueKindOfPoint         =   5,
    ///char*
    AutoPropertyValueKindOfChars         =   6,
    
    AutoPropertyValueKindOfBlock         =   7,
};

typedef NS_OPTIONS(NSUInteger, AutoPropertyOwnerKind){
    
    AutoPropertyOwnerKindOfClass       =   0,
    
    AutoPropertyOwnerKindOfInstance    =   1,
};

typedef NS_OPTIONS(NSUInteger, AutoPropertyHookKind){
    
    AutoPropertyHookKindOfNil       =   0,
    
    AutoPropertyHookKindOfSelector  =   1,
    
    AutoPropertyHookKindOfBlock     =   2,
    
    AutoPropertyHookKindOfIMP       =   3,
};

@interface AutoPropertyInfo : NSObject <APCPropertyMapperKeyProtocol>
{
@public
    
    Class                   _des_class;
    Class                   _src_class;
    NSString*               _ogi_property_name;
    NSString*               _des_property_name;
    NSString*               _des_setter_name;
@protected
    
    AutoPropertyOwnerKind   _kindOfOwner;
    AutoPropertyHookKind    _kindOfHook;
    __weak id               _instance;
@private
    
    BOOL                    _enable;
}


@property (nonatomic,assign,readonly)BOOL                       isReadonly;
@property (nonatomic,assign,readonly)BOOL                       enable;

@property (nonatomic,assign,readonly)AutoPropertyAccessOptions  accessOption;
@property (nonatomic,assign,readonly)AutoPropertyOwnerKind      kindOfOwner;
@property (nonatomic,assign,readonly)AutoPropertyValueKind      kindOfValue;
@property (nonatomic,assign,readonly)AutoPropertyHookKind       kindOfHook;
@property (nonatomic,assign,readonly)objc_AssociationPolicy     policy;

+ (instancetype _Nonnull)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                    aInstance:(id _Nonnull)aInstance;

+ (instancetype _Nonnull)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                       aClass:(Class _Nonnull __unsafe_unretained)aClass;

- (instancetype _Nonnull)initWithPropertyName:(NSString* _Nonnull)propertyName
                        aInstance:(id _Nonnull)aInstance;

- (instancetype _Nonnull)initWithPropertyName:(NSString* _Nonnull)propertyName
                                       aClass:(Class _Nonnull __unsafe_unretained)aClass;


- (id _Nullable)getIvarValueFromTarget:(_Nonnull id)target;

/**
 Return NO if the object is marked with 'id'.Return YES otherwise.
 */
@property (nonatomic,assign,readonly,nullable)Class   propertyClass;
@property (nonatomic,assign,readonly,nullable)SEL     propertyGetter;
@property (nonatomic,assign,readonly,nullable)SEL     propertySetter;
@property (nonatomic,assign,readonly)BOOL hasKindOfClass;

/**
 Get setter that generated by compiler.
 */
@property (nonatomic,assign,readonly,nullable)SEL     associatedSetter;

/**
 The type written by programmer.
 */
@property (nonatomic,copy,readonly,nonnull)NSString* programmingType;
@property (nonatomic,copy,readonly,nonnull)NSString* valueAttibute;
@property (nonatomic,copy,readonly,nonnull)NSString* valueTypeEncoding;
@property (nonatomic,assign,readonly,nullable)Ivar   associatedIvar;

/**
 作用于实例对象的失效
 */
- (void)invalid;

/**
 访问计数
 */
- (void)access;
@property (nonatomic,assign,readonly) NSUInteger accessCount;


/**
 
 YES = [obj isEqual: @"Srcclass/Desclass.property"];
 */
- (BOOL)isEqual:(id _Nonnull)object;

/**
 字符串的哈希值
 同名属性具有相同hash值
 */
- (NSUInteger)hash;

#pragma mark - APCPropertyMapperKeyProtocol
- (APCPropertyMapperkey* _Nonnull)classMapperkey;

- (NSSet<APCPropertyMapperkey*>* _Nonnull)propertyMapperkeys;
@end


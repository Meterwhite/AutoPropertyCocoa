//
//  AutoPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_OPTIONS (NSUInteger,AutoPropertyKVCOption){
    
    AutoPropertyKVCDisable    =   0,
    
    AutoPropertyKVCGetter     =   1,
    
    AutoPropertyKVCSetter     =   1   <<  1,
    
    AutoPropertyKVCIVar       =   1   <<  2
};

typedef NS_OPTIONS(NSUInteger,AutoPropertyValueKind){

    AutoPropertyValueKindOfObject        =   1,
    
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

@interface AutoPropertyInfo : NSObject
{
    NSString*               _ogi_property_name;
    AutoPropertyOwnerKind   _kindOfOwner;
    AutoPropertyHookKind    _kindOfHook;
    __weak id               _instance;
    BOOL                    _enable;
    Class                   _clazz;
}


@property (nonatomic,assign,readonly)BOOL                   isReadonly;
@property (nonatomic,assign,readonly)BOOL                   enable;
@property (nonatomic,assign,readonly)AutoPropertyOwnerKind  kindOfOwner;
@property (nonatomic,assign,readonly)AutoPropertyValueKind  kindOfValue;
@property (nonatomic,assign,readonly)AutoPropertyHookKind   kindOfHook;
@property (nonatomic,assign,readonly)AutoPropertyKVCOption  kvcOption;
@property (nonatomic,assign,readonly)objc_AssociationPolicy policy;

+ (_Nullable instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                      aInstance:(id _Nonnull)aInstance;

+ (_Nullable instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                        aClass:(Class __unsafe_unretained)aClass;

- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                           aInstance:(id _Nonnull)aInstance;
- (instancetype)initWithPropertyName:(NSString* _Nonnull)propertyName
                              aClass:(Class __unsafe_unretained)aClass;


- (_Nullable id)getIvarValueFromTarget:(_Nonnull id)target;

/**
 Return NO if the object is marked with 'id'.Return YES otherwise.
 */
@property (nonatomic,assign,readonly)BOOL    hasKindOfClass;
@property (nonatomic,assign,readonly)Class   associatedClass;
@property (nonatomic,assign,readonly)SEL     associatedGetter;
@property (nonatomic,assign,readonly)SEL     associatedSetter;

/**
 The type written by programmer.
 */
@property (nonatomic,copy,  readonly)NSString* programmingType;
@property (nonatomic,copy,  readonly)NSString* valueAttibute;
@property (nonatomic,copy,  readonly)NSString* valueTypeEncoding;
@property (nonatomic,assign,readonly)Ivar      associatedIvar;

- (void)invalid;

- (void)access;
@property (nonatomic,assign,readonly) NSUInteger accessCount;


@end


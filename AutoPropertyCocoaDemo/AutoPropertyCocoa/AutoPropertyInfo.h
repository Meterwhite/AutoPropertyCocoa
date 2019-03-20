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

typedef NS_OPTIONS(NSUInteger, AutoPropertyHookType){
    
    AutoPropertyHookedToClass       =   1   <<  0,
    
    AutoPropertyHookedToInstance    =   1   <<  1,
    
    AutoPropertyHookBySelector      =   1   <<  2,
    
    AutoPropertyHookByBlock         =   1   <<  3,
};

@interface AutoPropertyInfo : NSObject
{
    Class                   _clazz;
    NSString*               _org_property_name;
    AutoPropertyHookType    _hookType;
    __weak id               _instance;
}


@property (nonatomic,assign,readonly)AutoPropertyHookType    hookType;
@property (nonatomic,assign,readonly)AutoPropertyValueKind   kindOfValue;
@property (nonatomic,assign,readonly)objc_AssociationPolicy  policy;
@property (nonatomic,assign,readonly)AutoPropertyKVCOption   kvcOption;
@property (nonatomic,assign,readonly)BOOL                    isReadonly;
/** Property return type encodings. */
@property (nonatomic,copy,readonly)NSString* valueTypeEncode;

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
 Code types written by programmers.
 
 */
@property (nonatomic,copy,readonly)NSString* programmingType;
@property (nonatomic,assign,readonly)Ivar    associatedIvar;



@property (nonatomic,assign,readonly) NSUInteger accessCount;
- (void)access;


@end


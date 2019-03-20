//
//  AutoPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum AutoPropertyKVCOption{
    
    AutoPropertyKVCDisable    =   0,
    
    AutoPropertyKVCGetter     =   1,
    
    AutoPropertyKVCSetter     =   1   <<  1,
    
    AutoPropertyKVCIVar       =   1   <<  2
}AutoPropertyKVCOption;

typedef enum AutoPropertyValueKind{

    AutoPropertyValueKindOfObject        =   1,
    
    AutoPropertyValueKindOfNumber        =   2,
    
    AutoPropertyValueKindOfStructure     =   3,
    
    AutoPropertyValueKindOfSEL           =   4,
    
    AutoPropertyValueKindOfPoint         =   5,
    ///char*
    AutoPropertyValueKindOfChars         =   6,
    
    AutoPropertyValueKindOfBlock         =   7,
}AutoPropertyValueKind;

typedef enum AutoPropertyHookType{
    AutoPropertyHookBySelector   =   0,
    
    AutoPropertyHookByBlock      =   1,
}AutoPropertyHookType;

@interface AutoPropertyInfo : NSObject



@property (nonatomic,assign,readonly) AutoPropertyHookType hookType;

+ (_Nullable instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                        aClass:(Class __unsafe_unretained)aClass
                                      instance:(id _Nonnull)instance;

+ (_Nullable instancetype)infoWithPropertyName:(NSString* _Nonnull)propertyName
                                        aClass:(Class __unsafe_unretained)aClass;

- (void)hookSelector:(_Nonnull SEL)aSelector;
- (_Nonnull SEL)hookedSelector;

- (void)hookBlock:(_Nonnull id)block;
- (_Nonnull id)hookedBlock;

- (void)unhook;


- (_Nullable id)performOldGetterFromTarget:(_Nonnull id)target;
- (_Nullable id)getIvarValueFromTarget:(_Nonnull id)target;
- (void)setValue:(_Nullable id)value toTarget:(_Nonnull id)target;


@property (nonatomic,assign,readonly)objc_AssociationPolicy  policy;
@property (nonatomic,assign,readonly)AutoPropertyKVCOption   kvcOption;
@property (nonatomic,assign,readonly)AutoPropertyValueKind   kindOfValue;
@property (nonatomic,assign,readonly)BOOL                    isReadonly;

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


/**
 value type encode for current property.
 */
@property (nonatomic,copy,readonly)NSString* valueTypeEncode;
@property (nonatomic,assign,readonly)Ivar    associatedIvar;


@property (nonatomic,assign,readonly) NSUInteger accessCount;
- (void)access;



+ (_Nullable instancetype)cachedInfoByClass:(Class)clazz
                               propertyName:(NSString*)propertyName;

- (void)cache;
@end


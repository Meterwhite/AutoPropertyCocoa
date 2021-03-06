//
//  APCPropertyHook.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/15.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCMethodHook.h"

@class APCTriggerGetterProperty;
@class APCTriggerSetterProperty;
@class APCHookProperty;
@class APCLazyProperty;


@protocol APCPropertyHookProtocol <NSObject>

@optional
- (id _Nullable)performOldGetterFromTarget:(_Nonnull id)target;

- (void)performOldSetterFromTarget:(_Nonnull id)target
                         withValue:(id _Nullable)value;
@end



@interface APCPropertyHook : APCMethodHook<APCPropertyHookProtocol>
{
@public
    
    __kindof __weak APCMethodHook* _superhook;
    IMP             _old_setter_implementation;
@protected
    
    APCAtomicIMP    _new_setter_implementation;
}

+ (nullable instancetype)hookWithProperty:(nonnull __kindof APCHookProperty*)property;
@property (nonatomic,readonly) BOOL isGetterEmpty;
@property (nonatomic,readonly) BOOL isSetterEmpty;
@property (nonatomic,readonly) BOOL isEmpty;

/**
 Result is a valid property.
 */
@property (nullable,nonatomic,weak,readonly) APCTriggerGetterProperty* getterTrigger;
@property (nullable,nonatomic,weak,readonly) APCTriggerSetterProperty* setterTrigger;
@property (nullable,nonatomic,weak,readonly) APCLazyProperty* lazyload;

@property (nullable,nonatomic,weak,readonly) __kindof APCPropertyHook* superhook;
@property (nonatomic,readonly) APCPropertyOwnerKind kindOfOwner;
@property (nonnull,nonatomic,readonly) Class sourceclass;
@property (nonnull,nonatomic,readonly) Class hookclass;
@property (nonnull,nonatomic,readonly,copy) NSString* propertyName;

- (void)bindProperty:(nonnull __kindof APCHookProperty*)property;
- (void)unbindProperty:(nonnull __kindof APCHookProperty*)property;

- (nullable id)performOldGetterFromTarget:(nonnull id)target;

- (void)performOldSetterFromTarget:(nonnull id)target
                         withValue:(nullable id)value;

/**
 Implementation for restoring to a matching inheritance chain relationship.
 */
- (nonnull IMP)restoredImplementation:(APCMethodStyle)style;

/**
 Used to invoke the original implementation.
 */
- (nonnull IMP)oldImplementation:(APCMethodStyle)style;
@end

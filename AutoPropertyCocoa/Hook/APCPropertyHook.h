//
//  APCPropertyHook.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
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
}

+ (nullable instancetype)hookWithProperty:(nonnull __kindof APCHookProperty*)property;
@property (nonatomic,readonly) BOOL        isEmpty;

/**
 Result is a valid property.
 */
@property (nullable,nonatomic,weak,readonly) APCTriggerGetterProperty* getterTrigger;
@property (nullable,nonatomic,weak,readonly) APCTriggerSetterProperty* setterTrigger;
@property (nullable,nonatomic,weak,readonly) APCLazyProperty* lazyload;

@property (nullable,nonatomic,weak,readonly) __kindof APCPropertyHook* superhook;
@property (nullable,nonatomic,copy,readonly) NSString* hookMethod;
@property (nonnull,nonatomic,readonly) Class sourceclass;
@property (nonnull,nonatomic,readonly) Class hookclass;

- (void)bindProperty:(nonnull __kindof APCHookProperty*)property;
- (void)unbindProperty:(nonnull __kindof APCHookProperty*)property;

- (nullable id)performOldGetterFromTarget:(nonnull id)target;

- (void)performOldSetterFromTarget:(nonnull id)target
                         withValue:(nullable id)value;

/**
 Implementation for restoring to a matching inheritance chain relationship.
 */
- (nonnull IMP)restoredImplementation;

/**
 Used to invoke the original implementation.
 */
- (nonnull IMP)oldImplementation;
@end

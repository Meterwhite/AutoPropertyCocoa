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


#warning change to thread safe

@protocol APCPropertyHookProtocol <NSObject>

@optional
- (id _Nullable)performOldGetterFromTarget:(_Nonnull id)target;

- (void)performOldSetterFromTarget:(_Nonnull id)target
                         withValue:(id _Nullable)value;
@end



/**
 统一管理类和实例的钩子
 类和方法名 唯一
 */
@interface APCPropertyHook : APCMethodHook<APCPropertyHookProtocol>
{
@public
    __kindof APCMethodHook* _superhook;
    APCProxyClass           _proxyClass;
}

+ (nullable instancetype)hookWithProperty:(nonnull __kindof APCHookProperty*)property;
+ (void)lockRead;
+ (void)lockWrite;
//@property (nonatomic,strong,nullable) NSEnumerator<APCHookProperty*>* propertyEnumerator;
@property (nonatomic,readonly) BOOL        isEmpty;

/**
 Result is a valid property.
 */
@property (nullable,atomic,strong) APCTriggerGetterProperty* getterTrigger;
@property (nullable,atomic,strong) APCTriggerSetterProperty* setterTrigger;
@property (nullable,atomic,strong) APCLazyProperty* lazyload;

@property (nonnull,nonatomic,readonly) Class sourceclass;
@property (nonnull,nonatomic,readonly) Class hookclass;
@property (nonnull,nonatomic,strong,readonly) __kindof APCPropertyHook* superhook;
@property (nullable,nonatomic,copy,readonly) NSString* hookMethod;

- (void)bindProperty:(nonnull __kindof APCHookProperty*)property;
- (void)unbindProperty:(nonnull __kindof APCHookProperty*)property;

- (nullable id)performOldGetterFromTarget:(nonnull id)target;

- (void)performOldSetterFromTarget:(nonnull id)target
                         withValue:(nullable id)value;

//p list
//unhook property
//hook a proeprty
//in .m auto unhook when no property be hooked

@end

//
//  APCPropertyHook.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCMethodHook.h"

@class APCHookProperty;

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
@interface APCPropertyHook : APCMethodHook<APCPropertyHookProtocol,NSFastEnumeration>
{
@public
    
    __kindof APCMethodHook* _superhook;
    APCProxyClass           _proxyClass;
}

+ (instancetype _Nullable)hookWithProperty:(APCHookProperty* _Nonnull)property;

//@property (nonatomic,strong,nullable) NSEnumerator<APCHookProperty*>* propertyEnumerator;
@property (nonatomic,assign,readonly) BOOL        isEmpty;


- (Class __unsafe_unretained _Nullable)sourceclass;
- (Class __unsafe_unretained _Nullable)hookclass;
- (__kindof APCPropertyHook* _Nullable)superhook;
- (NSString* _Nullable)hookMethod;

- (__kindof APCHookProperty* _Nullable)boundPropertyForPropertyKind:(Class _Nonnull __unsafe_unretained)propertyKind;
- (NSArray<APCHookProperty*>* _Nonnull)boundProperties;
- (void)unbindProperty:(APCHookProperty* _Nonnull)property;
- (void)bindProperty:(APCHookProperty* _Nonnull)property;

- (id _Nullable)performOldGetterFromTarget:(id _Nonnull)target;

- (void)performOldSetterFromTarget:(_Nonnull id)target
                         withValue:(id _Nullable)value;

//p list
//unhook property
//hook a proeprty
//in .m auto unhook when no property be hooked

@end

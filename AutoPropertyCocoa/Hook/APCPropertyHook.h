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

+ (nullable instancetype)hookWithProperty:(nonnull APCHookProperty*)property;

//@property (nonatomic,strong,nullable) NSEnumerator<APCHookProperty*>* propertyEnumerator;
@property (nonatomic,assign,readonly) BOOL        isEmpty;


- (nullable Class)sourceclass;
- (nullable Class)hookclass;
- (nullable __kindof APCPropertyHook*)superhook;
- (nullable NSString*)hookMethod;

- (nullable __kindof APCHookProperty*)boundPropertyForKind:(nonnull Class)cls;
- (nonnull NSArray<APCHookProperty*>*)boundProperties;
- (void)unbindProperty:(nonnull APCHookProperty*)property;
- (void)bindProperty:(nonnull APCHookProperty*)property;

- (nullable id)performOldGetterFromTarget:(nonnull id)target;

- (void)performOldSetterFromTarget:(nonnull id)target
                         withValue:(nullable id)value;

//p list
//unhook property
//hook a proeprty
//in .m auto unhook when no property be hooked

@end

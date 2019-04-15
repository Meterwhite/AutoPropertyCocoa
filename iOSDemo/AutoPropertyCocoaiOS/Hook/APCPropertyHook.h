//
//  APCPropertyHook.h
//  AutoPropertyCocoa
//
//  Created by MDLK on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCMethodHook.h"

@class APCHookProperty;

/**
 统一管理类和实例的钩子
 类和方法名 唯一
 */
@interface APCPropertyHook : APCMethodHook

+ (instancetype _Nullable)hookWithProperty:(APCHookProperty* _Nonnull)property;

@property (nonatomic,assign,readonly) BOOL isEmpty;
@property (nonatomic,strong,nullable) NSEnumerator<APCHookProperty*>* propertyEnumerator;

- (void)bindProperty:(APCHookProperty* _Nonnull)property;

- (void)unbindProperty:(APCHookProperty* _Nonnull)property;

- (NSArray<APCHookProperty*>* _Nonnull)boundProperties;



//p list
//unhook property
//hook a proeprty
//in .m auto unhook when no property be hooked

@end

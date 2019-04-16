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
/**
 统一管理类和实例的钩子
 类和方法名 唯一
 */
@interface APCPropertyHook : APCMethodHook
{
@public
    
    __kindof APCMethodHook* _superhook;
}

+ (instancetype _Nullable)hookWithProperty:(APCHookProperty* _Nonnull)property;

@property (nonatomic,strong,nullable) NSEnumerator<APCHookProperty*>* propertyEnumerator;
@property (nonatomic,assign,readonly) BOOL        isEmpty;
- (NSString* _Nullable)hookMethod;
- (Class __unsafe_unretained _Nullable)hookclass;
- (__kindof APCPropertyHook* _Nullable)superhook;

- (void)unbindProperty:(APCHookProperty* _Nonnull)property;
- (void)bindProperty:(APCHookProperty* _Nonnull)property;
- (NSArray<APCHookProperty*>* _Nonnull)boundProperties;



//p list
//unhook property
//hook a proeprty
//in .m auto unhook when no property be hooked

@end

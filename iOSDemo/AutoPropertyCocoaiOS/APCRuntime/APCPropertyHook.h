//
//  APCPropertyHook.h
//  AutoPropertyCocoaiOS
//
//  Created by MDLK on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoHookPropertyInfo.h"


/**
 统一管理类和实例的钩子
 类和方法名 唯一
 */
@interface APCPropertyHook : NSObject
{
@protected
    
    IMP         _new_implementation;
    IMP         _old_implementation;
}

+ (instancetype _Nullable)hookWithProperty:(AutoHookPropertyInfo* _Nonnull)property;

@property (nonatomic,assign,readonly) BOOL isEmpty;

- (void)bindProperty:(AutoHookPropertyInfo* _Nonnull)property;

- (void)unbindProperty:(AutoHookPropertyInfo* _Nonnull)property;

- (NSArray<AutoHookPropertyInfo*>* _Nonnull)boundProperties;



//p list
//unhook property
//hook a proeprty
//in .m auto unhook when no property be hooked

@end

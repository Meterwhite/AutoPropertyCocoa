//
//  AutoghookPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCMethod.h"
#import "APCProperty.h"

@protocol APCHookPropertyProtocol <NSObject>

@required
- (void)disposeRuntimeResource;
@optional

- (id _Nullable)performOldSetterFromTarget:(_Nonnull id)target;

- (void)performOldGetterFromTarget:(_Nonnull id)target
                         withValue:(id _Nullable)value;
@end

@class APCPropertyHook;
/**
 该类型没有具体实现
 */
@interface APCHookProperty : APCProperty <APCHookPropertyProtocol,APCMethodProtocol>
{
@public
    
    NSString*       _hooked_name;
@protected

    APCMethodStyle  _methodStyle;
    Class           _proxyClass;
}
@property (nonatomic,copy,readonly,nullable)NSString*       methodTypeEncoding;
@property (nonatomic,copy,readonly,nonnull) NSString*       hookedMethod;
@property (nonatomic,assign,readonly)       APCMethodStyle  methodStyle;
@property (nonatomic,weak,readonly,nullable)APCPropertyHook*hook;

- (void)bindingToHook:(APCPropertyHook* _Nullable)hook;

- (void)disposeRuntimeResource;


/**
 Class.hooedMethod
 */
- (NSUInteger)hash;
@end

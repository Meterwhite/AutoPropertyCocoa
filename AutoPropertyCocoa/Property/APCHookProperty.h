//
//  AutfuncnamePropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/3/23.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCUserEnvironmentSupportObject.h"
#import "APCProperty.h"
#import "APCMethod.h"

@protocol APCHookPropertyProtocol <NSObject>

@required
- (nullable SEL)outlet;
- (nullable SEL)inlet;
- (void)unhook;
@optional


- (id _Nullable)performOldSetterFromTarget:(_Nonnull id)target;

- (void)performOldGetterFromTarget:(_Nonnull id)target
                         withValue:(id _Nullable)value;
@end

@class APCPropertyHook;

@interface APCHookProperty : APCProperty
<
    APCHookPropertyProtocol,
    APCMethodProtocol,
    APCUserEnvironmentMessage
>
{
@public
    
    NSString*               _hooked_name;
@protected

    APCMethodStyle          _methodStyle;
    SEL                     _outlet;
    SEL                     _inlet;
}
@property (nullable,nonatomic,copy,readonly)NSString*      methodTypeEncoding;
@property (nullable,nonatomic,weak)APCPropertyHook*        associatedHook;
@property (nonnull,nonatomic,copy,readonly)NSString const* hookedMethod;
@property (nonatomic,readonly)APCMethodStyle               methodStyle;

- (nullable SEL)outlet;
- (nullable SEL)inlet;

- (NSUInteger)hash;

#pragma mark - APCUserEnvironmentMessage
- (nullable instancetype)superEnvironmentMessage;
@end

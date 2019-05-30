//
//  AutfuncnamePropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright © 2019 Novo. All rights reserved.
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
    dispatch_semaphore_t    _lock;
}
@property (nullable,nonatomic,copy,readonly)NSString*      methodTypeEncoding;
@property (nullable,nonatomic,weak)APCPropertyHook*        associatedHook;
@property (nonnull,nonatomic,copy,readonly)NSString const* hookedMethod;
@property (nonatomic,readonly)APCMethodStyle               methodStyle;

- (nullable SEL)outlet;
- (nullable SEL)inlet;


/**
 NSClass.APCClass.hookedMethod
 */
- (NSUInteger)hash;

#pragma mark - APCUserEnvironmentMessage
- (nullable instancetype)superEnvironmentMessage;
@end

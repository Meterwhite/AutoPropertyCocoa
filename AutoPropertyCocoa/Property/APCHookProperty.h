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
    
#warning del and use set get.
    NSString*       _hooked_name;
@protected

    APCMethodStyle  _methodStyle;
    SEL             _outlet;
    SEL             _inlet;
}
@property (nullable,nonatomic,copy,readonly)NSString*           methodTypeEncoding;
@property (nonnull,nonatomic,copy,readonly)NSString const*      hookedMethod;
@property (nullable,nonatomic,weak)APCPropertyHook*             associatedHook;
@property (nonatomic,readonly)APCMethodStyle                    methodStyle;

- (nullable SEL)outlet;
- (nullable SEL)inlet;


/**
 NSClass.APCClass.hooedMethod
 */
- (NSUInteger)hash;

#pragma mark - APCUserEnvironmentMessage
- (nullable instancetype)superObject;
@end

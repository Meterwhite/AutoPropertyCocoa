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

//+ (instancetype _Nullable)boundPropertyForClass:(Class _Nonnull __unsafe_unretained)cls
//                                       property:(NSString* _Nonnull)property;
//
//- (instancetype _Nullable)boundPropertyForClass:(Class _Nonnull __unsafe_unretained)cls
//                                        property:(NSString* _Nonnull)property;

- (void)unhook;
@optional


- (id _Nullable)performOldSetterFromTarget:(_Nonnull id)target;

- (void)performOldGetterFromTarget:(_Nonnull id)target
                         withValue:(id _Nullable)value;
@end

@class APCPropertyHook;

@interface APCHookProperty : APCProperty <APCHookPropertyProtocol,APCMethodProtocol>
{
@public
    
    NSString*       _hooked_name;
@protected

    APCMethodStyle  _methodStyle;
}
@property (nullable,nonatomic,copy,readonly)NSString*       methodTypeEncoding;
@property (nonnull,nonatomic,copy,readonly) NSString*       hookedMethod;
@property (nullable,nonatomic,weak,readonly)APCPropertyHook*hook;
@property (nonatomic,readonly)APCMethodStyle                methodStyle;


- (void)bindingToHook:(APCPropertyHook* _Nullable)hook;

//- (instancetype _Nullable)boundPropertyForClass:(Class _Nonnull __unsafe_unretained)cls
//                                        property:(NSString* _Nonnull)property;

/**
 NSClass.APCClass.hooedMethod
 */
- (NSUInteger)hash;
@end

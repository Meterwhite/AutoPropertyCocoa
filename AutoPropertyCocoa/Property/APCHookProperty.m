//
//  AutfuncnamePropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCHookProperty.h"
#import "APCPropertyHook.h"
#import "APCRuntime.h"

@implementation APCHookProperty

- (instancetype)initWithPropertyName:(NSString *)propertyName aClass:(__unsafe_unretained Class)aClass
{
    if(self = [super initWithPropertyName:propertyName aClass:aClass]){
        
        _hashcode   = 0;
    }
    return self;
}

- (instancetype)initWithPropertyName:(NSString *)propertyName aInstance:(id)aInstance
{
    if(self = [super initWithPropertyName:propertyName aInstance:aInstance]){
        
        _hashcode   = 0;
    }
    return self;
}

- (NSString const*)methodTypeEncoding
{
    return
    
    @(
        _methodStyle == APCMethodGetterStyle
        ? APCGetterMethodEncoding
        : APCSetterMethodEncoding
    );
}

- (NSString *)hookedMethod
{
    return _hooked_name;
}

- (SEL)outlet
{
    return _outlet;
}

- (SEL)inlet
{
    return _inlet;
}

- (void)unhook
{
    if(_associatedHook != nil){
        
        [_associatedHook unbindProperty:self];
    }
}

/**
 NSClass.APCClass.hookedMethod
 */
- (NSUInteger)hash
{
    if(_hashcode == 0){
        
        _hashcode = [[NSString stringWithFormat:@"%@.%@.%@"
                      , NSStringFromClass(_des_class)
                      , object_getClass(self)
                      , _hooked_name]
                     
                     hash];
    }
    
    return _hashcode;
}

- (instancetype)superEnvironmentMessage
{
    return apc_property_getSuperProperty(self);
}

@end

//
//  AutoghookPropertyInfo.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCHookProperty.h"

@implementation APCHookProperty

- (instancetype)initWithPropertyName:(NSString *)propertyName aClass:(__unsafe_unretained Class)aClass
{
    if(self = [super initWithPropertyName:propertyName aClass:aClass]){
        
        _hashcode = 0;
    }
    return self;
}

- (instancetype)initWithPropertyName:(NSString *)propertyName aInstance:(id)aInstance
{
    if(self = [super initWithPropertyName:propertyName aInstance:aInstance]){
        
        _hashcode = 0;
    }
    return self;
}

- (NSString *)hookedMethod
{
    return _hooked_name;
}

-(void)bindingToHook:(APCPropertyHook *)hook
{
    _hook = hook;
}

- (NSUInteger)hash
{
    if(_hashcode == 0){
        
        _hashcode = [[NSString stringWithFormat:@"%@.%@"
                      , NSStringFromClass(_des_class)
                      , _hooked_name]
                     
                     hash];
    }
    
    return _hashcode;
}

- (void)dealloc
{
    if(self.kindOfOwner == APCPropertyOwnerKindOfInstance){
        
        [self disposeRuntimeResource];
    }
}

- (void)disposeRuntimeResource
{
    if(nil != _proxyClass){
        
        objc_disposeClassPair(_proxyClass);
    }
}


@end

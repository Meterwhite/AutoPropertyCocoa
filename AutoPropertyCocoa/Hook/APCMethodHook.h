//
//  APCMethodHook.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/15.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCRuntime.h"
#import "APCScope.h"

@class APCMethodHook;

@protocol APCMethodHookProtocol <NSObject>

@optional
- (nullable __kindof APCMethodHook*)superhook;
- (nullable Class)hookclass;
@end

@interface APCMethodHook : NSObject<APCMethodHookProtocol>
{
@public
    
    IMP             _old_implementation;
@protected
    
    APCAtomicIMP    _new_implementation;
    Class           _source_class;
}


@end


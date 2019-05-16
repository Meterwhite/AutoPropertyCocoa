//
//  APCMethodHook.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCRuntime.h"
#import "APCScope.h"

@class APCMethodHook;

@protocol APCMethodHookProtocol <NSObject>

@optional
- (nullable __kindof APCMethodHook*)superhook;
- (nullable Class)hookclass;
- (nullable NSString*)hookMethod;
- (nonnull IMP)restoredImplementation;
- (nonnull IMP)oldImplementation;
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


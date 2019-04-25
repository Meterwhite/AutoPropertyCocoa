//
//  APCMethodHook.h
//  AutoPropertyCocoa
//
//  Created by NOVO on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCScope.h"

@class APCMethodHook;

@protocol APCMethodHookProtocol <NSObject>

@required
- (void)disposeRuntimeResource;


@optional
- (nullable __kindof APCMethodHook*)superhook;
- (nullable Class)hookclass;
- (nullable NSString*)hookMethod;
@end

@interface APCMethodHook : NSObject<APCMethodHookProtocol>
{
@protected
    
    IMP         _new_implementation;
    IMP         _old_implementation;
    Class       _source_class;
}


@end


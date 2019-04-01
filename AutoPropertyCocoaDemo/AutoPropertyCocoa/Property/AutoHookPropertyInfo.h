//
//  AutoghookPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyInfo.h"

@protocol AutoHookPropertyProtocol <NSObject>

@optional
- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target;
- (void)performOldSetterFromTarget:(_Nonnull id)target withValue:(id _Nullable)value;
- (void)hookPropertyWithImplementation:(IMP _Nonnull)implementation
                                option:(NSUInteger)option;
- (void)unhook;
@end


/**
 该类型没有具体实现
 */
@interface AutoHookPropertyInfo : AutoPropertyInfo <AutoHookPropertyProtocol>
{
    IMP         _new_setter_implementation;
    IMP         _old_setter_implementation;
    IMP         _new_implementation;
    IMP         _old_implementation;
}

@end

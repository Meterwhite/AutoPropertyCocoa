//
//  AutoghookPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCProperty.h"

@protocol APCHookPropertyProtocol <NSObject>

@required
- (void)disposeRuntimeResource;
@optional
- (id _Nullable)performOldSetterFromTarget:(_Nonnull id)target;
- (void)performOldGetterFromTarget:(_Nonnull id)target withValue:(id _Nullable)value;



- (void)hookPropertyWithImplementation:(IMP _Nonnull)implementation
                                option:(NSUInteger)option;
- (void)unhook;
@end

@class APCPropertyHook;
/**
 该类型没有具体实现
 */
@interface APCHookProperty : APCProperty <APCHookPropertyProtocol>
{
@protected
    
    IMP         _new_setter_implementation;
    IMP         _old_setter_implementation;
    IMP         _new_getter_implementation;
    IMP         _old_getter_implementation;
    Class       _proxyClass;
}

@property (nonatomic,weak,nullable) APCPropertyHook* hook;

- (void)disposeRuntimeResource;
@end

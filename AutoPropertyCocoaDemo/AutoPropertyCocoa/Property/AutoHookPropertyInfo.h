//
//  AutoghookPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/23.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyInfo.h"

@protocol AutoghookPropertyProtocol <NSObject>

@optional

- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target;
- (void)hookUsingUserSelector:(_Nonnull SEL)aSelector;
- (void)hookUsingUserBlock:(_Nonnull id)block;
- (void)hookUsingUserIMP:(_Nonnull IMP)block;
- (void)unhook;
@end


/**
 该类型没有具体实现
 */
@interface AutoghookPropertyInfo : AutoPropertyInfo <AutoghookPropertyProtocol>
{
    IMP         _old_implementation;
    IMP         _new_implementation;
    NSString*   _des_property_name;
    SEL         _userSelector;
    id          _userBlock;
    IMP         _userIMP;
}

@property (nonatomic,assign,readonly,nullable)   SEL userSelector;
@property (nonatomic,copy,readonly,nullable)     id  userBlock;
@property (nonatomic,assign,readonly,nullable)   IMP userIMP;
@end
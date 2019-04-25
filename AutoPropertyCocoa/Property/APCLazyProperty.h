//
//  APCLazyProperty.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCHookProperty.h"

@interface APCLazyProperty : APCHookProperty
{
@public
    
    SEL                 _userSelector;
    id                  _userBlock;
}

@property (nullable,nonatomic,readonly)         SEL userSelector;
@property (nullable,nonatomic,copy,readonly)    id  userBlock;

- (void)bindindUserBlock:(nonnull id)block;

- (void)bindingUserSelector:(nonnull SEL)aSelector;


- (nullable id)performOldGetterFromTarget:(nonnull id)target;

- (nullable id)instancetypeNewObjectByUserSelector;

- (nullable id)performUserBlock:(nonnull id)_SELF;

- (void)setValue:(nullable id)value toTarget:(nonnull id)target;
@end

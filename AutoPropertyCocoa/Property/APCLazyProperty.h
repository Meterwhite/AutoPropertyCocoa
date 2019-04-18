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

@property (nonatomic,assign,readonly,nullable)   SEL userSelector;

@property (nonatomic,copy,readonly,nullable)     id  userBlock;

- (void)bindindUserBlock:(_Nonnull id)block;

- (void)bindingUserSelector:(_Nonnull SEL)aSelector;


- (_Nullable id)performOldGetterFromTarget:(_Nonnull id)target;

- (id _Nullable)instancetypeNewObjectByUserSelector;

- (id _Nullable)performUserBlock:(id _Nonnull)_SELF;

- (void)setValue:(_Nullable id)value toTarget:(_Nonnull id)target;
@end

//+ (_Nullable instancetype)cachedTargetClass:(Class _Nonnull __unsafe_unretained)clazz
//                                   property:(NSString* _Nonnull)property;
//
//+ (_Nullable instancetype)cachedFromAClassByInstance:(id _Nonnull)instance
//                                            property:(NSString* _Nonnull)property;
//
//+ (_Nullable instancetype)cachedFromAClass:(Class _Nonnull __unsafe_unretained)aClazz
//                                  property:(NSString* _Nonnull)property;

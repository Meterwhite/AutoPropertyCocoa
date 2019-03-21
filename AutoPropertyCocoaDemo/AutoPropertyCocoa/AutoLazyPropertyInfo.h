//
//  AutoLazyPropertyInfo.h
//  AutoPropertyCocoaDemo
//
//  Created by NOVO on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyInfo.h"

@interface AutoLazyPropertyInfo : AutoPropertyInfo

@property (nonatomic,copy,readonly)     id  hookedBlock;
@property (nonatomic,assign,readonly)   SEL hookedSelector;

- (void)hookWithSelector:(_Nonnull SEL)aSelector;

- (void)hookUsingBlock:(_Nonnull id)block;

- (void)unhook;


- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target;

- (void)setValue:(_Nullable id)value toTarget:(_Nonnull id)target;

#pragma mark - Cache for class type.

+ (_Nullable instancetype)cachedInfoByClass:(Class)clazz
                               propertyName:(NSString*)propertyName;

- (void)cache;
@end


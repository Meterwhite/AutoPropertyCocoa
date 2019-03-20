//
//  AutoLazyPropertyInfo.h
//  AutoPropertyCocoaDemo
//
//  Created by NOVO on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyInfo.h"

@interface AutoLazyPropertyInfo : AutoPropertyInfo
- (void)hookSelector:(_Nonnull SEL)aSelector;
- (_Nonnull SEL)hookedSelector;

- (void)hookBlock:(_Nonnull id)block;
- (_Nonnull id)hookedBlock;

- (void)unhook;


- (_Nullable id)performOldGetterFromTarget:(_Nonnull id)target;

- (void)setValue:(_Nullable id)value toTarget:(_Nonnull id)target;

+ (_Nullable instancetype)cachedInfoByClass:(Class)clazz
                               propertyName:(NSString*)propertyName;

- (void)cache;
@end


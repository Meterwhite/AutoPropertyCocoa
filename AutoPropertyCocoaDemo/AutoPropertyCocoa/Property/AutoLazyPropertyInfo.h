//
//  AutoLazyPropertyInfo.h
//  AutoPropertyCocoa
//
//  Created by NOVO on 2019/3/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoHookPropertyInfo.h"

/**
 对子类懒加载父类的属性，子类使用覆盖属性的策略，解绑也没问题
 */
@interface AutoLazyPropertyInfo : AutoHookPropertyInfo

@property (nonatomic,assign,readonly,nullable)   SEL userSelector;

@property (nonatomic,copy,readonly,nullable)     id  userBlock;

- (void)hookUsingUserBlock:(_Nonnull id)block;

- (void)hookUsingUserSelector:(_Nonnull SEL)aSelector;

- (void)unhook;

- (_Nullable id)performOldPropertyFromTarget:(_Nonnull id)target;

- (id _Nullable)instancetypeNewObjectByUserSelector;

- (id _Nullable)performUserBlock:(id _Nonnull)_SELF;

- (void)setValue:(_Nullable id)value toTarget:(_Nonnull id)target;

#pragma mark - Cache for type of class.

+ (_Nullable instancetype)cachedInfoByClass:(Class _Nonnull)clazz
                               propertyName:(NSString* _Nonnull)propertyName;

- (void)cache;

- (void)removeFromCache;


+ (void)removeCacheForClass:(Class _Nonnull)clazz;

#pragma mark - Cache for the instance object.
+ (void)unbindlazyLoadForInstance:(id _Nonnull)instance;
@end


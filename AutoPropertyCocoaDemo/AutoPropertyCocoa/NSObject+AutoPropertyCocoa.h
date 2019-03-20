//
//  NSObject+AutoWorkPropery.h
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject(AutoProperyCocoa)

- (void)apc_autoClassProperty:(NSString*)propertyName
                hookWithBlock:(id)block
                  hookWithSEL:(SEL)aSelector;

+ (void)apc_lazyPropertyForKey:(NSString* _Nonnull)key;

+ (void)apc_lazyPropertyForKey:(NSString* _Nonnull)key
                    usingBlock:(id _Nullable(^)(id _Nonnull  _self))block;

+ (void)apc_lazyPropertyForKey:(NSString* _Nonnull)key
                      selector:(_Nonnull SEL)selector;

+ (void)apc_lazyPropertyForKeyHooks:(NSDictionary* _Nonnull)keyHooks;

+ (void)apc_unbindLazyPropertyForKey:(NSString* _Nonnull)key;


//- (void)apc_lazyPropertyForKey:(NSString* _Nonnull)key;
@end


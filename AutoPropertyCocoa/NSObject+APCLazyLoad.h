//
//  NSObject+AutoWorkPropery.h
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject(APCLazyLoad)

#pragma mark - Lazy load for class.
+ (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property;

+ (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
                     usingBlock:(id _Nullable(^ _Nonnull)(id _Nonnull instance))block;

+ (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
             initializeSelector:(_Nonnull SEL)selector;

+ (void)apc_lazyLoadForPropertyHooks:(NSDictionary<NSString*,id>* _Nonnull)propertyHooks;

+ (void)apc_unbindLazyLoadForProperty:(NSString* _Nonnull)property;


#pragma mark - Lazy load for instance.
- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property;

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
                     usingBlock:(id _Nullable(^ _Nonnull)(id _Nonnull instance))block;

- (void)apc_lazyLoadForProperty:(NSString* _Nonnull)property
                       selector:(SEL _Nonnull)selector;

- (void)apc_lazyLoadForPropertyHooks:(NSDictionary<NSString* ,id>* _Nonnull)propertyHooks;

- (void)apc_unbindLazyLoadForProperty:(NSString* _Nonnull)property;
@end

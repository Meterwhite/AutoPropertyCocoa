//
//  NSObject+AutoWorkPropery.h
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCUserEnvironmentSupportObject.h"
#import <Foundation/Foundation.h>

@interface NSObject(APCLazyLoad)

#pragma mark - Lazy load for class.
+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property;

+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                     usingBlock:(id _Nullable(^ _Nonnull)(apc_id _Nonnull instance))block;

+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property
             initializeSelector:(nonnull SEL)selector;

+ (void)apc_lazyLoadForPropertyHooks:(nonnull NSDictionary<NSString*,id>*)propertyHooks;

+ (void)apc_unbindLazyLoadForProperty:(nonnull NSString*)property;


#pragma mark - Lazy load for instance.
- (void)apc_lazyLoadForProperty:(nonnull NSString*)property;

- (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                     usingBlock:(id _Nullable(^ _Nonnull)(apc_id _Nonnull instance))block;

- (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                       selector:(nonnull SEL)selector;

- (void)apc_lazyLoadForPropertyHooks:(nonnull NSDictionary<NSString* ,id>*)propertyHooks;

- (void)apc_unbindLazyLoadForProperty:(nonnull NSString*)property;
@end

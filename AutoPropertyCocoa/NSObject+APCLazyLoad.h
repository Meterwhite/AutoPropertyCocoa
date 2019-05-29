//
//  NSObject+AutoWorkPropery.h
//  AutoWorkProperty
//
//  Created by Novo on 2019/3/13.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCUserEnvironmentSupportObject.h"
#import <Foundation/Foundation.h>


/**
 Similar to the following code
 :
 - (id)lazyloadProperty{
 
    if(_lazyloadProperty == nil){
 
        _lazyloadProperty = ...;
    }
    return _lazyloadProperty;
 }
 
 'lazyload'
 */
@interface NSObject(APCLazyLoad)

#pragma mark - Lazy load for instance.Can be applied to basic-value types.

/**
 Use default @selector(new) to initialize the value.
 */
- (void)apc_lazyLoadForProperty:(nonnull NSString*)property;

- (void)apc_lazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array;

- (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                     usingBlock:(id _Nullable(^ _Nonnull)(id_apc_t _Nonnull instance))block;


/**
 ...@selector(array), @selector(dictionary)...
 */
- (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                       selector:(nonnull SEL)selector;

- (void)apc_lazyLoadForPropertyHooks:(nonnull NSDictionary<NSString* ,id>*)propertyHooks;

- (void)apc_unbindLazyLoadForProperty:(nonnull NSString*)property;

#pragma mark - Lazy load for class. Can only be applied to object types.
+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property;

+ (void)apc_lazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array;

+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                     usingBlock:(id _Nullable(^ _Nonnull)(id_apc_t _Nonnull instance))block;

+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property
             selector:(nonnull SEL)selector;

+ (void)apc_lazyLoadForPropertyHooks:(nonnull NSDictionary<NSString*,id>*)propertyHooks;

/**
 Ensured that other threads don't access the property when unbinding for class.
 */
+ (void)apc_unbindLazyLoadForProperty:(nonnull NSString*)property;

@end

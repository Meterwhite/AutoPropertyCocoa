//
//  NSObject+AutoWorkPropery.h
//  AutoWorkProperty
//
//  Created by Meterwhite on 2019/3/13.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
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
 Use default selector '@selector(new)' to initialize the value.
 */
- (void)apc_lazyLoadForProperty:(nonnull NSString*)property;

- (void)apc_lazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array;

- (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                     usingBlock:(id _Nullable(^ _Nonnull)(id_apc_t _Nonnull instance))block;


/**
 Use selector create lazy-load value.
 ...@selector(array), @selector(dictionary)...
 */
- (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                       selector:(nonnull SEL)selector;

- (void)apc_lazyLoadForPropertyHooks:(nonnull NSDictionary<NSString* ,id>*)propertyHooks;

- (void)apc_unbindLazyLoadForProperty:(nonnull NSString*)property;

- (void)apc_unbindLazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array;

#pragma mark - Lazy load for class. Can only be applied to object types.
+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property;

+ (void)apc_lazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array;

+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property
                     usingBlock:(id _Nullable(^ _Nonnull)(id_apc_t _Nonnull instance))block;

+ (void)apc_lazyLoadForProperty:(nonnull NSString*)property
             selector:(nonnull SEL)selector;

+ (void)apc_lazyLoadForPropertyHooks:(nonnull NSDictionary<NSString*,id>*)propertyHooks;

+ (void)apc_unbindLazyLoadForProperty:(nonnull NSString*)property;

+ (void)apc_unbindLazyLoadForPropertyArray:(nonnull NSArray<NSString*> *)array;
@end

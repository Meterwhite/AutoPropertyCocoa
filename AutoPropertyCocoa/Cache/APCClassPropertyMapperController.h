//
//  APCClassPropertyMapperController.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCProperty;


/**
 This Cache is thread-safe.
 
 
 */
@interface APCClassPropertyMapperController : NSObject

+ (instancetype _Nonnull)cache;

//- (void)addProperty:(APCProperty* _Nonnull)aProperty;
//- (void)removeProperty:(APCProperty* _Nonnull)aProperty;
//- (void)removePropertiesWithSrcclass:(Class _Nonnull)srcclass;
//
//- (NSSet<__kindof APCProperty*>* _Nullable)propertiesForSrcclass:(Class _Nonnull)srcclass;
//
//- (__kindof APCProperty* _Nullable)propertyForDesclass:(Class _Nonnull)desclass
//                                          property:(NSString* _Nonnull)property;
//
//- (__kindof APCProperty* _Nullable)searchFromTargetClass:(Class _Nullable)desclass
//                                                     property:(NSString* _Nonnull)property;

- (void)addProperty:(APCProperty* _Nonnull)aProperty;
- (void)removeProperty:(APCProperty* _Nonnull)aProperty;
- (void)removePropertiesWithSrcclass:(Class _Nonnull)srcclass;

- (NSSet<__kindof APCProperty*>* _Nullable)propertiesForSrcclass:(Class _Nonnull)srcclass;

- (__kindof APCProperty* _Nullable)propertyForDesclass:(Class _Nonnull)desclass
                                                   property:(NSString* _Nonnull)property;

- (__kindof APCProperty* _Nullable)searchFromTargetClass:(Class _Nullable)desclass
                                                     property:(NSString* _Nonnull)property;
#pragma mark - New mapper



@end

//
//  APCClassPropertyMapperCache.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AutoPropertyInfo;


/**
 This Cache is thread-safe.
 */
@interface APCClassPropertyMapperCache : NSObject

+ (instancetype _Nonnull)cache;

- (void)addProperty:(AutoPropertyInfo* _Nonnull)aProperty;
- (void)removeProperty:(AutoPropertyInfo* _Nonnull)aProperty;
- (void)removePropertiesWithSrcclass:(Class _Nonnull)srcclass;

- (NSSet<__kindof AutoPropertyInfo*>* _Nullable)propertiesForSrcclass:(Class _Nonnull)srcclass;

- (__kindof AutoPropertyInfo* _Nullable)propertyForDesclass:(Class _Nonnull)desclass
                                          property:(NSString* _Nonnull)property;;

@end

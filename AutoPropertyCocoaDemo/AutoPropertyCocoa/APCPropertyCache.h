//
//  APCPropertyCache.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AutoPropertyInfo;

@interface APCPropertyCache : NSObject

+ (instancetype)cache;

- (void)addProperty:(AutoPropertyInfo*)aProperty;
- (void)removeProperty:(AutoPropertyInfo*)aProperty;

- (void)removePropertiesWithSrcclass:(Class _Nonnull)srcclass;

//+ (instancetype)addSrcclass:(Class _Nonnull)srcclass
//                   desclass:(Class _Nonnull)desclass
//                   property:(NSString* _Nonnull)property;

- (NSArray* _Nullable)propertiesForSrcclass:(Class _Nonnull)srcclass;

- (id _Nullable)propertyFordesclass:(Class _Nonnull)desclass
                           property:(NSString* _Nonnull)property;;

@end

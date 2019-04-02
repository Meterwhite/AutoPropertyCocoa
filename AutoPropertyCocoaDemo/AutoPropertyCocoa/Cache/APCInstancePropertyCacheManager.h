//
//  APCInstancePropertyCacheManager.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AutoPropertyInfo;

@interface APCInstancePropertyCacheManager : NSObject

+ (void)bindProperty:(__kindof AutoPropertyInfo*)property forInstance:(id _Nonnull)instance cmd:(NSString* _Nonnull)cmd;


+ (__kindof AutoPropertyInfo* _Nullable)boundPropertyForInstance:(id _Nonnull)instance cmd:(NSString* _Nonnull)cmd;

+ (NSArray<__kindof AutoPropertyInfo*>*)boundAllPropertiesForInstance:(id _Nonnull)instance;

+ (void)boundPropertyRemoveForInstance:(id _Nonnull)instance cmd:(NSString* _Nonnull)cmd;

+ (void)boundAllPropertiesRemoveForInstance:(id _Nonnull)instance;
@end

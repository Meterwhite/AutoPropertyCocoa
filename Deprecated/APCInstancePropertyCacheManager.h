//
//  APCInstancePropertyCacheManager.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCProperty;

@interface APCInstancePropertyCacheManager : NSObject

+ (void)bindProperty:(__kindof APCProperty* _Nonnull)property toInstance:(id _Nonnull)instance cmd:(NSString* _Nonnull)cmd;

+ (__kindof APCProperty* _Nullable)boundPropertyFromInstance:(id _Nonnull)instance cmd:(NSString* _Nonnull)cmd;

+ (NSArray<__kindof APCProperty*>* _Nullable)boundAllPropertiesForInstance:(id _Nonnull)instance;

+ (void)boundPropertyRemoveFromInstance:(id _Nonnull)instance cmd:(NSString* _Nonnull)cmd;

+ (void)boundAllPropertiesRemoveFromInstance:(id _Nonnull)instance;

+ (BOOL)boundContainsValidPropertyForInstance:(id _Nonnull)instance;
@end

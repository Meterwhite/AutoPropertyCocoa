//
//  NSObject+APCExtension.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/3.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(APCExtension)


/**
 Get the original class of the instance that has been bound property.
 */
- (BOOL)apc_isKindOfClass:(nonnull Class)cls;
- (nonnull Class)apc_originalClass;
- (void)apc_instanceUnbind;
+ (void)apc_classUnbind;

- (BOOL)apc_performUserSuperAsBOOLWithObject:(nullable id)object;
- (void)apc_performUserSuperAsVoidWithObject:(nullable id)object;
- (void)apc_performUserSuperAsVoid;
- (nullable id)apc_performUserSuperAsId;
@end

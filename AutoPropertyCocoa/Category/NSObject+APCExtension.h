//
//  NSObject+APCExtension.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/3.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(APCExtension)
- (BOOL)apc_performUserSuperBOOLWithObject:(nullable id)object;
- (void)apc_performUserSuperVoidWithObject:(nullable id)object;
- (void)apc_performUserSuperVoid;
- (nullable id)apc_performUserSuperID;
@end

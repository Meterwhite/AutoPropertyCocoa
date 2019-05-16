//
//  APCClassMapper.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCScope.h"


/**
 Thread safe
 */
@interface APCClassMapper : NSObject<NSFastEnumeration>

- (BOOL)containsClass:(nonnull Class)cls;

/**
 Must first check if the Class exists.
 */
- (void)addClass:(nonnull Class)cls;

/**
 Must first check if the Class exists.
 */
- (void)removeClass:(nonnull Class)cls;

/**
 Itself and its subclasses
 */
- (void)removeKindOfClass:(nonnull Class)cls;

- (nullable Class)superclassOfClass:(nonnull Class)cls;

@end

//
//  APCClassMapper.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCScope.h"


@interface APCClassMapper : NSObject<NSFastEnumeration>

- (BOOL)containsClass:(nonnull Class)cls;

/**
 Can not duplicate.
 */
- (void)addClass:(nonnull Class)cls;

- (void)removeClass:(nonnull Class)cls;

- (nullable Class)superclassOfClass:(nonnull Class)cls;

@end

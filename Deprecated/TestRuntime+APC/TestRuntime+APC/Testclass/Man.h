//
//  Man.h
//  TestRuntime+APC
//
//  Created by NOVO on 2019/5/5.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Man : Person

- (void)name0;
- (void)name1;


@end


@interface Man(ManCategory)
- (void)name2;
@end


NS_ASSUME_NONNULL_END

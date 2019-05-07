//
//  Man.m
//  TestRuntime+APC
//
//  Created by NOVO on 2019/5/5.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import "Man.h"

@implementation Man
- (void)name0{}
- (void)name1{}
- (NSString *)name
{
    NSLog(@"In Man!");
    return @"ABC";
}
@end


@implementation Man(ManCategory)
- (void)name2{}
@end

//
//  Person.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "Person.h"

@implementation Person
{
    NSString* _name_1;
    APCRect _rect_1;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _name = @"init _name";
    }
    return self;
}

- (void)mySetName1:(NSString *)name1
{
    _name_1 = name1;
}

- (NSString *)myGetName1
{
    return _name_1;
}


-(NSString *)myGetName2
{
    return _name2;
}

- (void)mySetName3:(NSString *)name3
{
    _name3 = name3;
}

- (APCRect)myFrame1
{
    return _rect_1;
}

- (void)mySetFrame1:(APCRect)frame1
{
    _rect_1 = frame1;
}
@end

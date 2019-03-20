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
    NSString* _kkk;
    CGRect   _frame;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frame = CGRectMake(1, 1, 1, 1);
        _age = 1;
    }
    return self;
}

- (NSUInteger)getAge
{
    return _age;
}

- (CGRect)getFrame
{
    return _frame;
}

- (NSString *)myGetName
{
    return _kkk;
}

- (void)mySetName:(NSString *)name
{
    _kkk = name;
}

- (NSString*)name
{
    return _name;
}

- (void)setFrame2:(CGRect)frame
{
    _frame = frame;
}

@end

//
//  Man.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/3/14.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "Man.h"

@implementation Man
{
    id _apc_manRealizeToPerson;
}
@synthesize manObj = _manObj;

- (id)manRealizeToPerson
{
    NSLog(@"APCTest << %s << _apc_manRealizeToPerson = %@", __func__, _apc_manRealizeToPerson);
    return _apc_manRealizeToPerson;
}

- (void)setManRealizeToPerson:(id)personRealizedInMan
{
    NSLog(@"APCTest << %s << _apc_manRealizeToPerson = %@", __func__, personRealizedInMan);
    _apc_manRealizeToPerson = personRealizedInMan;
}

- (id)manObj
{
    NSLog(@"APCTest << %s << _manObj = %@", __func__, _manObj);
    return _manObj;
}

- (void)setManObj:(id)manObj
{
    NSLog(@"APCTest << %s << _manObj = %@", __func__, manObj);
    _manObj = manObj;
}

- (NSString *)manDeletedWillCallPerson
{
    return @"Man";
}



@end

//
//  Man.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "Man.h"

@implementation Man
{
    id _apc_manRealizeToPerson;
}

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

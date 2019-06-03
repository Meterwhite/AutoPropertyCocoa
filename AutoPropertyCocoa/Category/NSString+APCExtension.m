//
//  NSString+APCExtension.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/25.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "NSString+APCExtension.h"

@implementation NSString(APCExtension)

- (NSString *)apc_kvcAssumedSetterName1
{
    return [NSString stringWithFormat:@"set%@:",self.apc_firstCharUpper];
}

- (NSString *)apc_kvcAssumedSetterName2
{
    return [NSString stringWithFormat:@"_set%@",self.apc_firstCharUpper];
}

- (NSString*)apc_kvcAssumedIvarName1
{
    return [NSString stringWithFormat:@"_%@",self];
}

- (NSString*)apc_kvcAssumedIvarName2
{
    return [NSString stringWithFormat:@"_is%@",self.apc_firstCharUpper];
}

- (NSString*)apc_kvcAssumedIvarName3
{
    return self;
}

- (NSString*)apc_kvcAssumedIvarName4
{
    return [NSString stringWithFormat:@"is%@",self.apc_firstCharUpper];;
}

- (NSString *)apc_firstCharUpper
{
    if (self.length == 0)
        
        return self;
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:0]].uppercaseString];
    
    if (self.length >= 2)
        
        [string appendString:[self substringFromIndex:1]];
    
    return string;
}
@end

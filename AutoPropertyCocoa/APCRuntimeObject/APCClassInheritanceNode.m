//
//  APCClassInheritanceNode.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/22.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassInheritanceNode.h"

@implementation APCClassInheritanceNode

+ (nonnull instancetype)node
{
    return [[self alloc] init];
}

- (NSArray<APCClassInheritanceNode *> *)elderBrothersForSubclassOfClass:(Class)cls
{
    NSMutableArray* ret = [NSMutableArray array];
    APCClassInheritanceNode* node = self;
    do
    {
        
        if([node.value isSubclassOfClass:cls]){
            
            [ret addObject:node];
        }
    } while (nil != (node = node.elderBrother));
    
    return [ret copy];
}

- (nullable APCClassInheritanceNode*)childrenForSuperclassOfClass:(nullable Class)cls
{
    
}
@end

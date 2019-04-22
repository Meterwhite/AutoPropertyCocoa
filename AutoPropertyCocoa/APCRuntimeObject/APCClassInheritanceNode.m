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

- (NSArray<APCClassInheritanceNode *> *)elderBrothersThatIsSubclassToClass:(Class)cls
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

- (APCClassInheritanceNode*)firstDirectChildThatIsSuperclassToClass:(Class)cls
{
    APCClassInheritanceNode* node = self;
    while (nil != (node = node.elderBrother)) {
        
        if([cls isSubclassOfClass:node.value]){
            
            return node;
        }
    }
    
    return nil;
}
@end

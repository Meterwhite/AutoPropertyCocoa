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

+ (nonnull instancetype)nodeWithClass:(nonnull Class)cls
{
    return [[self alloc] initWithClass:cls];
}

- (instancetype)initWithClass:(Class)cls
{
    self = [super init];
    if (self) {
        
        _value = cls;
    }
    return self;
}

- (NSUInteger)brotherLevelFromRoot
{
    APCClassInheritanceNode*    iNode = self;
    NSUInteger                  lev = 0;    
    while (YES) {
        
        if(nil == (iNode = iNode.father ?: iNode.previousBrother))
            break;
        
        ++lev;
    }
    
    return lev;
}

- (NSComparisonResult)brotherLevelFromRootCompare:(nonnull APCClassInheritanceNode*)node
{
    return self.brotherLevelFromRoot - node.brotherLevelFromRoot;
}

- (void)setFather:(APCClassInheritanceNode *)father
{
    _father             = father;
    _previousBrother    = nil;
    father->_child      = self;
}

- (void)setPreviousBrother:(APCClassInheritanceNode *)previousBrother
{
    _previousBrother                = previousBrother;
    _father                         = nil;
    previousBrother->_nextBrother   = self;
}

- (void)setChild:(APCClassInheritanceNode *)child
{
    _child                  = child;
    child->_father          = child;
    child->_previousBrother = nil;
}

- (void)setNextBrother:(APCClassInheritanceNode *)nextBrother
{
    _nextBrother                    = nextBrother;
    nextBrother->_previousBrother   = nextBrother;
    nextBrother->_father            = nil;
}

- (NSArray<APCClassInheritanceNode *> *)brothersThatIsSubclassTo:(Class)cls others:(NSArray**)others
{
    NSMutableArray* ret = [NSMutableArray array];
    NSMutableArray* or  = [NSMutableArray array];
    APCClassInheritanceNode* node = self;
    do
    {
        
        if([node.value isSubclassOfClass:cls]){
            
            [ret addObject:node];
        }else{
            
            [or addObject:node];
        }
    } while (nil != (node = node.previousBrother));
    
    *others = [or copy];
    return [ret copy];
}

- (APCClassInheritanceNode*)firstFatherThatIsBaseclassTo:(Class)cls
{
    APCClassInheritanceNode* iNode = self;
    
    do {
        
        if([cls isSubclassOfClass:iNode.value])
            return iNode;
        
    } while (nil == (iNode = iNode.father ?: iNode.previousBrother));
    
    return nil;
}
@end

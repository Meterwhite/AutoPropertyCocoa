//
//  APCClassInheritanceNode.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/22.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassInheritanceNode.h"

@implementation APCClassInheritanceNode

#ifdef DEBUG
- (NSString *)description
{
    NSMutableString* str = [NSMutableString string];
    
    if(nil != _child){
        
        [str appendFormat:@"%@←", NSStringFromClass(_child.value)];
    }
    
    [str appendFormat:@"⎨%@",NSStringFromClass(_value)];
    if(nil == _father && nil == _previousBrother){
        
        [str appendString:@"(root)"];
    }else if (nil == _child && nil == _nextBrother){
        
        [str appendString:@"(leaf)"];
    }
    [str appendString:@"⎬"];
    
    if(nil != _nextBrother){
        
        [str appendFormat:@"→%@", NSStringFromClass(_nextBrother.value)];
    }
    
    return [str copy];
}
#endif

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
        
        if(nil == (iNode = iNode.father ? ((void)(++lev),iNode.father) : iNode.previousBrother)){
            
            break;
        }
    }
    
    return lev;
}

- (NSUInteger)depthToRoot
{
    APCClassInheritanceNode*    iNode = self;
    NSUInteger                  lev = 0;
    while (YES) {
        
        if(nil == (iNode = iNode.father ? iNode.father : iNode.previousBrother)){
            
            break;
        }
        ++lev;
    }
    
    return lev;
}

- (NSComparisonResult)brotherLevelFromRootCompare:(nonnull APCClassInheritanceNode*)node
{
    return self.brotherLevelFromRoot - node.brotherLevelFromRoot;
}

- (NSComparisonResult)depthToRootCompare:(APCClassInheritanceNode *)node
{
    return self.depthToRoot - node.depthToRoot;
}

- (void)setFather:(APCClassInheritanceNode *)father
{
    _father             = father;
    _previousBrother    = nil;
    if(father != nil){
        
        father->_child      = self;
    }
}

- (void)setPreviousBrother:(APCClassInheritanceNode *)previousBrother
{
    _previousBrother                = previousBrother;
    _father                         = nil;
    if(previousBrother != nil){
        previousBrother->_nextBrother   = self;
    }
}

- (void)setChild:(APCClassInheritanceNode *)child
{
    _child                  = child;
    if(child != nil){
        
        child->_father          = self;
        child->_previousBrother = nil;
    }
}

- (void)setNextBrother:(APCClassInheritanceNode *)nextBrother
{
    _nextBrother                    = nextBrother;
    if(nextBrother != nil){
        
        nextBrother->_previousBrother   = self;
        nextBrother->_father            = nil;
    }
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
    
    *others = [[or reverseObjectEnumerator] allObjects];
    return [[ret reverseObjectEnumerator] allObjects];
}

- (APCClassInheritanceNode*)firstFatherThatIsBaseclassTo:(Class)cls
{
    APCClassInheritanceNode* iNode = self;
    
    do {
        
        if([cls isSubclassOfClass:iNode.value])
            return iNode;
        
    } while (nil != (iNode = iNode.father ?: iNode.previousBrother));
    
    return nil;
}

- (APCClassInheritanceNode *)rootBrother
{
    APCClassInheritanceNode * iNode = self;
    
    while (YES){
        
        if(nil == iNode.previousBrother)
            break;
        iNode = iNode.previousBrother;
    }
    return iNode;
}
@end

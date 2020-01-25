//
//  APCClassInheritanceNode.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/22.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCClassInheritanceNode.h"

static void apc_node_DLR(APCClassInheritanceNode* node, NSMutableArray* result)
{
    if(node == nil) {
        return;
    }
    [result addObject:node];
    if (node.child != nil){
        apc_node_DLR(node.child, result);
    }
    if(node.nextBrother != nil){
        apc_node_DLR(node.nextBrother, result);
    }
}

@implementation APCClassInheritanceNode

#ifdef DEBUG
- (NSString *)description
{
    NSMutableString* str = [NSMutableString string];
    if(nil != _child){
        [str appendFormat:@"%@⇤", NSStringFromClass(_child.value)];
    }
    [str appendFormat:@"⎨%@",NSStringFromClass(_value)];
    if(nil == _father && nil == _previousBrother){
        [str appendString:@"(root)"];
    }else if (nil == _child && nil == _nextBrother){
        [str appendString:@"(leaf)"];
    }
    [str appendString:@"⎬"];
    if(nil != _nextBrother){
        [str appendFormat:@"⇢%@", NSStringFromClass(_nextBrother.value)];
    }
    return [str copy];
}
#endif

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

- (NSUInteger)brotherLevelToRoot
{
    APCClassInheritanceNode*    iNode = self;
    NSUInteger                  lev = 0;    
    while (1) {
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
    while (1) {
        if(nil == (iNode = iNode.father ? iNode.father : iNode.previousBrother)){
            break;
        }
        ++lev;
    }
    return lev;
}

- (NSComparisonResult)brotherLevelFromRootCompare:(nonnull APCClassInheritanceNode*)node
{
    return self.brotherLevelToRoot - node.brotherLevelToRoot;
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

- (BOOL)isRoot
{
    return (nil == _father) & (nil == _previousBrother);
}

- (BOOL)isLeaf
{
    return (nil != _father | nil != _previousBrother) & (!_child) & (!_nextBrother);
}

- (NSUInteger)degree
{
    return (NSUInteger)((_Bool)_father + (_Bool)_previousBrother + (_Bool)_child + (_Bool)_nextBrother);
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

- (NSArray<APCClassInheritanceNode *> *)allChild
{
    NSMutableArray* result = [NSMutableArray array];
    
    apc_node_DLR(self.child, result);
    
    return [result copy];
}

- (APCClassInheritanceNode *)rootDirectBrother
{
    APCClassInheritanceNode * iNode = self;
    while (1){
        if(nil == iNode.previousBrother) break;
        iNode = iNode.previousBrother;
    }
    return iNode;
}

- (APCClassInheritanceNode *)leafDirectBrother
{
    APCClassInheritanceNode * iNode = self;
    while (1){
        if(nil == iNode.nextBrother)  break;
        iNode = iNode.nextBrother;
    }
    return iNode;
}

- (void)clean
{
    _previousBrother    =   nil;
    _nextBrother        =   nil;
    _father             =   nil;
    _child              =   nil;
}
@end

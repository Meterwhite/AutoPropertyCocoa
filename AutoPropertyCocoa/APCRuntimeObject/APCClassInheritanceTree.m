//
//  APCClassInheritanceTree.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/22.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "APCClassInheritanceTree.h"
#import "APCClassInheritanceNode.h"

@implementation APCClassInheritanceTree
{
    NSHashTable*                _references;
}

#ifdef DEBUG
- (NSString *)description
{
    NSMutableString* str = [NSMutableString string];
    for (APCClassInheritanceNode *item in _references) {
        [str appendFormat:@"%@\n",item];
    }
    return [str copy];
}
#endif

+ (instancetype)tree
{
    return [[self alloc] init];
}

- (void)setRoot:(APCClassInheritanceNode *)root
{
    _root       =   root;
    _references =   [NSHashTable weakObjectsHashTable];
    [_references addObject:root];
}

- (APCClassInheritanceNode *)deepestNodeThatIsSuperclassTo:(Class)cls
{
    NSMutableArray* nodes = [NSMutableArray array];
    for (APCClassInheritanceNode *item in _references) {
        if([cls isSubclassOfClass:item.value]){
            [nodes addObject:item];
        }
    }
    [nodes sortUsingSelector:@selector(depthToRootCompare:)];
    return nodes.lastObject;
}

- (void)fastEnumeratedNode:(APCClassInheritanceNode *)node
{
    [_references addObject:node];
}

- (void)removeFastEnumeratedNode:(APCClassInheritanceNode *)node
{
    [_references removeObject:node];
}

- (void)remapForRoot
{
    for (APCClassInheritanceNode* item in _references) {
        if(nil == item.father && nil == item.previousBrother){
            _root = item;
        }
    }
}

- (BOOL)isEmpty
{
    return nil == _root ? YES : NO;
}

- (void)clean
{
    [_references removeAllObjects];
    _root = nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [_references countByEnumeratingWithState:state
                                            objects:buffer
                                              count:len];
}

- (NSArray<APCClassInheritanceNode*>*)leafnodesInBrotherBranch
{
    if(self.isEmpty){
        return nil;
    }
    NSMutableArray* ret = [NSMutableArray array];
    for (APCClassInheritanceNode* item in _references) {
        if(nil == item.nextBrother){
            [ret addObject:item];
        }
    }
    [ret sortUsingSelector:@selector(brotherLevelFromRootCompare:)];
    return [ret copy];
}

- (NSArray<APCClassInheritanceNode *> *)leafnodesInChildBranch
{
    if(self.isEmpty){
        return nil;
    }
    NSMutableArray* ret = [NSMutableArray array];
    for (APCClassInheritanceNode* item in _references) {
        if(nil == item.child){
            [ret addObject:item];
        }
    }
    return [ret copy];
}

@end

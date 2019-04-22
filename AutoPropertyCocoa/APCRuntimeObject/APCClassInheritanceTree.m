//
//  APCClassInheritanceTree.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/22.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassInheritanceTree.h"
#import "APCClassInheritanceNode.h"

@implementation APCClassInheritanceTree
{
    NSHashTable*                _references;
}

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

- (void)refenceNode:(APCClassInheritanceNode *)node
{
    [_references addObject:node];
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

- (NSArray<APCClassInheritanceNode*>*)topsOfYoungerBrother
{
    if(self.isEmpty){
        
        return nil;
    }
    
    NSMutableArray* ret = [NSMutableArray array];
    for (APCClassInheritanceNode* item in _references) {
        
        if(nil == item.youngerBrother){
            
            [ret addObject:item];
        }
    }
    
    return [ret copy];
}

- (NSArray<APCClassInheritanceNode *> *)topsOfChild
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

//
//  APCClassMapper.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/20.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassInheritanceTree.h"
#import "APCClassInheritanceNode.h"
#import "APCClassMapper.h"

@interface APCClassMapper()

@end

@implementation APCClassMapper
{
    NSMapTable<Class, APCClassInheritanceNode*>* _map;
    APCClassInheritanceTree*                     _tree;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _tree = [APCClassInheritanceTree tree];
        _map  = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (BOOL)containsClass:(Class)cls
{
    return (nil == [_map objectForKey:cls]) ? NO : YES;
}

- (Class)superclassOfClass:(Class)cls
{
    return [[[_map objectForKey:cls] father] value];
}

- (void)addClass:(Class)cls
{
    if(YES == [self containsClass:cls]){
        
        return;
    }
    
    ///Enumerate brother nodes
    
    if(_tree.isEmpty){
        
        _tree.root = [APCClassInheritanceNode node];
        _tree.root.value = cls;
        return;
    }
    
//    APCClassInheritanceNode* node = _tree.root;
    
    
    ///Reverse inserts a node.
//    NSArray<APCClassInheritanceNode*>* topsOfYoungerBrother = [_tree topsOfYoungerBrother];
    
    APCClassInheritanceNode* rootFather;
    for (APCClassInheritanceNode* item in [_tree topNodesForYoungerBrother]) {
        
        NSArray<APCClassInheritanceNode*>* nodes = [item elderBrothersThatIsSubclassToClass:cls];
        if(nodes.count > 1) {
            
            ///Reset point
            
            return;
        }else if (nodes.count == 1) {
            
            rootFather = item;
        }
    }
    
    ///Inserts the node forward.
    if(nil != rootFather){
        
        
    }else{
        
        
    }
    
}

@end

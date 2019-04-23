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
    
    APCClassInheritanceNode* newNode = [APCClassInheritanceNode nodeWithClass:cls];
    if(_tree.isEmpty){
        
        _tree.root = newNode;
        return;
    }
    
    NSArray* others;
    NSEnumerator<APCClassInheritanceNode*>*e;
    APCClassInheritanceNode* n_curr;
    APCClassInheritanceNode* n_next;
    for (APCClassInheritanceNode* leaf in [_tree leafnodesInBrotherBranch]) {
        
        NSArray<APCClassInheritanceNode*>* nodes = [leaf brothersThatIsSubclassTo:cls
                                                                           others:&others];
        if(nodes.count > 0) {
            
            ///Reset point
            
            ///Connect new brothers
            e = nodes.objectEnumerator;
            n_curr = e.nextObject;
            while (YES) {
                
                if(n_curr && (n_next = e.nextObject)){
                    
                    n_curr.nextBrother = n_next;
                    n_curr = n_next;
                }
                break;
            }
            ///As new father to first brothers
            newNode.child = nodes.firstObject;
            
            ///Reconnect the rest nodes as brother to the new one.
            n_curr = newNode;
            e = others.objectEnumerator;
            while (nil != (n_next = e.nextObject)) {
                
                n_curr.nextBrother = n_next;
                n_curr = n_next;
            }
            
            return;
        }
    }
    
    ///Inserts the node forward.
    for (APCClassInheritanceNode* item in [_tree leafnodesInChildBranch]) {
        
        APCClassInheritanceNode* node = [item firstFatherThatIsBaseclassTo:cls];
        if(node != nil){
            ///Reset point
            
            
        }
    }
    
    ///New basic brother.
    
    
}

@end

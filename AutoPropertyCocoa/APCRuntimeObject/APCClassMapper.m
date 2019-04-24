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
    
    NSEnumerator<APCClassInheritanceNode*>*e;
    APCClassInheritanceNode*            n_curr;
    APCClassInheritanceNode*            n_next;
    NSArray<APCClassInheritanceNode*>*  iNodes;
    APCClassInheritanceNode*            iNode;
    NSArray*                            others;
    APCClassInheritanceNode*            newNode = [APCClassInheritanceNode nodeWithClass:cls];
    if(_tree.isEmpty){
        
        _tree.root = newNode;
        goto CALL_MAP_ADD;
    }
    
    ///As superclass.
    for (APCClassInheritanceNode* leaf in [_tree leafnodesInBrotherBranch])
    {
        iNodes = [leaf brothersThatIsSubclassTo:cls others:&others];
        if(iNodes.count > 0)
        {
            ///As new root brother.
            newNode.father = leaf.rootBrother.father;
            
            ///Reset relasionship
            ///Connect new brothers in iNodes.
            e       = iNodes.objectEnumerator;
            n_curr  = e.nextObject;
            while (YES) {
                
                if(n_curr == nil)
                    break;
                
                n_next              = e.nextObject;
                n_curr.nextBrother  = n_next;
                n_curr              = n_next;
            }
            ///As father to first brothers and connect to
            newNode.child           = iNodes.firstObject;
            
            
            ///Reconnect the rest nodes as brother to the new one.
            n_curr  = newNode;
            e       = others.objectEnumerator;
            while (YES) {
                
                if(n_curr == nil)
                    break;
                
                n_next              = e.nextObject;
                n_curr.nextBrother  = n_next;
                n_curr              = n_next;
            }
            
            goto CALL_MAP_ADD;
        }
    }
    
    ///As subclass
    for (APCClassInheritanceNode* item in [_tree leafnodesInChildBranch]) {
        
        iNode = [item firstFatherThatIsBaseclassTo:cls];
        if(iNode != nil){
            
            ///Insert the new one bettwen superclass and its subclass.
            newNode.child   = iNode.child;
            iNode.child     = newNode;
            goto CALL_MAP_ADD;
        }
    }
    
    ///New basic brother.
    iNode = _tree.root;
    while (YES) {
        
        if(nil == iNode.nextBrother){
            
            break;
        }
        iNode = iNode.nextBrother;
    }
    
    iNode.nextBrother = newNode;
    
CALL_MAP_ADD:
    {
        [self mapAddNode:newNode];
    }
}

- (void)mapAddNode:(APCClassInheritanceNode*)node
{
    [_map setObject:node forKey:node.value];
    [_tree refenceNode:node];
    [_tree remapForRoot];
}

#ifdef DEBUG
- (NSString *)description
{
    return [_tree debugDescription];
}
#endif

@end

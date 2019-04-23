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
    
    for (APCClassInheritanceNode* leaf in [_tree leafnodesInBrotherBranch])
    {
        @autoreleasepool
        {
            iNodes = [leaf brothersThatIsSubclassTo:cls others:&others];
            if(iNodes.count > 0)
            {
                ///Reset relasionship
                ///Connect new brothers
                e       = iNodes.objectEnumerator;
                n_curr  = e.nextObject;
                while (YES) {
                    
                    if(n_curr && (n_next = e.nextObject)){
                        
                        n_curr.nextBrother  = n_next;
                        n_curr              = n_next;
                    }
                    break;
                }
                ///As new father to first brothers
                newNode.child = iNodes.firstObject;
                
                ///Reconnect the rest nodes as brother to the new one.
                n_curr  = newNode;
                e       = others.objectEnumerator;
                while (nil != (n_next = e.nextObject)) {
                    
                    n_curr.nextBrother  = n_next;
                    n_curr              = n_next;
                }
                
                goto CALL_MAP_ADD;
            }
        }
    }
    
    ///Inserts the node forward.
    for (APCClassInheritanceNode* item in [_tree leafnodesInChildBranch]) {
        
        iNode = [item firstFatherThatIsBaseclassTo:cls];
        if(iNode != nil){
            
            ///Insert the new one bettwen superclass and its subclass.
            newNode.child   = iNode.child;
            newNode.father  = iNode;
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
}

@end

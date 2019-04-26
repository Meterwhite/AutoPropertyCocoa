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

#define APC_CLASS_MAPPER_LOCK \
    \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);

#define APC_CLASS_MAPPER_UNLOCK \
    \
dispatch_semaphore_signal(_lock);

@interface APCClassMapper()

@end

@implementation APCClassMapper
{
    NSMapTable<Class, APCClassInheritanceNode*>*_map;
    APCClassInheritanceTree*                    _tree;
    dispatch_semaphore_t                        _lock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _tree = [APCClassInheritanceTree tree];
        _map  = [NSMapTable weakToWeakObjectsMapTable];
        _lock = dispatch_semaphore_create(1);
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
    APC_CLASS_MAPPER_LOCK;
    @autoreleasepool {
        
        NSEnumerator<APCClassInheritanceNode*>*e;
        APCClassInheritanceNode*            n_curr;
        APCClassInheritanceNode*            n_next;
        NSArray<APCClassInheritanceNode*>*  iNodes;
        APCClassInheritanceNode*            iNode;
        NSArray*                            others;
        APCClassInheritanceNode*            newNode = [APCClassInheritanceNode nodeWithClass:cls];
        if(_tree.isEmpty){
            
            _tree.root = newNode;
            goto CALL_UPDATE_NODE;
        }
        
        ///As superclass.
        for (APCClassInheritanceNode* leaf in [_tree leafnodesInBrotherBranch])
        {
            iNodes = [leaf brothersThatIsSubclassTo:cls others:&others];
            if(iNodes.count > 0)
            {
                ///As new root brother.
                newNode.father = leaf.rootDirectBrother.father;
                
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
                
                goto CALL_UPDATE_NODE;
            }
        }
        
        if(nil != (iNode = [_tree deepestNodeThatIsSuperclassTo:cls])){
            
            if((nil == iNode.child) || [iNode.child.value isSubclassOfClass:cls]){
                
                ///Insert the new one betwen superclass and its subclass.
                newNode.child   = iNode.child;
                iNode.child     = newNode;
            }else{
                
                ///Inserted as the last brother node to its subclass.
                n_curr = iNode.child;
                while (YES) {
                    
                    if(nil == n_curr.nextBrother){
                        break;
                    }
                    n_curr = n_curr.nextBrother;
                }
                n_curr.nextBrother = newNode;
            }
            
            goto CALL_UPDATE_NODE;
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
        
    CALL_UPDATE_NODE:
        {
            [_map setObject:newNode forKey:newNode.value];
            [_tree fastEnumeratedNode:newNode];
            [_tree remapForRoot];
        }
    }
    APC_CLASS_MAPPER_UNLOCK;
}

- (void)removeClass:(Class)cls
{
    APC_CLASS_MAPPER_LOCK;
    @autoreleasepool {
    
        APCClassInheritanceNode* oldNode    = [_map objectForKey:cls];
        APCClassInheritanceNode* previous   = oldNode.father ?: oldNode.previousBrother;
        APCClassInheritanceNode* newNode    = oldNode.child ?: oldNode.nextBrother;
        
        if(newNode != nil){
            
            ///Exchange ↑.
            if(previous != nil){
                
                if(oldNode.father != nil){
                    
                    newNode.father = previous;
                }else{
                    
                    newNode.previousBrother = previous;
                }
            }else{
                
                ///Root
                newNode.father = nil;
            }
            ///Exchange ↓.
            if(oldNode.child && oldNode.nextBrother){
                
                newNode.leafDirectBrother.nextBrother = oldNode.nextBrother;
            }
            
        }else if (previous != nil) {
            
            ///Leaf
            previous.child = nil;
            previous.nextBrother = nil;
        }
        
        [oldNode clean];
        [_map removeObjectForKey:oldNode.value];
        [_tree removeFastEnumeratedNode:oldNode];
        [_tree remapForRoot];
    }
    APC_CLASS_MAPPER_UNLOCK;
}

- (void)removeKindOfClass:(Class)cls
{
    APC_CLASS_MAPPER_LOCK;
    @autoreleasepool {
        
        APCClassInheritanceNode* oldNode    = [_map objectForKey:cls];
        APCClassInheritanceNode* previous   = oldNode.father ?: oldNode.previousBrother;
        APCClassInheritanceNode* insteadNode= oldNode.nextBrother ?: nil;
        NSArray*                 allChild   = oldNode.allChild;
        
        if(insteadNode != nil){
            
            ///Exchange ↑.
            if(previous != nil){
                
                if(oldNode.father != nil){
                    
                    insteadNode.father = previous;
                }else{
                    
                    insteadNode.previousBrother = previous;
                }
            }else{
                
                ///Root
                oldNode.nextBrother.father = nil;
            }
        }else if (previous != nil) {
            
            if(oldNode.father != nil){
                
                previous.child = nil;
            }else{
                
                previous.nextBrother = nil;
            }
        }
        
        for (APCClassInheritanceNode* child in allChild) {

            [child clean];
            [_map removeObjectForKey:child.value];
            [_tree removeFastEnumeratedNode:child];
        }
        [oldNode clean];
        [_map removeObjectForKey:oldNode.value];
        [_tree removeFastEnumeratedNode:oldNode];
        [_tree remapForRoot];
    }
    APC_CLASS_MAPPER_UNLOCK;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [_map countByEnumeratingWithState:state objects:buffer count:len];
}

#ifdef DEBUG
- (NSString *)description
{
    return [_tree description];
}
#endif

@end

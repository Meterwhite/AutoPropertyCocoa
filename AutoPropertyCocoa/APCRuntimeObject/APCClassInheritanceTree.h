//
//  APCClassInheritanceTree.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/22.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCClassInheritanceNode;


/**
  The binary tree represented by the class inheritance forest.
 */
@interface APCClassInheritanceTree : NSObject<NSFastEnumeration>

+ (nonnull instancetype)tree;

@property (nullable,nonatomic,strong) APCClassInheritanceNode* root;

- (nullable APCClassInheritanceNode*)deepestNodeThatIsSuperclassTo:(nonnull Class)cls;

- (void)fastEnumeratedNode:(nonnull APCClassInheritanceNode*)node;

- (void)remapForRoot;

- (BOOL)isEmpty;

- (void)clean;

/**
 Sort according to the depth of the brother branch.
 The direction of depth on the binary tree : ↙
 */
- (nullable NSArray<APCClassInheritanceNode*>*)leafnodesInBrotherBranch;

@end

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

- (void)refenceNode:(nonnull APCClassInheritanceNode*)node;

- (BOOL)isEmpty;

- (void)clean;

- (nullable NSArray<APCClassInheritanceNode*>*)topsOfYoungerBrother;

- (nullable NSArray<APCClassInheritanceNode*>*)topsOfChild;
@end

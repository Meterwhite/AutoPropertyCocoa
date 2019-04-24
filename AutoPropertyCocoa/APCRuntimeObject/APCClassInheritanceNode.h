//
//  APCClassInheritanceNode.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/22.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Node of binary tree.
 Bidirectional traversal.
 -------------------------------
 --ElderBrother---Father--------
 -----------\------/------------
 ------------\----/-------------
 -------------Node--------------
 ------------/----\-------------
 -----------/------\------------
 --------Child--YoungerBrother--
 -------------------------------
 */
@interface APCClassInheritanceNode : NSObject

+ (nonnull instancetype)node;

+ (nonnull instancetype)nodeWithClass:(nonnull Class)cls;

@property (nullable,nonatomic) Class value;


/**
 'father' and 'child' will be set at the same time.
 */
@property (nullable,nonatomic,weak)     APCClassInheritanceNode* father;
@property (nullable,nonatomic,strong)   APCClassInheritanceNode* child;

/**
 'previousBrother' and 'nextBrother' will be set at the same time.
 */
@property (nullable,nonatomic,weak)     APCClassInheritanceNode* previousBrother;
@property (nullable,nonatomic,strong)   APCClassInheritanceNode* nextBrother;


- (NSUInteger)brotherLevelFromRoot;

- (NSComparisonResult)brotherLevelFromRootCompare:(nonnull APCClassInheritanceNode*)node;

/**
 Self within.
 */
- (nonnull NSArray<APCClassInheritanceNode*>*)brothersThatIsSubclassTo:(nonnull Class)cls others:(NSArray*_Nonnull*_Nonnull)others;

/**
 Self within.
 */
- (nullable APCClassInheritanceNode*)firstFatherThatIsBaseclassTo:(nullable Class)cls;

- (nullable APCClassInheritanceNode*)rootBrother;
@end


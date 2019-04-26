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

+ (nonnull instancetype)nodeWithClass:(nonnull Class)cls;

@property (nonnull,nonatomic,readonly) Class value;

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


@property (nullable,nonatomic,strong,readonly) NSArray<APCClassInheritanceNode*>* allChild;
@property (nullable,nonatomic,strong,readonly) APCClassInheritanceNode* rootDirectBrother;
@property (nullable,nonatomic,strong,readonly) APCClassInheritanceNode* leafDirectBrother;
@property (nonatomic,readonly) NSUInteger   brotherLevelToRoot;
@property (nonatomic,readonly) NSUInteger   depthToRoot;
@property (nonatomic,readonly) NSUInteger   degree;
@property (nonatomic,readonly) BOOL         isRoot;
@property (nonatomic,readonly) BOOL         isLeaf;

- (NSComparisonResult)brotherLevelFromRootCompare:(nonnull APCClassInheritanceNode*)node;

- (NSComparisonResult)depthToRootCompare:(nonnull APCClassInheritanceNode*)node;

/**
 Self within.
 */
- (nonnull NSArray<APCClassInheritanceNode*>*)brothersThatIsSubclassTo:(nonnull Class)cls others:(NSArray*_Nonnull*_Nonnull)others;


- (void)clean;

@end


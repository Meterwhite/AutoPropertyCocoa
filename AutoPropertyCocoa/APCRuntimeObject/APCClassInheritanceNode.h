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

@property (nullable,nonatomic) Class value;

@property (nullable,nonatomic,weak) APCClassInheritanceNode* father;
@property (nullable,nonatomic,weak) APCClassInheritanceNode* youngerBrother;

@property (nullable,nonatomic,strong) APCClassInheritanceNode* child;
@property (nullable,nonatomic,strong) APCClassInheritanceNode* elderBrother;


/**
 self within.
 */
- (nonnull NSArray<APCClassInheritanceNode*>*)elderBrothersThatIsSubclassToClass:(nullable Class)cls;

/**
 self within.
 */
- (nullable APCClassInheritanceNode*)firstDirectChildThatIsSuperclassToClass:(nullable Class)cls;
@end


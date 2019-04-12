//
//  Person.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCScope.h"
@interface Person : NSObject

@property (nonatomic,copy)NSString* name;
@property (nonatomic,copy,getter=myGetName1,setter=mySetName1:)NSString* name1;
@property (nonatomic,copy,getter=myGetName2)NSString*  name2;
@property (nonatomic,copy,setter=mySetName3:)NSString* name3;

@property (nonatomic,assign)APCRect frame;
@property (nonatomic,assign,getter=myFrame1,setter=mySetFrame1:)APCRect frame1;
@property (nonatomic,assign,getter=myGetFrame2)APCRect  frame2;
@property (nonatomic,assign,setter=mySetFrame3:)APCRect frame3;

@property (nonatomic,assign)NSUInteger age;
@end

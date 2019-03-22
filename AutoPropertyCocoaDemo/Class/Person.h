//
//  Person.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

//delete it
#import <UIKit/UIKit.h>
@interface Person : NSObject

//@property (nonatomic,assign) char* name;

@property (nonatomic,copy,getter=myGetName,setter=mySetName:)NSString*   name;

//@property (nonatomic,copy)    NSString*   name;

@property (nonatomic,assign,getter=getAge)    NSUInteger  age;

@property (nonatomic,assign,getter=getFrame,setter=setFrame2:)  CGRect  frame;
@end


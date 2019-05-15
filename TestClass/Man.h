//
//  Man.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "Person.h"

@interface Man<TestType> : Person

#define key_manDeletedWillCallPerson "manDeletedWillCallPerson"
///superman called.
@property (nonatomic,nullable,copy)NSString*  manDeletedWillCallPerson;

#define key_manObj "manObj"
@property (nonatomic,nullable,strong)TestType  manObj;


@end


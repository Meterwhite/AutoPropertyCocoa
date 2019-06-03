//
//  Person.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/3/14.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCScope.h"

#define APCTestInstance(...) \
\
submacro_apc_concat(APCTestInstance_ , submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)

#define APCTestInstance_3(cls,T,var)    cls<T>* var = [cls instanceWithTestingSymbol:__func__]
#define APCTestInstance_2(cls,var)      cls* var = [cls instanceWithTestingSymbol:__func__]
#define APCTestInstance_1(cls)          APCTestInstance_2(cls)
#define APCTestInstance_0()             APCTestInstance_2()

@interface Person<TestType> : NSObject

+ (nonnull instancetype)instanceWithTestingSymbol:(nonnull const char*)symbol;

#define key_obj "obj"
@property (nonatomic,
           nullable,strong)             TestType    obj;

#define key_gettersetterobj "gettersetterobj"
@property (nonatomic,
           nullable,strong,
           getter=myGetGettersetterobj,
           setter=mySetGettersetterobj:)TestType    gettersetterobj;

#define key_getterobj "getterobj"
@property (nonatomic,
           nullable,strong,
           getter=myGetGetterobj)       TestType    getterobj;

#define key_setterobj "setterobj"
@property (nonatomic,
           nullable,strong,
           setter=mySetSetterobj:)      TestType    setterobj;

#define key_objNoIvar "objNoIvar"
@property (nonatomic,
           nullable,strong)             TestType    objNoIvar;

#define key_objReadonly "objReadonly"
@property (nonatomic,
           nullable,strong,readonly)    TestType    objReadonly;

#define key_manRealizeToPerson "manRealizeToPerson"
@property (nonatomic,
           nullable,strong)             TestType    manRealizeToPerson;

#define key_supermanRealizeToPerson "supermanRealizeToPerson"
@property (nonatomic,
           nullable,strong)             TestType    supermanRealizeToPerson;

#define key_objCopy "objCopy"
@property (nonatomic,
           nullable,copy)               TestType    objCopy;

#define key_rectValue "rectValue"
@property (assign)                      APCRect     rectValue;

#define key_intValue "intValue"
@property (assign)                      NSUInteger  intValue;

#define key_arrayValue "arrayValue"
@property (nonatomic,
           nullable,strong)             NSArray*    arrayValue;

#define key_defaultString "defaultString"
@property (nonatomic,
           nullable,copy)               NSString*   defaultString;
@end


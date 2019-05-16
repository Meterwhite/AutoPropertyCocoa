//
//  Person.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/14.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyCocoa.h"
#import "APCPropertyHook.h"
#import <objc/runtime.h>
#import "APCRuntime.h"
#import "Person.h"

@implementation Person
{
    const char *    _testingSymbol;
    NSString*       _testKind;
    NSInteger       _testID;
    
    
    id _apc_objNoIvar;
    id _apc_gettersetterobj;
    id _apc_getterobj;
    id _apc_setterobj;
//    id _manRealizeToPerson;
//    id _supermanRealizeToPerson;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithTestingSymbol:(const char *)symbol
{
    self = [super init];
    if (self) {
        
        _testingSymbol  = symbol;
        
        NSString* str   = [NSString stringWithUTF8String:_testingSymbol];
        NSArray* cnps   = [str componentsSeparatedByString:@"__"];
        _testKind       = cnps.firstObject;
        _testID         = [cnps.lastObject integerValue];
    }
    return self;
}

+ (instancetype)instanceWithTestingSymbol:(const char *)symbol
{
    return [[self alloc] initWithTestingSymbol:symbol];
}

- (id)objNoIvar
{
    NSLog(@"APCTest << %s << _apc_objNoIvar = %@", __func__, _apc_objNoIvar);
    return _apc_objNoIvar;
}

- (void)setObjNoIvar:(id)objNoIvar
{
    NSLog(@"APCTest << %s << _apc_objNoIvar = %@", __func__, objNoIvar);
    _apc_objNoIvar = objNoIvar;
}

- (id)myGetGettersetterobj
{
    NSLog(@"APCTest << %s << _apc_gettersetterobj = %@", __func__, _apc_gettersetterobj);
    return _apc_gettersetterobj;
}

- (void)mySetGettersetterobj:(id)gettersetterobj
{
    NSLog(@"APCTest << %s << _apc_gettersetterobj = %@", __func__, gettersetterobj);
    _apc_gettersetterobj = gettersetterobj;
}

- (id)myGetGetterobj
{
    NSLog(@"APCTest << %s << _apc_getterobj = %@", __func__, _apc_getterobj);
    return _apc_getterobj;
}

- (void)mySetSetterobj:(id)setterobj
{
    NSLog(@"APCTest << %s << _apc_setterobj = %@", __func__, setterobj);
    _apc_setterobj = setterobj;
}

- (NSString *)description
{
    NSMutableString* ret = [NSMutableString stringWithString:NSStringFromClass([self class])];
    
    [ret appendFormat:@":%p",self];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"APC: Testing symbol << %s", _testingSymbol];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_obj = %@", _obj];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_obj = %@", _apc_objNoIvar];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_apc_gettersetterobj = %@", _apc_gettersetterobj];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_apc_getterobj = %@", _apc_getterobj];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_apc_setterobj = %@", _apc_setterobj];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_apc_setterobj = %@", _objCopy];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_objReadonly = %@", _objReadonly];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_rectValue = %@", [NSValue valueWithRect:_rectValue]];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_intValue = %@", @(_intValue)];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_manRealizeToPerson = %@", _manRealizeToPerson];
    
    [ret appendString:@"\n"];
    [ret appendFormat:@"_supermanRealizeToPerson = %@", _supermanRealizeToPerson];
    
    return [ret copy];
}

- (void)dealloc
{
    NSLog(@"%s/%@/dealloc : %p",_testingSymbol,NSStringFromClass([self class]), self);
    Class cls = apc_object_hookWithProxyClass(self);
    objc_disposeClassPair(cls);
//    _objc_flush_caches([NSObject class]);
//    _objc_flush_caches([APCPropertyHook class]);
}

- (NSString *)manDeletedWillCallPerson
{
    return @"Person";
}

@end

//
//  APCPropertyMappingKey.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/18.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyMappingKey.h"
#import <objc/runtime.h>

@implementation APCPropertyMappingKey
{
    NSString*   _property_name;
    NSString*   _getter_name;
    NSString*   _setter_name;
}

static Class _icls;
+ (void)load
{
    _icls = [APCPropertyMappingKey class];
}


//- (NSString *)property
//{
//    return _property_name;
//}
//
//- (NSString *)getter
//{
//    return _getter_name;
//}
//
//- (NSString *)setter
//{
//    return _setter_name;
//}

- (instancetype)initWithProperty:(NSString*)property
                                  getter:(NSString*)getter
                                  setter:(NSString*)setter
{
    self = [super init];
    if (self) {
        
        NSAssert(property, @"APC: property should not be nil.");
        
        _property_name  = property;
        _getter_name    = getter;
        _setter_name    = setter;
    }
    return self;
}

- (instancetype)initWithMatchingProperty:(NSString*)property
{
    self = [super init];
    if (self) {
        
        _property_name = property;
    }
    return self;
}

- (NSUInteger)hash
{
    return 0;
}

- (BOOL)isEqual:(APCPropertyMappingKey*)object
{
//    NSLog(@"%p",_property_name);
//    NSLog(@"%p",object->_property_name);
//    NSLog(@"%p",object->_getter_name  );
//    NSLog(@"%p",object->_setter_name  );
    ///1 to 1
    if((_property_name == object->_property_name||
        _property_name == object->_getter_name  ||
        _property_name == object->_setter_name  )){
        
        return YES;
    }
    
    /**
     Removed because of optimization
     
     if(object_getClass(object) != _icls){
     
     return NO;
     }
     */
    
    NSUInteger len = _property_name.length;
    if((len != object->_property_name.length&&
        len != object->_getter_name.length  &&
        len != object->_setter_name.length  )){
        
        return NO;
    }
    
    ///1 to n
    if(([_property_name isEqualToString:object->_property_name] ||
       [_property_name isEqualToString:object->_getter_name]    ||
       [_property_name isEqualToString:object->_setter_name]    )){
        
        return YES;
    }
    
    return NO;
}

- (NSString *)description
{
    NSMutableString* string = [NSMutableString stringWithString:[super description]];
    
    [string appendString:@"[:"];
    [string appendString:_property_name];
    
    if(_getter_name){
        
        [string appendString:@",G:"];
        [string appendString:_getter_name];
    }
    
    if(_setter_name){
        
        [string appendString:@",S:"];
        [string appendString:_setter_name];
    }
    
    [string appendString:@"]"];
    
    return [string copy];
}

@end

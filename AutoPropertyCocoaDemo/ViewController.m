//
//  ViewController.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyCocoa/Property/AutoLazyPropertyInfo.h"
#import "AutoPropertyCocoa/APCPropertyMapperKey.h"
#import "AutoPropertyCocoa/APCPropertyMapperCache.h"
#import "NSObject+APCLazyLoad.h"
#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "APCScope.h"
#import "APCHash.h"
#import "Person.h"
#import "Man.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self testClassSuperclassSubclass];
//    [self testHash];
//    [self testMapperCache];
}


- (void)testClassSuperclassSubclass
{
    [Person apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {

        return @(999);
    }];
    
    [Man apc_lazyLoadForProperty:@"age" usingBlock:^id _Nullable(id  _Nonnull _self) {
        
        return @(111);
    }];
    
//    [Person apc_unbindLazyLoadForProperty:@"age"];
    
//    [Man apc_unbindLazyLoadForProperty:@"age"];
    
    Person* p = [Person new];
    NSUInteger age0 = p.age;
    Man* m = [Man new];
    NSUInteger age1 = m.age;
}

- (void)testHash
{
    Class p = [Person class];
    Class m = [Man class];
    NSString* propertyName = @"age";
    
    
    NSUInteger hashP = [p hash];
    NSUInteger hashM = [m hash];
    NSUInteger hashN = [propertyName hash];//21042608 516213936
    
//    NSUInteger t0 = apc_hash_cantorpairing(1111, 9999);
//
//    NSUInteger d0;
//    NSUInteger d1;
//    apc_hash_decantorpairing(t0, &d0, &d1);
    
    
    NSUInteger h0 = hashM;
    NSUInteger h1 = hashN;
    
    void* ptr = malloc(sizeof(NSUInteger) * 2);
    
    memcpy(ptr, &h0, sizeof(NSUInteger));
    
    memcpy(ptr+sizeof(NSUInteger), &h1, sizeof(NSUInteger));
    
    NSUInteger xx = apc_hash_bytes(ptr, 2 * sizeof(NSUInteger));
    
    free(ptr);
    
    NSMutableData* data = [NSMutableData data];
    
    [data appendBytes:&h0 length:sizeof(NSUInteger)];
    
    [data appendBytes:&h1 length:sizeof(NSUInteger)];
    
    NSUInteger yy = apc_hash_bytes((uint8_t*)data.bytes, 2 * sizeof(NSUInteger));
    //21042608 516213936
}


- (void)testMapperCache
{
    
    
//    APCPropertyMapperCache* cache = [APCPropertyMapperCache cache];
//
//    cache addProperty:<#(AutoPropertyInfo *)#>
    
    id k0 = [APCPropertyMapperKey keyWithClass:self.class];
    id k1 = [APCPropertyMapperKey keyWithClass:self.class];
    
    NSMutableDictionary* mdic = NSMutableDictionary.dictionary;
    
    mdic[k0] = @"A";
    mdic[k1] = @"B";
    
    id xx = mdic[NSStringFromClass(self.class)];
    NSLog(@"%@",mdic);
}
@end

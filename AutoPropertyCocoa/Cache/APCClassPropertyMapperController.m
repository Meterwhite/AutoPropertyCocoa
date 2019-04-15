//
//  APCClassPropertyMapperController.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassPropertyMapperController.h"
#import "APCPropertyMapperkey.h"
#import "APCProperty.h"

@interface APCClassPropertyMapperController ()
{
    dispatch_semaphore_t _lock;
}
///(Desclass,propertyName) ----> p
@property (nonatomic,strong) NSMapTable*    mapperForDesclassAndProperty;

///Srcclass ----> {p0, p1, ...}
@property (nonatomic,strong) NSMapTable*    mapperForSrcclassAndProperty;

@end

@implementation APCClassPropertyMapperController

+ (instancetype)cache
{
    return [[self alloc] init];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _lock = dispatch_semaphore_create(1);
        
        _mapperForDesclassAndProperty = [NSMapTable strongToStrongObjectsMapTable];
        
        _mapperForSrcclassAndProperty = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

//
///**
// The same object will be replaced.
// */
//- (void)addProperty:(APCProperty *)aProperty
//{
//    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
//
//    APCPropertyMapperkey*           keyForClass      = [aProperty classMapperkey];
//    NSSet<APCPropertyMapperkey*>*   keysForProperty  = [aProperty propertyMapperkeys];
//
//    NSMutableSet*            pties = [self.mapperForSrcclassAndProperty objectForKey:keyForClass];
//    if(nil == pties){
//
//        pties = [NSMutableSet set];
//        [self.mapperForSrcclassAndProperty setObject:pties forKey:keyForClass];
//    }
//    [pties addObject:aProperty];
//
//    NSEnumerator*         em = keysForProperty.objectEnumerator;
//    APCPropertyMapperkey* keyForProperty;
//    while (nil != (keyForProperty = em.nextObject)) {
//
//        [self.mapperForDesclassAndProperty setObject:aProperty forKey:keyForProperty];
//    }
//
//    dispatch_semaphore_signal(_lock);
//}
//
//- (void)removeProperty:(APCProperty *)aProperty
//{
//    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
//
//    [[self.mapperForSrcclassAndProperty objectForKey:aProperty.classMapperkey] removeObject:aProperty];
//
//    [aProperty.propertyMapperkeys enumerateObjectsUsingBlock:^(APCPropertyMapperkey * _Nonnull aKey, BOOL * _Nonnull stop) {
//
//        [self.mapperForDesclassAndProperty removeObjectForKey:aKey];
//    }];
//
//    dispatch_semaphore_signal(_lock);
//}
//
//- (void)removePropertiesWithSrcclass:(Class)srcclass
//{
//    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
//
//    APCPropertyMapperkey*   keyForSrc   = [APCPropertyMapperkey keyWithClass:srcclass];
//    NSMutableSet*           set         = [self.mapperForSrcclassAndProperty objectForKey:keyForSrc];
//    NSEnumerator*           e           = set.objectEnumerator;
//    APCProperty*       p;
//    [self.mapperForSrcclassAndProperty removeObjectForKey:keyForSrc];
//    while (nil != (p = e.nextObject)) {
//
//        [self.mapperForDesclassAndProperty removeObjectForKey:p.propertyMapperkeys];
//    }
//
//    dispatch_semaphore_signal(_lock);
//}
//
//- (__kindof APCProperty*)propertyForDesclass:(Class)desclass
//                                         property:(NSString *)property
//{
//    return
//
//    [self.mapperForDesclassAndProperty objectForKey:
//     [APCPropertyMapperkey keyWithClass:desclass property:property]];
//}
//
//- (__kindof APCProperty*)searchFromTargetClass:(Class _Nullable)desclass
//                                        property:(NSString *)property
//{
//    if(desclass == nil){
//
//        return nil;
//    }
//
//    APCProperty* p = [self.mapperForDesclassAndProperty objectForKey:
//                           [APCPropertyMapperkey keyWithClass:desclass property:property]];
//
//    if(p == nil){
//
//        return [self searchFromTargetClass:[desclass superclass] property:property];
//    }
//
//    return p;
//}
//
//- (NSSet *)propertiesForSrcclass:(Class)srcclass
//{
//    return
//    
//    [[self.mapperForSrcclassAndProperty objectForKey:
//      [APCPropertyMapperkey keyWithClass:srcclass]] copy];
//}

@end

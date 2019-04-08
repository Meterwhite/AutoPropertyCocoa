//
//  APCClassPropertyMapperCache.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassPropertyMapperCache.h"
#import "APCPropertyMapperkey.h"
#import "AutoPropertyInfo.h"

@interface APCClassPropertyMapperCache ()
{
    dispatch_semaphore_t _lock;
}
@property (nonatomic,strong) NSMutableSet*  references;
///strong to weak.
///(Desclass,propertyName) ----> (weak)p
@property (nonatomic,strong) NSMapTable*    mapperForDesclassAndProperty;
///strong to strong.
///Srcclass ----> (strong){(weak)p0, (weak)p1, ...}
@property (nonatomic,strong) NSMapTable*    mapperForSrcclassAndProperty;

@end

@implementation APCClassPropertyMapperCache

+ (instancetype)cache
{
    return [[self alloc] init];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _lock = dispatch_semaphore_create(1);
        
        _references = [NSMutableSet setWithCapacity:31];
        
        _mapperForDesclassAndProperty
        = [NSMapTable strongToWeakObjectsMapTable];
        
        _mapperForSrcclassAndProperty
        = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}


/**
 The same object will be replaced.
 */
- (void)addProperty:(AutoPropertyInfo *)aProperty
{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    APCPropertyMapperkey*           keyForClass      = [aProperty classMapperkey];
    NSSet<APCPropertyMapperkey*>*   keysForProperty  = [aProperty propertyMapperkeys];
    
    if(YES == [self.references containsObject:aProperty]){
        
        [self.references removeObject:aProperty];
    }
    
    [self.references addObject:aProperty];
    
    NSHashTable*            pties = [self.mapperForSrcclassAndProperty objectForKey:keyForClass];
    if(nil == pties){
        
        pties = [NSHashTable weakObjectsHashTable];
        [self.mapperForSrcclassAndProperty setObject:pties forKey:keyForClass];
    }
    [pties addObject:aProperty];
    
    NSEnumerator*         em = keysForProperty.objectEnumerator;
    APCPropertyMapperkey* keyForProperty;
    while (nil != (keyForProperty = em.nextObject)) {
        
        [self.mapperForDesclassAndProperty setObject:aProperty forKey:keyForProperty];
    }
    
    dispatch_semaphore_signal(_lock);
}

- (void)removeProperty:(AutoPropertyInfo *)aProperty
{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    [self.references removeObject:aProperty];
    
    dispatch_semaphore_signal(_lock);
}

- (void)removePropertiesWithSrcclass:(Class)srcclass
{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    id obj;
    APCPropertyMapperkey* keyForSrc = [APCPropertyMapperkey keyWithClass:srcclass];
    NSHashTable*    tab = [self.mapperForSrcclassAndProperty objectForKey:keyForSrc];
    NSEnumerator*   e   = tab.objectEnumerator;
    while (nil != (obj = e.nextObject)) {
        
        [self.references removeObject:obj];
    }
    
    dispatch_semaphore_signal(_lock);
}

- (__kindof AutoPropertyInfo*)propertyForDesclass:(Class)desclass
                                         property:(NSString *)property
{
    return
    
    [self.mapperForDesclassAndProperty objectForKey:
     [APCPropertyMapperkey keyWithClass:desclass property:property]];
}

- (NSSet *)propertiesForSrcclass:(Class)srcclass
{
    return
    
    [[self.mapperForSrcclassAndProperty objectForKey:
      [APCPropertyMapperkey keyWithClass:srcclass]]
     
     setRepresentation];
}

@end

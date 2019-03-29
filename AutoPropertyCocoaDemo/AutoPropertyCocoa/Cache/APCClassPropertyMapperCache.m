//
//  APCClassPropertyMapperCache.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCClassPropertyMapperCache.h"
#import "APCPropertyMapperKey.h"
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
    APCPropertyMapperKey* keyForSrc = [APCPropertyMapperKey keyWithClass:aProperty->_src_class];
    
    APCPropertyMapperKey* keyForDes = [APCPropertyMapperKey keyWithClass:aProperty->_des_class
                                                                property:aProperty->_ogi_property_name];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if(YES == [self.references containsObject:aProperty]){
        
        [self.references removeObject:aProperty];
    }
    
    [self.references addObject:aProperty];
    
    NSHashTable* pts = [self.mapperForSrcclassAndProperty objectForKey:keyForSrc];
    if(nil == pts){
        
        pts = [NSHashTable weakObjectsHashTable];
        [self.mapperForSrcclassAndProperty setObject:pts forKey:keyForSrc];
    }
    [pts addObject:aProperty];
    [self.mapperForDesclassAndProperty setObject:aProperty forKey:keyForDes];
    
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
    APCPropertyMapperKey* keyForSrc = [APCPropertyMapperKey keyWithClass:srcclass];
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
     [APCPropertyMapperKey keyWithClass:desclass property:property]];
}

- (NSSet *)propertiesForSrcclass:(Class)srcclass
{
    return
    
    [[self.mapperForSrcclassAndProperty objectForKey:
      [APCPropertyMapperKey keyWithClass:srcclass]]
     
     setRepresentation];
}

@end

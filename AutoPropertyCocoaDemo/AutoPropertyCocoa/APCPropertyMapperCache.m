//
//  APCPropertyMapperCache.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyMapperCache.h"
#import "APCPropertyMapperKey.h"
#import "AutoPropertyInfo.h"

@interface APCPropertyMapperCache ()
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

@implementation APCPropertyMapperCache

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

- (void)addProperty:(AutoPropertyInfo *)aProperty
{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
#warning self.references add:/aProperty hash
    if([self.references containsObject:aProperty]){
        
        dispatch_semaphore_signal(_lock);
        return;
    }
    
    
    APCPropertyMapperKey* keyForSrc = [APCPropertyMapperKey keyWithClass:aProperty->_src_class];
    
    APCPropertyMapperKey* keyForDes = [APCPropertyMapperKey keyWithClass:aProperty->_src_class
                                                              property:aProperty->_ogi_property_name];
    
    if(nil == [self.mapperForSrcclassAndProperty objectForKey:keyForSrc]){
        
        NSHashTable* tab = [NSHashTable weakObjectsHashTable];
        
        [tab addObject:aProperty];
        [self.mapperForSrcclassAndProperty setObject:tab forKey:keyForSrc];
    }

    
    if(nil == [self.mapperForDesclassAndProperty objectForKey:keyForDes]){
        
        [self.mapperForDesclassAndProperty setObject:keyForDes forKey:aProperty];
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
    APCPropertyMapperKey* keyForSrc = [APCPropertyMapperKey keyWithClass:srcclass];
    NSHashTable*    tab = [self.mapperForSrcclassAndProperty objectForKey:keyForSrc];
    NSEnumerator*   e   = tab.objectEnumerator;
    while (nil != (obj = e.nextObject)) {
        
        [self.references removeObject:obj];
    }
    
    dispatch_semaphore_signal(_lock);
}

- (id)propertyForDesclass:(Class)desclass property:(NSString *)property
{
    return
    
    [self.mapperForDesclassAndProperty objectForKey:apc_desMapperKeyString(desclass, property)];
}

- (NSSet *)propertiesForSrcclass:(Class)srcclass
{
    return
    
    [[self.mapperForSrcclassAndProperty objectForKey:apc_srcMapperKeyString(srcclass)]
      setRepresentation];
}

@end

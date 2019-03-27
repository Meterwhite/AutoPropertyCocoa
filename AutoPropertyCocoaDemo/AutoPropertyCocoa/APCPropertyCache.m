//
//  APCPropertyCache.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyCacheKey.h"
#import "APCPropertyCache.h"
#import "AutoPropertyInfo.h"

@interface APCPropertyCache ()
@property (nonatomic,strong) NSLock* cacheLock;

@property (nonatomic,strong)
    NSMutableDictionary<APCPropertyCacheKey*, NSMutableSet<AutoPropertyInfo*>*>*
    cacheOfSrc;

@property (nonatomic,strong)
    NSMutableDictionary<APCPropertyCacheKey*, AutoPropertyInfo*>*
    cacheOfProperties;
@end

@implementation APCPropertyCache

+ (instancetype)cache
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _cacheLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)addProperty:(AutoPropertyInfo *)aProperty
{
    
    APCPropertyCacheKey* keyForSrc = [APCPropertyCacheKey keyWithClass:aProperty->_src_class];
    
}



- (NSMutableDictionary *)cacheOfProperties
{
    [self.cacheLock lock];
    
    if(nil == _cacheOfProperties){
        
        _cacheOfProperties = [NSMutableDictionary dictionary];
    }
    
    [self.cacheLock unlock];
    
    return _cacheOfProperties;
}


- (NSMutableDictionary *)cacheOfSrc
{
    [self.cacheLock lock];
    
    if(nil == _cacheOfSrc){
        
        _cacheOfSrc = [NSMutableDictionary dictionary];
    }
    
    [self.cacheLock unlock];
    
    return _cacheOfSrc;
}
@end

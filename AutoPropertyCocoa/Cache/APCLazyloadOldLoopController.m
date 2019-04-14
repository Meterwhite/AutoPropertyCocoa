//
//  APCLazyloadOldLoopController.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/13.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCLazyloadOldLoopController.h"
#import "APCScope.h"

/**
 {(weak)ThreadID : {(weak)Instance : count}}
 */
static NSMapTable* _apc_lazyload_oldloop_mapper;

NS_INLINE NSMapTable* apc_oldloop_instance_mapper()
{
    return [_apc_lazyload_oldloop_mapper objectForKey:APCThreadID];
}

@implementation APCLazyloadOldLoopController

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apc_lazyload_oldloop_mapper = [NSMapTable weakToStrongObjectsMapTable];
    });
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    NSAssert(NO, @"Instantiation of APCLazyloadOldLoopController is not allowed!");
    
    return nil;
}

+ (void)joinLoop:(id)instance
{
    NSMapTable* map = apc_oldloop_instance_mapper();
    
    if(map == nil){
        
        map = [NSMapTable weakToStrongObjectsMapTable];
        
        [map setObject:[NSNumber numberWithUnsignedInteger:1] forKey:instance];
        
        [_apc_lazyload_oldloop_mapper setObject:map forKey:APCThreadID];
        
        return;
    }
    
    [map setObject:[NSNumber numberWithUnsignedInteger:([[map objectForKey:instance] unsignedIntegerValue] + 1)]
            forKey:instance];
}

+ (void)breakLoop:(id)instance
{
    [apc_oldloop_instance_mapper() removeObjectForKey:instance];
}

+ (BOOL)testingIsInLoop:(id)instance
{
    return [self loopCount:instance];
}

+ (NSUInteger)loopCount:(id)instance
{
    return [[apc_oldloop_instance_mapper() objectForKey:instance] unsignedIntegerValue];
}
@end



//
//  NSObject+APC.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+APCExtension.h"

@implementation NSObject(APCExtension)
- (id)apc_performSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    if (signature == nil) {
        //
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = aSelector;
    [invocation invoke];
    id __unsafe_unretained returnValue;
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}

- (id)apc_performSelector:(SEL)aSelector withObject:(id)object
{
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    if (signature == nil) {
        //
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = aSelector;
    if(signature.numberOfArguments>2)
        [invocation setArgument:&object atIndex:2];//去掉self,_cmd所以从2开始
    [invocation invoke];
    id __unsafe_unretained returnValue;
    if (signature.methodReturnLength > 0) {
        
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}
@end

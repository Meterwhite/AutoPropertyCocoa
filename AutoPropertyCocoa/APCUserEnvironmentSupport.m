//
//  APCUserEnvironmentSupport.m
//  AutoPropertyCocoaiOS
//
//  Created by Novo on 2019/4/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCUserEnvironmentSupport.h"
#import "APCScope.h"

@implementation APCUserEnvironmentSupport
{
    id                              _instance;
    id<APCUserEnvironmentMessage>   _message;
}

- (id)initWithObject:(NSObject *)object message:(id<APCUserEnvironmentMessage>)message
{
    NSAssert([message conformsToProtocol:@protocol(APCUserEnvironmentMessage)]
             , @"APC: Object that is not supported.");
    _instance = object;
    _message = message;
    return self;
}

#pragma mark - received message

- (id)superMessage
{
    return [_message superObject];
}

- (id)setSuperMessagePerformerForAction:(APCUserEnvironmentAction)action
{
    _superMessagePerformerForAction = [action copy];
    return self;
}

- (void)performSuperMessage_void
{
    APCSafeBlockInvok(self->_superMessagePerformerForAction, self);
}

- (BOOL)performSuperMessage_BOOL
{
    APCSafeBlockInvok(self->_superMessagePerformerForAction, self);
    return _returnedBOOLValue;
}

- (id)performSuperMessage_id
{
    APCSafeBlockInvok(self->_superMessagePerformerForAction, self);
    return _returnedIDValue;
}

#pragma mark - Fast forwarding messages
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _instance;
}

#pragma mark - Overwrite NSProxy
- (void)forwardInvocation:(NSInvocation *)invocation
{
    return [_instance forwardInvocation:invocation];
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_instance methodSignatureForSelector:sel];
}

- (void)dealloc
{
    _superMessagePerformerForAction = nil;
    _instance                       = nil;
    _message                        = nil;
}

#pragma mark - Overwrite <NSObject>

- (BOOL)isEqual:(id)object
{
    return [_instance isEqual:object];
}

- (NSUInteger)hash
{
    return [_instance hash];
}

- (Class)superclass
{
    return [_instance superclass];
}
- (Class)class
{
    return [_instance class];
}
- (id)self
{
    return (id)_instance;
}

- (id)performSelector:(SEL)aSelector
{
    return (((id(*)(id, SEL))[_instance methodForSelector:aSelector])(_instance, aSelector));
}
- (id)performSelector:(SEL)aSelector withObject:(id)object
{
    return (((id(*)(id, SEL, id))[_instance methodForSelector:aSelector])(_instance, aSelector, object));
}
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
{
    return (((id(*)(id, SEL, id, id))[_instance methodForSelector:aSelector])(_instance, aSelector, object1, object2));
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return [_instance isKindOfClass:aClass];
}
- (BOOL)isMemberOfClass:(Class)aClass
{
    return [_instance isMemberOfClass:aClass];
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [_instance conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [_instance respondsToSelector:aSelector];
}

- (NSString *)description
{
    return [_instance description];
}

- (NSString *)debugDescription
{
    return [_instance debugDescription];
}

@end

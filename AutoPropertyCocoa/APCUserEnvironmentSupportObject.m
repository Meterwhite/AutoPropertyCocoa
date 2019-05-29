//
//  APCUserEnvironmentSupportObject.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCUserEnvironmentSupportObject.h"
#import "APCScope.h"

@implementation APCUserEnvironmentSupportObject
{
    id                              _instance;
    id<APCUserEnvironmentMessage>   _message;
    SEL                             _action;
}

- (id)initWithObject:(NSObject *)object
             message:(id<APCUserEnvironmentMessage>)message
              action:(SEL)action
{
    NSAssert([message conformsToProtocol:@protocol(APCUserEnvironmentMessage)]
             , @"APC: Need conforms to APCUserEnvironmentMessage.");
    _instance = object;
    _message = message;
    _action = action;
    return self;
}

- (SEL)apc_environmentAction
{
    return _action;
}

#pragma mark - received message

- (id)apc_superEnvironmentMessage
{
    return [_message superEnvironmentMessage];
}

- (void)apc_performUserSuperAsVoid
{
    ((void(*)(id,SEL,id))objc_msgSend)([self apc_superEnvironmentMessage]
                                          , _action
                                          , _instance);
}

- (void)apc_performUserSuperAsVoidWithObject:(id)object
{
    ((void(*)(id,SEL,id,id))objc_msgSend)([self apc_superEnvironmentMessage]
                                             , _action
                                             , _instance
                                             , object);
}

- (BOOL)apc_performUserSuperAsBOOLWithObject:(id)object
{
    return ((BOOL(*)(id,SEL,id,id))objc_msgSend)([self apc_superEnvironmentMessage]
                                                    , _action
                                                    , _instance
                                                    , object);
}

- (id)apc_performUserSuperAsId
{
    return
    
    ((id(*)(id,SEL,id))objc_msgSend)([self apc_superEnvironmentMessage]
                                     , _action
                                     , _instance);
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
    _instance   =   nil;
    _message    =   nil;
    _action     =   nil;
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


#pragma mark - debug working
#ifdef DEBUG
void apc_debug_super_method_void1(APCUserEnvironmentSupportObject* instance)
{
    if(![instance isProxy]){
        
        return;
    }
    ((void(*)(id,SEL,id))objc_msgSend)([instance apc_superEnvironmentMessage]
                                       , [instance apc_environmentAction]
                                       , [instance self]);
}

void apc_debug_super_method_void2(APCUserEnvironmentSupportObject* instance, id object)
{
    if(![instance isProxy]){
        
        return;
    }
    ((void(*)(id,SEL,id,id))objc_msgSend)([instance apc_superEnvironmentMessage]
                                          , [instance apc_environmentAction]
                                          , [instance self]
                                          , object);
}

BOOL apc_debug_super_method_BOOL2(APCUserEnvironmentSupportObject* instance, id object)
{
    if(![instance isProxy]){
        
        return NO;
    }
    
    return
    
    ((BOOL(*)(id,SEL,id,id))objc_msgSend)([instance apc_superEnvironmentMessage]
                                          , [instance apc_environmentAction]
                                          , [instance self]
                                          , object);
}

id apc_debug_super_method_id1(APCUserEnvironmentSupportObject* instance)
{
    if(![instance isProxy]){
        
        return nil;
    }
    
    return
    
    ((id(*)(id,SEL,id))objc_msgSend)([instance apc_superEnvironmentMessage]
                                          , [instance apc_environmentAction]
                                          , [instance self]);
}
#endif

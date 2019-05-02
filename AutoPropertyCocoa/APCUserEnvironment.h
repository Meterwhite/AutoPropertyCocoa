//
//  APCUserEnvironment.h
//  AutoPropertyCocoaiOS
//
//  Created by Novo on 2019/4/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "APCScope.h"

@class APCUserEnvironment;

@protocol APCUserEnvironmentSupport <NSObject>
- (nonnull id)self;
@end

@protocol APCUserEnvironmentMessage <NSObject>
- (nullable id<APCUserEnvironmentMessage>)superObject;
@end

typedef id apc_id;
typedef id<APCUserEnvironmentSupport> APCID;
typedef APCUserEnvironment APCObject;

#ifdef DEBUG

OBJC_EXPORT void
apc_debug_super_method_void1(APCObject* _Nonnull instance);

OBJC_EXPORT void
apc_debug_super_method_void2(APCObject* _Nonnull instance, id _Nullable object);

OBJC_EXPORT BOOL
apc_debug_super_method_BOOL2(APCObject* _Nonnull instance, id _Nullable object);

OBJC_EXPORT id _Nullable
apc_debug_super_method_id1(APCObject* _Nonnull instance);


#define apc_void_super_method(...) \
submacro_apc_concat(apc_debug_super_method_void, submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)

#define apc_bool_super_method(...) \
submacro_apc_concat(apc_debug_super_method_BOOL, submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)

#define apc_id_super_method(...) \
submacro_apc_concat(apc_debug_super_method_id, submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)

#define apc_debug_super_method_void0 apc_debug_super_method_void1
#define apc_debug_super_method_void3 apc_debug_super_method_void2
#define apc_debug_super_method_void4 apc_debug_super_method_void2
#define apc_debug_super_method_void5 apc_debug_super_method_void2
#define apc_debug_super_method_void6 apc_debug_super_method_void2

#define apc_debug_super_method_BOOL0 apc_debug_super_method_BOOL2
#define apc_debug_super_method_BOOL1 apc_debug_super_method_BOOL2
#define apc_debug_super_method_BOOL3 apc_debug_super_method_BOOL2
#define apc_debug_super_method_BOOL4 apc_debug_super_method_BOOL2
#define apc_debug_super_method_BOOL5 apc_debug_super_method_BOOL2
#define apc_debug_super_method_BOOL6 apc_debug_super_method_BOOL2

#define apc_debug_super_method_id0 apc_debug_super_method_id1
#define apc_debug_super_method_id2 apc_debug_super_method_id1
#define apc_debug_super_method_id3 apc_debug_super_method_id1
#define apc_debug_super_method_id4 apc_debug_super_method_id1
#define apc_debug_super_method_id5 apc_debug_super_method_id1
#define apc_debug_super_method_id6 apc_debug_super_method_id1

#else


#define apc_void_super_method(...) \
\
if(YES == [submacro_apc_head(__VA_ARGS__) isProxy]){\
\
((void(*)(apc_msgSend_t_list(__VA_ARGS__)))objc_msgSend)   \
    (\
        [(APCObject*)submacro_apc_head(__VA_ARGS__) superMessage]\
        , [(APCObject*)submacro_apc_head(__VA_ARGS__) action]   \
        , __VA_ARGS__ \
    );\
}

#define apc_bool_super_method(...) \
\
((YES == [submacro_apc_head(__VA_ARGS__) isProxy])\
?\
((BOOL(*)(apc_msgSend_t_list(__VA_ARGS__)))objc_msgSend)   \
(\
    [(APCObject*)submacro_apc_head(__VA_ARGS__) superMessage]\
    , [(APCObject*)submacro_apc_head(__VA_ARGS__) action]   \
    , __VA_ARGS__ \
) : NO)

#define apc_id_super_method(...) \
\
((YES == [submacro_apc_head(__VA_ARGS__) isProxy])\
?\
((id(*)(apc_msgSend_t_list(__VA_ARGS__)))objc_msgSend)   \
(\
    [(APCObject*)submacro_apc_head(__VA_ARGS__) superMessage]\
    , [(APCObject*)submacro_apc_head(__VA_ARGS__) action]   \
    , __VA_ARGS__ \
) : nil)

#define apc_msgSend_t_list(...)\
\
submacro_apc_concat(apc_t_list_ , submacro_apc_argcount(__VA_ARGS__))

#define apc_t_list_6 id,SEL,id,id,id,id
#define apc_t_list_5 id,SEL,id,id,id
#define apc_t_list_4 id,SEL,id,id,id
#define apc_t_list_3 id,SEL,id,id,id
#define apc_t_list_2 id,SEL,id,id
#define apc_t_list_1 id,SEL,id
#define apc_t_list_0 apc_t_list_1

#endif


#define APCUserEnvironmentObject(object, msg) \
\
([[APCUserEnvironment alloc] initWithObject:object message:msg action:_cmd])



/**
 The behavior of the proxy object is the same as that of the normal object.
 */
@interface APCUserEnvironment<MessageType> : NSProxy <APCUserEnvironmentSupport>
- (nonnull APCObject*)initWithObject:(nonnull NSObject*)object
                               message:(nonnull MessageType<APCUserEnvironmentMessage>)message
                                action:(nonnull SEL)action;
- (nullable MessageType)superMessage;

- (nonnull SEL)action;

/**
 Overwrite <NSObject>.
 Returns the object that actually responds to the message
 */
- (nonnull id)self;

- (void)performVoidWithObject:(nullable id)object;
- (void)performVoidWithObject:(nullable id)object withObject:(nullable id)object2;
- (BOOL)performBOOLWithObject:(nullable id)object withObject:(nullable id)object2;
@end


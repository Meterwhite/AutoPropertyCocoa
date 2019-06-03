//
//  APCUserEnvironmentSupportObject.h
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/30.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+APCExtension.h"
#import <objc/message.h>
#import "APCScope.h"

@class APCUserEnvironmentSupportObject;

@protocol APCUserEnvironmentMessage <NSObject>
- (nullable id<APCUserEnvironmentMessage>)superEnvironmentMessage;
@end

/**
 
 This type identifies an object that is a type that supports APCUserEnvironment, and can call the superior method using APCSuperPerformedXXX. The original type should be obtained using + apc_originalClass. The type relationship should be judged using - apc_isKindOfClass:. Other behaviors of the subject are the same as usual.
 
 -----------------------------
 
 ///(Person <- Man)
 [person apc_lazyLoadForProperty:key  usingBlock:^id _Nullable(id_apc_t instance) {
 
     ...work in person
 }];
 
 [man apc_lazyLoadForProperty:key  usingBlock:^id _Nullable(id_apc_t instance) {
 
    if([instance apc_isKindOfClass:[SomeType class]]){
 
        [instance yourMethod];
    }
    return APCSuperPerformedAsId(instance);///...work in person
 }];
 
 -----------------------------
 
 Key work of APCSuper
 :
 APCSuperPerformedAsVoid(instance, ...)
 APCSuperPerformedAsBOOL(instance, ...)
 APCSuperPerformedAsId(instance, ...)
 
 The number of parameters and the order are exactly the same as the block
 */
typedef id id_apc_t;

#ifdef DEBUG

#define APCSuperPerformedAsVoid(...) \
submacro_apc_concat(apc_debug_super_method_void, submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)

#define APCSuperPerformedAsBOOL(...) \
submacro_apc_concat(apc_debug_super_method_BOOL, submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)

#define APCSuperPerformedAsId(...) \
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

OBJC_EXPORT void
apc_debug_super_method_void1(id_apc_t _Nonnull instance);

OBJC_EXPORT void
apc_debug_super_method_void2(id_apc_t _Nonnull instance, id _Nullable object);

OBJC_EXPORT BOOL
apc_debug_super_method_BOOL2(id_apc_t _Nonnull instance, id _Nullable object);

OBJC_EXPORT id _Nullable
apc_debug_super_method_id1(id_apc_t _Nonnull instance);

#else

#define APCSuperPerformedAsVoid(instance, ...) \
\
if([(id)instance isProxy]){         \
\
((void(*)(submacro_apc_msgSend_t_list(__VA_ARGS__)))objc_msgSend)\
    (                                                   \
        [(APCUserEnvironmentSupportObject*)instance apc_superEnvironmentMessage]             \
        , [(APCUserEnvironmentSupportObject*)instance apc_environmentAction]                 \
        , [(APCUserEnvironmentSupportObject*)instance self]                   \
        , ##__VA_ARGS__                                 \
    );\
}

#define APCSuperPerformedAsBOOL(instance, ...) \
\
(([(id)instance isProxy])\
?                               \
((BOOL(*)(submacro_apc_msgSend_t_list(__VA_ARGS__)))objc_msgSend)\
(                                                       \
    [(APCUserEnvironmentSupportObject*)instance apc_superEnvironmentMessage]                 \
    , [(APCUserEnvironmentSupportObject*)instance apc_environmentAction]                     \
    , [(APCUserEnvironmentSupportObject*)instance self]                       \
    , ##__VA_ARGS__                                     \
) : NO)

#define APCSuperPerformedAsId(instance, ...) \
\
(([(APCUserEnvironmentSupportObject*)instance isProxy])  \
?                                                   \
((id(*)(submacro_apc_msgSend_t_list(__VA_ARGS__)))objc_msgSend)  \
(                                                       \
    [(APCUserEnvironmentSupportObject*)instance apc_superEnvironmentMessage]                 \
    , [(APCUserEnvironmentSupportObject*)instance apc_environmentAction]                     \
    , [(APCUserEnvironmentSupportObject*)instance self]                       \
    , ##__VA_ARGS__                                     \
) : nil)

#define submacro_apc_msgSend_t_list(...)\
\
submacro_apc_concat(submacro_apc_t_list_ , submacro_apc_argcount(__VA_ARGS__))

#define submacro_apc_t_list_6 id,SEL,id,id,id,id
#define submacro_apc_t_list_5 id,SEL,id,id,id
#define submacro_apc_t_list_4 id,SEL,id,id,id
#define submacro_apc_t_list_3 id,SEL,id,id,id
#define submacro_apc_t_list_2 id,SEL,id,id
#define submacro_apc_t_list_1 id,SEL,id
#define submacro_apc_t_list_0 apc_t_list_1

#endif


#define APCUserEnvironmentObject(object, msg) \
\
([[APCUserEnvironmentSupportObject alloc] initWithObject:object message:msg action:_cmd])

/**
 
 All APCUserEnvironmentSupportObject objects are marked as id_apc_t
 The behavior of the proxy object is the same as that of the normal object.
 */
@interface APCUserEnvironmentSupportObject<MessageType> : NSProxy
- (nonnull id_apc_t)initWithObject:(nonnull NSObject*)object
                           message:(nonnull MessageType<APCUserEnvironmentMessage>)message
                            action:(nonnull SEL)action;

- (nullable MessageType)apc_superEnvironmentMessage;

- (nonnull SEL)apc_environmentAction;

/**
 Overwrite protocol <NSObject>.
 Returns the object that actually responds to the objc message.
 */
- (nonnull id)self;


#pragma mark - This instance method with the same effect as APCSuper key word.
- (void)apc_performUserSuperAsVoidWithObject:(nullable id)object;
- (void)apc_performUserSuperAsVoid;
- (BOOL)apc_performUserSuperAsBOOLWithObject:(nullable id)object;
- (nullable id)apc_performUserSuperAsId;
@end


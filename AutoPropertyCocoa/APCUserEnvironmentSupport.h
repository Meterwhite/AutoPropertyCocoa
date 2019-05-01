//
//  APCUserEnvironmentSupport.h
//  AutoPropertyCocoaiOS
//
//  Created by Novo on 2019/4/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APCUserEnvironmentMessage <NSObject>
- (nullable id<APCUserEnvironmentMessage>)superObject;
@end

@protocol APCUserEnvironmentSupport
- (nullable id)performSuperMessage_id;
- (void)performSuperMessage_void;
- (BOOL)performSuperMessage_BOOL;
@end

/**
 (result , enviroment , userHook)
 supermessage
 */
@interface APCUserEnvironmentSupport<MessageType> : NSProxy <APCUserEnvironmentSupport>
typedef void(^APCUserEnvironmentAction)(APCUserEnvironmentSupport<MessageType>* uObject);

@property (nullable,nonatomic,copy,readonly) APCUserEnvironmentAction superMessagePerformerForAction;
@property (nullable,nonatomic,strong) id returnedIDValue;
@property (nonatomic,assign) BOOL returnedBOOLValue;

- (nonnull instancetype)initWithObject:(nonnull NSObject*)object
                               message:(nonnull MessageType<APCUserEnvironmentMessage>)message;
- (nonnull instancetype)setSuperMessagePerformerForAction:(nonnull APCUserEnvironmentAction)action;



- (nullable MessageType)superMessage;

/**
 Overwrite <NSObject>.
 Returns the object that actually responds to the message
 */
- (nonnull id)self;

- (void)performSuperMessage_void;
- (BOOL)performSuperMessage_BOOL;
- (id)performSuperMessage_id;
@end


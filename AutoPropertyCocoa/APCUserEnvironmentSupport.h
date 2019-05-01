//
//  APCUserEnvironmentSupport.h
//  AutoPropertyCocoaiOS
//
//  Created by Novo on 2019/4/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCUserEnvironmentSupport;



@protocol APCUserEnvironmentMessage <NSObject>
- (nullable id)messageForSuper;
@end

@protocol APCUserEnvironmentSupport
- (nonnull id)self;
- (nonnull id)super_perform;
@end

/**
 (result , enviroment , userHook)
 supermessage
 */
@interface APCUserEnvironmentSupport<__covariant MessageType> : NSProxy <APCUserEnvironmentSupport>

typedef void(^APCUserEnvironmentAction)(APCUserEnvironmentSupport<MessageType>* iSupport);

- (nonnull instancetype)initWithObject:(nonnull NSObject*)object
                               message:(nonnull MessageType<APCUserEnvironmentMessage>)message;

@property (nullable,nonatomic,copy,readonly) APCUserEnvironmentAction actionForPerformSuper;
- (nonnull instancetype)setActionForPerformSuper:(APCUserEnvironmentAction)actionForPerformSuper;

@property (nonatomic,assign) BOOL returned_bool;
@property (nullable,nonatomic,strong) id returned_id;

- (nonnull id)self;
- (nullable MessageType)superMessage;

- (void)performSuperMessage;
- (id)performSuperMessage_id;
- (BOOL)performSuperMessage_b;
@end


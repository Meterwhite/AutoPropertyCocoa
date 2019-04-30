//
//  APCUserEnvironmentSupport.h
//  AutoPropertyCocoaiOS
//
//  Created by Novo on 2019/4/30.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APCUserEnvironmentMessage <NSObject>

@end


/**
 (instance, message, args)
 
 result <- message -> block(↓↓↓)
 
 Get key of block
 supermessage
 */
@interface APCUserEnvironmentSupport : NSProxy

- (nonnull id)initWithInstance:(nonnull NSObject*)object;

- (void)msg:(nonnull id<APCUserEnvironmentMessage>)message;

/** block */
- (void)act:(nonnull NSString*)ivar;

- (void)value:(nonnull id)value;

- (void)returnType;


- (nonnull id)SELF;
- (nonnull id)SUPER_PERFORM;
@end


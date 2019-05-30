//
//  APCProxyInstanceResource.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/16.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCScope.h"


@interface APCProxyInstanceResource : NSObject
{
@public
    
    pthread_rwlock_t instanceLock;
}

- (nonnull instancetype)initWithClass:(nullable APCProxyClass)clazz;

@end

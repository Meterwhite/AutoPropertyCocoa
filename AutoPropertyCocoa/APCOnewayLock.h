//
//  APCOnewayLock.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/28.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCOnewayLock : NSObject

- (BOOL)visit;

- (void)open;

- (void)close;
@end

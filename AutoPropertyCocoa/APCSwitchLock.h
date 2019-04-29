//
//  APCSwitchLock.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/28.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Blocking lock.
 
 ///off : ⟳; on : ↓;
 if([APCSwitchLock* visit]){
 
    ///...
 }
 */
@interface APCSwitchLock : NSObject

- (BOOL)visit;

- (void)on;
- (void)off;

- (void)waitingOff;
- (void)waitingOn;
@end

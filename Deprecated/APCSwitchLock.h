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
 
 ///close : ⟳; open : ↓;
 if([APCSwitchLock* visit]){
 
    ///...
 }
 */
@interface APCSwitchLock : NSObject

- (BOOL)visit;

- (void)open;
- (void)close;

- (void)closing;
- (void)opening;
@end

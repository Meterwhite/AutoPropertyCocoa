//
//  NSObject+APC.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/19.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject(APCExtension) 

- (id)apc_performSelector:(SEL)aSelector;

- (id)apc_performSelector:(SEL)aSelector withObject:(id)object;
@end


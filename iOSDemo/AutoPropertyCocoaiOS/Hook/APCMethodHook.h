//
//  APCMethodHook.h
//  AutoPropertyCocoaiOS
//
//  Created by NOVO on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCScope.h"


@interface APCMethodHook : NSObject
{
@protected
    
    IMP         _new_implementation;
    IMP         _old_implementation;
}


@end


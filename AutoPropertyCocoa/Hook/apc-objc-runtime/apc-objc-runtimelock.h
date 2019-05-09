//
//  APCOBJC2Runtimelock.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/9.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>



//@interface APCOBJC2Runtimelock : NSObject
//
//@end
#import <objc/runtime.h>

#if defined __cplusplus
extern "C"
{
#endif
    
    
    
    void acp_runtimelock_lock(void(^block)(void));
    
    
    
#if defined __cplusplus
};
#endif

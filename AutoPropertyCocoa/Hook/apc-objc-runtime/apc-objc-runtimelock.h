//
//  APCOBJC2Runtimelock.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/9.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @Runtimelock({
    ...
 });
 */
#define Runtimelock(...)\
\
submacro_apc_keywordify apc_runtimelock_lock(^()__VA_ARGS__)


#if defined __cplusplus
extern "C"
{
#endif
    
    
    /**
     <#Description#>
     */
    void apc_main_hook(void);
        
    _Bool apc_contains_runtimelock(void);
    
    void apc_runtimelock_lock(void(^userblock)(void));
    
    
#if defined __cplusplus
};
#endif

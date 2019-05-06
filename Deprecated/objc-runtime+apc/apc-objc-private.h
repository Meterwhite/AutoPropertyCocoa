//
//  apc-objc-private.hpp
//  Test123123
//
//  Created by MDLK on 2019/5/5.
//  Copyright © 2019 MDLK. All rights reserved.
//

#ifndef apc_objc_private_hpp
#define apc_objc_private_hpp

#import <objc/runtime.h>


#if defined __cplusplus
extern "C" {
#endif
        
void apc_objc_removeMethod(Class cls, SEL name);

#if defined __cplusplus
};
#endif  

#endif /* apc_objc_private_hpp */

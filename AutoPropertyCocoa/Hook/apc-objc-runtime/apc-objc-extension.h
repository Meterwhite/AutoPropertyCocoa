//
//  apc-objc-private.hpp
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/5/5.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#ifndef APC_OBJC_PRIVATE
#define APC_OBJC_PRIVATE

#import <objc/runtime.h>

#if defined __cplusplus
extern "C"
{
#endif
    
    /**
     apc_main_classHookFullSupport() should be called before.
     Does not affect the super class
     The runtimelock is not locked when the function is called.
     So avoid the write behavior of other threads to the method_list of that Class when the function is called.
     */
    void class_removeMethod_APC_OBJC2(Class _Nonnull cls, SEL _Nonnull name);
    
    IMP _Nullable class_itMethodImplementation_APC(Class _Nonnull cls, SEL _Nonnull name);
    
#if defined __cplusplus
};
#endif

#endif /* APC_OBJC_PRIVATE */


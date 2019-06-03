#import "APCScope.h"

/**
 Set 0 to close log. 1 open.
 */
#define APCDebugLogSwitch 1

/**
 When debug if the following two conditions are met
 :
 1.edit scheme -> Diagnostics -> Guard Malloc -> YES
 2.apc_main_classHookFullSupport() has been called in main()
 
 You should set : 1 & DEBUG
 
 */
#define APCDebugSchemeDiagnosticsGuardMalloc 0 & DEBUG

#define  APCLazyload(obj, ...) \
\
[obj apc_lazyLoadForPropertyArray:APCPropertiesArray(obj, ##__VA_ARGS__)]

#define  APCClassLazyload(T, ...) \
do {\
\
    const T* assistantObj __attribute__((unused));\
    [T apc_lazyLoadForPropertyArray:APCPropertiesArray(assistantObj, ##__VA_ARGS__)];\
}while(0)

#define APCUnbindLazyload(obj, ...) \
\
[obj apc_unbindLazyLoadForPropertyArray:APCPropertiesArray(obj, ##__VA_ARGS__)]

#define  APCClassUnbindLazyload(T, ...) \
do {\
\
    const T* assistantObj __attribute__((unused));\
    [T apc_unbindLazyLoadForPropertyArray:APCPropertiesArray(assistantObj, ##__VA_ARGS__)];\
}while(0)

#define APCBoxSelector(sel) \
\
@((const char*)(const void*)(@selector(sel)))

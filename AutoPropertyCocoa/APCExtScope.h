#import "APCScope.h"

/**
 Set 0 to close log.
 */
#define APCDebugLogSwitch 1

/**
 If the following two conditions are met
 :
 1.edit scheme -> Diagnostics -> Guard Malloc -> YES
 2.called apc_main_classHookFullSupport() in main()
 
 You should set : 1 & DEBUG
 
 */
#define APCDebugSchemeDiagnosticsGuardMalloc 0 & DEBUG

#define  APCLazyload(obj, arg...) \
\
[obj apc_lazyLoadForPropertyArray:APCPropertiesArray(obj, ##arg)]

#define  APCClassLazyload(T, arg...) \
do {\
\
    const T* assistantObj __attribute__((unused));\
    [T apc_lazyLoadForPropertyArray:APCPropertiesArray(assistantObj, ##arg)];\
}while(0)

#define APCBoxSelector(sel) \
\
@((const char*)(const void*)(@selector(sel)))

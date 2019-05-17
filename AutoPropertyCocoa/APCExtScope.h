
/**
 Set 0 to close log infomation.
 */
#define APCDebugLogSwitch 1

/**
 If the following two conditions are met
 :
 1.edit scheme -> Diagnostics -> Guard Malloc -> YES
 2.called apc_in_main() in main()
 
 You should set : 1 & DEBUG
 
 */
#define APCDebugSchemeDiagnosticsGuardMalloc 0 & DEBUG

#define APCBoxSelector(sel) \
\
@((const char*)(const void*)(@selector(sel)))


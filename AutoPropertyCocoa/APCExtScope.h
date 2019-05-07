

#define APCBoxSelector(sel) \
\
@((const char*)(const void*)(@selector(sel)))

#define APCRealUnbindButNoRuntimelock (1 & __OBJC2__)


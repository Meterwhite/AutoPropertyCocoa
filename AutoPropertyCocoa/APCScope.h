#ifndef __APCScope__H__
#define __APCScope__H__

#import <Foundation/Foundation.h>
#import <objc/NSObject.h>
#import <objc/runtime.h>




#if TARGET_OS_IPHONE || TARGET_OS_TV || TARGET_OS_WATCH

#import <UIKit/UIKit.h>
#define APCRect             CGRect
#define APCPoint            CGPoint
#define APCSize             CGSize
#define APCEdgeinsets       UIEdgeInsets
#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>
#define APCRect             NSRect
#define APCPoint            NSPoint
#define APCSize             NSSize
#define APCEdgeinsets       NSEdgeInsets
#endif




#ifndef __STDC_NO_ATOMICS__

#import <stdatomic.h>
#define APCAtomicUInteger   _Atomic(NSUInteger)
#define APCMemoryBarrier    atomic_thread_fence(memory_order_seq_cst)
#else
#define APCAtomicUInteger NSUInteger
#define APCMemoryBarrier
#endif

#define APCThreadID ([NSThread currentThread])

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0 \
|| MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_12 \
|| __TV_OS_VERSION_MIN_REQUIRED >= __TVOS_10_0

#import <os/lock.h>
#define apc_spinlock_unlock os_unfair_lock_unlock
#define apc_spinlock_lock os_unfair_lock_lock
#define apc_spinlock_init OS_UNFAIR_LOCK_INIT
#define apc_spinlock os_unfair_lock
#else

#import <libkern/OSAtomic.h>
#define apc_spinlock_unlock OSSpinLockUnlock
#define APC_SPINLOCK_INIT OS_SPINLOCK_INIT
#define apc_spinlock_lock OSSpinLockLock
#define apc_spinlock OSSpinLock
#endif


/**
 Only one line of code completes the block call, checks, and returns the result.
 AnyType ret = APCSafeBlock(object.block, args...);
 */
#define APCSafeBlockInvok(aBlockValue, args...) \
(^(){\
    \
    typeof(aBlockValue) iblock = aBlockValue;\
    \
    return iblock ? iblock(args) : 0;\
})()


typedef NSObject        APCProxyInstance;
typedef Class           APCProxyClass;
typedef apc_spinlock    APCSpinLock;

FOUNDATION_EXPORT NSString *const APCProgramingType_ptr;
FOUNDATION_EXPORT NSString *const APCProgramingType_charptr;
FOUNDATION_EXPORT NSString *const APCProgramingType_id;
FOUNDATION_EXPORT NSString *const APCProgramingType_NSBlock;
FOUNDATION_EXPORT NSString *const APCProgramingType_SEL;
FOUNDATION_EXPORT NSString *const APCProgramingType_char;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedchar;
FOUNDATION_EXPORT NSString *const APCProgramingType_int;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedint;
FOUNDATION_EXPORT NSString *const APCProgramingType_short;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedshort;
FOUNDATION_EXPORT NSString *const APCProgramingType_long;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedlong;
FOUNDATION_EXPORT NSString *const APCProgramingType_longlong;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedlonglong;
FOUNDATION_EXPORT NSString *const APCProgramingType_float;
FOUNDATION_EXPORT NSString *const APCProgramingType_double;
FOUNDATION_EXPORT NSString *const APCProgramingType_bool;

static inline void apc_setterimp_boxinvok(id _SELF,SEL _CMD,IMP imp,const char* encode, id arg)
{
    NSCAssert(*encode != '\0', @"APC: Type encoding can not be nil.");
    
    if(encode[0] == _C_ID){
    
        ((void(*)(id,SEL,id))imp)(_SELF, _CMD, arg);
        return;
    }
    
    ///Boxed basic-value.
    if(NO == [arg isKindOfClass:[NSValue class]]){
#warning @throw
    }
    
    if(strcmp(encode, "c") == 0) {
        
#define apc_Sinvok_rbox_by(type)\
    \
        type value;\
        [arg getValue:&value];\
        ((void(*)(id,SEL,type))imp)(_SELF,_CMD,value);\
        return;

        apc_Sinvok_rbox_by(char)
    }
    else if(strcmp(encode, "i") == 0){
        apc_Sinvok_rbox_by(int)
    }
    else if(strcmp(encode, "s") == 0){
        apc_Sinvok_rbox_by(short)
    }
    else if(strcmp(encode, "l") == 0){
        apc_Sinvok_rbox_by(long)
    }
    else if(strcmp(encode, "q") == 0){
        apc_Sinvok_rbox_by(long long)
    }
    else if(strcmp(encode, "C") == 0){
        apc_Sinvok_rbox_by(unsigned char)
    }
    else if(strcmp(encode, "I") == 0){
        apc_Sinvok_rbox_by(unsigned int)
    }
    else if(strcmp(encode, "S") == 0){
        apc_Sinvok_rbox_by(unsigned short)
    }
    else if(strcmp(encode, "L") == 0){
        apc_Sinvok_rbox_by(unsigned long)
    }
    else if(strcmp(encode, "Q") == 0){
        apc_Sinvok_rbox_by(unsigned long long)
    }
    else if(strcmp(encode, "f") == 0){
        apc_Sinvok_rbox_by(float)
    }
    else if(strcmp(encode, "d") == 0){
        apc_Sinvok_rbox_by(double)
    }
    else if(strcmp(encode, "B") == 0){
        apc_Sinvok_rbox_by(bool)
    }
    else if(strcmp(encode, "*") == 0){
        apc_Sinvok_rbox_by(char *)
    }
    else if(strcmp(encode, "#") == 0){
        apc_Sinvok_rbox_by(Class)
    }
    else if(strcmp(encode, ":") == 0){
        apc_Sinvok_rbox_by(SEL)
    }
    else if(encode[0] == _C_PTR){
        apc_Sinvok_rbox_by(void*)
    }
    else if(strcmp(encode, @encode(APCRect)) == 0){
        apc_Sinvok_rbox_by(APCRect)
    }
    else if(strcmp(encode, @encode(APCPoint)) == 0){
        apc_Sinvok_rbox_by(APCPoint)
    }
    else if(strcmp(encode, @encode(APCSize)) == 0){
        apc_Sinvok_rbox_by(APCSize)
    }
    else if(strcmp(encode, @encode(APCEdgeinsets)) == 0){
        apc_Sinvok_rbox_by(APCEdgeinsets)
    }
    else if(strcmp(encode, @encode(NSRange)) == 0){
        apc_Sinvok_rbox_by(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"APC: This type is not supported.");
}


static inline id apc_getterimp_boxinvok(id _SELF,SEL _CMD,IMP imp,const char* encode)
{
    NSCAssert(*encode != '\0', @"APC: Type encoding can not be nil.");
    
    if(encode[0] == _C_ID){
        
        return ((id(*)(id,SEL))imp)(_SELF,_CMD);
    }
    
    
    if(strcmp(encode, "c") == 0){
        
#define apc_Ginvok_rbox_num_by(type,methodSuffix)\
\
type returnValue = ((type(*)(id,SEL))imp)(_SELF,_CMD);\
return [NSNumber numberWith##methodSuffix:returnValue];
        
        apc_Ginvok_rbox_num_by(char,Char)
    }
    else if(strcmp(encode, "i") == 0){
        apc_Ginvok_rbox_num_by(int,Int)
    }
    else if(strcmp(encode, "s") == 0){
        apc_Ginvok_rbox_num_by(short,Short)
    }
    else if(strcmp(encode, "l") == 0){
        apc_Ginvok_rbox_num_by(long,Long)
    }
    else if(strcmp(encode, "q") == 0){
        apc_Ginvok_rbox_num_by(long long,LongLong)
    }
    else if(strcmp(encode, "C") == 0){
        apc_Ginvok_rbox_num_by(unsigned char,UnsignedChar)
    }
    else if(strcmp(encode, "I") == 0){
        apc_Ginvok_rbox_num_by(unsigned int,UnsignedInt)
    }
    else if(strcmp(encode, "S") == 0){
        apc_Ginvok_rbox_num_by(unsigned short,UnsignedShort)
    }
    else if(strcmp(encode, "L") == 0){
        apc_Ginvok_rbox_num_by(unsigned long,UnsignedLong)
    }
    else if(strcmp(encode, "Q") == 0){
        apc_Ginvok_rbox_num_by(unsigned long long,UnsignedLongLong)
    }
    else if(strcmp(encode, "f") == 0){
        apc_Ginvok_rbox_num_by(float,Float)
    }
    else if(strcmp(encode, "d") == 0){
        apc_Ginvok_rbox_num_by(double,Double)
    }
    else if(strcmp(encode, "B") == 0){
        apc_Ginvok_rbox_num_by(bool,Bool)
    }
    else if(strcmp(encode, "*") == 0){
        
#define apc_Ginvok_rbox_value_by(type)\
\
type returnValue = ((type(*)(id,SEL))imp)(_SELF,_CMD);\
return [NSValue valueWithBytes:&returnValue objCType:encode];
        
        apc_Ginvok_rbox_value_by(char *)
    }
    else if(strcmp(encode, "#") == 0){
        apc_Ginvok_rbox_value_by(Class)
    }
    else if(strcmp(encode, ":") == 0){
        apc_Ginvok_rbox_value_by(SEL)
    }
    else if(encode[0] == _C_PTR){
        apc_Ginvok_rbox_value_by(void*)
    }
    else if(strcmp(encode, @encode(APCRect)) == 0){
        apc_Ginvok_rbox_value_by(APCRect)
    }
    else if(strcmp(encode, @encode(APCPoint)) == 0){
        apc_Ginvok_rbox_value_by(APCPoint)
    }
    else if(strcmp(encode, @encode(APCSize)) == 0){
        apc_Ginvok_rbox_value_by(APCSize)
    }
    else if(strcmp(encode, @encode(APCEdgeinsets)) == 0){
        apc_Ginvok_rbox_value_by(APCEdgeinsets)
    }
    else if(strcmp(encode, @encode(NSRange)) == 0){
        apc_Ginvok_rbox_value_by(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"APC: This type is not supported.");
    return nil;
}


#define APCTemplate_NSValue_HookOfGetter(encodename,type,funcname)\
\
type funcname##_##encodename(_Nullable id _SELF,SEL _CMD)\
{\
    NSValue* value = funcname(_SELF, _CMD);\
    \
    type ret;\
    [value getValue:&ret];\
    \
    return ret;\
}

#define APCTemplate_NSNumber_HookOfGetter(encodename,type,funcname,methodPrefix)\
\
type funcname##_##encodename(_Nullable id _SELF,SEL _CMD)\
{\
    return [((NSNumber*)funcname(_SELF, _CMD)) methodPrefix##Value];\
}


/**
 Define A : BasicValue <Funcname>_<EncodeName>(...){...}
 Define B : IMP  <Funcname>_HookIMPMapper(char* encode){...}
 */
#define APC_Define_BasicValueHookOfGetter_Define_HookIMPMapper_UsingTemplate\
(NSNumberTemplate,NSValueTemplate,funcname) \
\
NSNumberTemplate(c,char,funcname,char)\
NSNumberTemplate(i,int,funcname,int)\
NSNumberTemplate(s,short,funcname,short)\
NSNumberTemplate(l,long,funcname,long)\
NSNumberTemplate(q,long long,funcname,longLong)\
NSNumberTemplate(C,unsigned char,funcname,unsignedChar)\
NSNumberTemplate(I,unsigned int,funcname,unsignedInt)\
NSNumberTemplate(S,unsigned short,funcname,unsignedShort)\
NSNumberTemplate(L,unsigned long,funcname,unsignedLong)\
NSNumberTemplate(Q,unsigned long long,funcname,unsignedLongLong)\
NSNumberTemplate(f,float,funcname,float)\
NSNumberTemplate(d,double,funcname,double)\
NSNumberTemplate(B,BOOL,funcname,bool)\
NSValueTemplate(charptr,char*,funcname)\
NSValueTemplate(class,Class,funcname)\
NSValueTemplate(sel,SEL,funcname)\
NSValueTemplate(ptr,void*,funcname)\
NSValueTemplate(rect,APCRect,funcname)\
NSValueTemplate(point,APCPoint,funcname)\
NSValueTemplate(size,APCSize,funcname)\
NSValueTemplate(range,NSRange,funcname)\
\
void* _Nullable funcname##_HookIMPMapper(NSString* _Nonnull encodeString)\
{\
    if([encodeString isEqualToString:@"c"]){\
        return funcname##_c;\
    }\
    else if ([encodeString isEqualToString:@"i"]){\
        return funcname##_i;\
    }\
    else if ([encodeString isEqualToString:@"s"]){\
        return funcname##_s;\
    }\
    else if ([encodeString isEqualToString:@"l"]){\
        return funcname##_l;\
    }\
    else if ([encodeString isEqualToString:@"q"]){\
        return funcname##_q;\
    }\
    else if ([encodeString isEqualToString:@"C"]){\
        return funcname##_C;\
    }\
    else if ([encodeString isEqualToString:@"I"]){\
        return funcname##_I;\
    }\
    else if ([encodeString isEqualToString:@"S"]){\
        return funcname##_S;\
    }\
    else if ([encodeString isEqualToString:@"L"]){\
        return funcname##_L;\
    }\
    else if ([encodeString isEqualToString:@"Q"]){\
        return funcname##_Q;\
    }\
    else if ([encodeString isEqualToString:@"f"]){\
        return funcname##_f;\
    }\
    else if ([encodeString isEqualToString:@"d"]){\
        return funcname##_d;\
    }\
    else if ([encodeString isEqualToString:@"B"]){\
        return funcname##_B;\
    }\
    else if ([encodeString isEqualToString:@"*"]){\
        return funcname##_charptr;\
    }\
    else if ([encodeString isEqualToString:@"#"]){\
        return funcname##_class;\
    }\
    else if ([encodeString isEqualToString:@":"]){\
        return funcname##_sel;\
    }\
    else if ([encodeString characterAtIndex:0] == '^'){\
        return funcname##_ptr;\
    }\
    else if ([encodeString isEqualToString:@(@encode(APCRect))]){\
        return funcname##_rect;\
    }\
    else if ([encodeString isEqualToString:@(@encode(APCPoint))]){\
        return funcname##_point;\
    }\
    else if ([encodeString isEqualToString:@(@encode(APCSize))]){\
        return funcname##_size;\
    }\
    else if ([encodeString isEqualToString:@(@encode(NSRange))]){\
        return funcname##_range;\
    }\
    return nil;\
}
///enc-m

#define APCTemplate_NSValue_HookOfSetter(encodename,type,funcname)\
\
void funcname##_##encodename(_Nullable id _SELF,SEL _CMD,type val)\
{\
    \
    funcname(_SELF, _CMD, [NSValue valueWithBytes:&val objCType:@encode(type)]);\
}

#define APCTemplate_NSNumber_HookOfSetter(encodename,type,funcname,ftype)\
\
void funcname##_##encodename(_Nullable id _SELF,SEL _CMD,type val)\
{\
    \
    funcname(_SELF, _CMD, [NSNumber numberWith##ftype:val]);\
}

#define APC_Define_BasicValueHookOfSetter_Define_HookIMPMapper_UsingTemplate(NSNumberTemplate,NSValueTemplate,funcname) \
\
NSNumberTemplate(c,char,funcname,Char)\
NSNumberTemplate(i,int,funcname,Int)\
NSNumberTemplate(s,short,funcname,Short)\
NSNumberTemplate(l,long,funcname,Long)\
NSNumberTemplate(q,long long,funcname,LongLong)\
NSNumberTemplate(C,unsigned char,funcname,UnsignedChar)\
NSNumberTemplate(I,unsigned int,funcname,UnsignedInt)\
NSNumberTemplate(S,unsigned short,funcname,UnsignedShort)\
NSNumberTemplate(L,unsigned long,funcname,UnsignedLong)\
NSNumberTemplate(Q,unsigned long long,funcname,UnsignedLongLong)\
NSNumberTemplate(f,float,funcname,Float)\
NSNumberTemplate(d,double,funcname,Double)\
NSNumberTemplate(B,BOOL,funcname,Bool)\
NSValueTemplate(charptr,char*,funcname)\
NSValueTemplate(class,Class,funcname)\
NSValueTemplate(sel,SEL,funcname)\
NSValueTemplate(ptr,void*,funcname)\
NSValueTemplate(rect,APCRect,funcname)\
NSValueTemplate(point,APCPoint,funcname)\
NSValueTemplate(size,APCSize,funcname)\
NSValueTemplate(range,NSRange,funcname)\
\
void* _Nullable funcname##_HookIMPMapper(NSString* _Nonnull encodeString)\
{\
    if([encodeString isEqualToString:@"c"]){\
    return funcname##_c;\
}\
else if ([encodeString isEqualToString:@"i"]){\
    return funcname##_i;\
}\
else if ([encodeString isEqualToString:@"s"]){\
    return funcname##_s;\
}\
else if ([encodeString isEqualToString:@"l"]){\
    return funcname##_l;\
}\
else if ([encodeString isEqualToString:@"q"]){\
    return funcname##_q;\
}\
else if ([encodeString isEqualToString:@"C"]){\
    return funcname##_C;\
}\
else if ([encodeString isEqualToString:@"I"]){\
    return funcname##_I;\
}\
else if ([encodeString isEqualToString:@"S"]){\
    return funcname##_S;\
}\
else if ([encodeString isEqualToString:@"L"]){\
    return funcname##_L;\
}\
else if ([encodeString isEqualToString:@"Q"]){\
    return funcname##_Q;\
}\
else if ([encodeString isEqualToString:@"f"]){\
    return funcname##_f;\
}\
else if ([encodeString isEqualToString:@"d"]){\
    return funcname##_d;\
}\
else if ([encodeString isEqualToString:@"B"]){\
    return funcname##_B;\
}\
else if ([encodeString isEqualToString:@"*"]){\
    return funcname##_charptr;\
}\
else if ([encodeString isEqualToString:@"#"]){\
    return funcname##_class;\
}\
else if ([encodeString isEqualToString:@":"]){\
    return funcname##_sel;\
}\
else if ([encodeString characterAtIndex:0] == '^'){\
    return funcname##_ptr;\
}\
else if ([encodeString isEqualToString:@(@encode(APCRect))]){\
    return funcname##_rect;\
}\
else if ([encodeString isEqualToString:@(@encode(APCPoint))]){\
    return funcname##_point;\
}\
else if ([encodeString isEqualToString:@(@encode(APCSize))]){\
    return funcname##_size;\
}\
else if ([encodeString isEqualToString:@(@encode(NSRange))]){\
    return funcname##_range;\
}\
return nil;\
}
///enc-m


#pragma mark - Fast

#define APCPropertiesArray(...)\
@[APCProperties(__VA_ARGS__)]

#define APCProperties(...)\
submacro_apc_concat(submacro_apc_plist_,submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)


#pragma mark - submacros


#define submacro_apc_plist_2(OBJ, P1)\
((void)(NO && ((void)OBJ.P1, NO)), @# P1)

#define submacro_apc_plist_3(OBJ, P1, P2)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO)), (@# P2, @# P1))

#define submacro_apc_plist_4(OBJ, P1, P2, P3)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO)), (@# P3, @# P2, @ #P1))

#define submacro_apc_plist_5(OBJ, P1, P2, P3, P4)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO)), (@# P4, @# P3, @ #P2, @ #P1))

#define submacro_apc_plist_6(OBJ, P1, P2, P3, P4, P5)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO)), (@# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_7(OBJ, P1, P2, P3, P4, P5, P6)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)), (@# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_8(OBJ, P1, P2, P3, P4, P5, P6, P7)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO)), (@# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_9(OBJ, P1, P2, P3, P4, P5, P6, P7, P8)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO)), (@# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_10(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO)), (@# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_11(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO)), (@# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_12(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO)), (@# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_13(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO)), (@# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_14(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO)), (@# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_15(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO)), (@# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_16(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO)), (@# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_17(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO)), (@# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_18(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO)), (@# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_19(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17, P18)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO) && ((void)OBJ.P18, NO)), (@# P18, @# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_20(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17, P18, P19)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO) && ((void)OBJ.P18, NO) && ((void)OBJ.P19, NO)), (@# P19, @# P18, @# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_plist_21(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17, P18, P19, P20)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO) && ((void)OBJ.P18, NO) && ((void)OBJ.P19, NO) && ((void)OBJ.P20, NO)), (@# P20, @# P19, @# P18, @# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1))

#define submacro_apc_concat_(A, B) A ## B

#define submacro_apc_concat(A, B) \
submacro_apc_concat_(A, B)

#define submacro_apc_at(N, ...) \
submacro_apc_concat(submacro_apc_at, N)(__VA_ARGS__)

#define submacro_apc_argcount(...) \
submacro_apc_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

#define submacro_apc_if_eq(A, B) \
submacro_apc_concat(submacro_apc_if_eq, A)(B)

#define submacro_apc_head_(FIRST, ...) FIRST

#define submacro_apc_head(...) \
submacro_apc_head_(__VA_ARGS__, 0)

// submacro_apc_at expansions
#define submacro_apc_at0(...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at1(_0, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at2(_0, _1, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at3(_0, _1, _2, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at4(_0, _1, _2, _3, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at5(_0, _1, _2, _3, _4, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at6(_0, _1, _2, _3, _4, _5, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at7(_0, _1, _2, _3, _4, _5, _6, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) submacro_apc_head(__VA_ARGS__)
#define submacro_apc_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) submacro_apc_head(__VA_ARGS__)


#define submacro_apc_consume_(...)

#define submacro_apc_expand_(...) __VA_ARGS__

#define submacro_apc_dec(VAL) \
submacro_apc_at(VAL, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)

// ak_if_eq expansions
#define submacro_apc_if_eq0(VALUE) \
submacro_apc_concat(submacro_apc_if_eq0_, VALUE)

#define submacro_apc_if_eq0_0(...) __VA_ARGS__ submacro_apc_consume_
#define submacro_apc_if_eq0_1(...) submacro_apc_expand_
#define submacro_apc_if_eq0_2(...) submacro_apc_expand_
#define submacro_apc_if_eq0_3(...) submacro_apc_expand_
#define submacro_apc_if_eq0_4(...) submacro_apc_expand_
#define submacro_apc_if_eq0_5(...) submacro_apc_expand_
#define submacro_apc_if_eq0_6(...) submacro_apc_expand_
#define submacro_apc_if_eq0_7(...) submacro_apc_expand_
#define submacro_apc_if_eq0_8(...) submacro_apc_expand_
#define submacro_apc_if_eq0_9(...) submacro_apc_expand_
#define submacro_apc_if_eq0_10(...) submacro_apc_expand_
#define submacro_apc_if_eq0_11(...) submacro_apc_expand_
#define submacro_apc_if_eq0_12(...) submacro_apc_expand_
#define submacro_apc_if_eq0_13(...) submacro_apc_expand_
#define submacro_apc_if_eq0_14(...) submacro_apc_expand_
#define submacro_apc_if_eq0_15(...) submacro_apc_expand_
#define submacro_apc_if_eq0_16(...) submacro_apc_expand_
#define submacro_apc_if_eq0_17(...) submacro_apc_expand_
#define submacro_apc_if_eq0_18(...) submacro_apc_expand_
#define submacro_apc_if_eq0_19(...) submacro_apc_expand_
#define submacro_apc_if_eq0_20(...) submacro_apc_expand_

#define submacro_apc_if_eq1(VALUE) submacro_apc_if_eq0(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq2(VALUE) submacro_apc_if_eq1(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq3(VALUE) submacro_apc_if_eq2(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq4(VALUE) submacro_apc_if_eq3(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq5(VALUE) submacro_apc_if_eq4(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq6(VALUE) submacro_apc_if_eq5(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq7(VALUE) submacro_apc_if_eq6(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq8(VALUE) submacro_apc_if_eq7(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq9(VALUE) submacro_apc_if_eq8(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq10(VALUE) submacro_apc_if_eq9(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq11(VALUE) submacro_apc_if_eq10(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq12(VALUE) submacro_apc_if_eq11(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq13(VALUE) submacro_apc_if_eq12(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq14(VALUE) submacro_apc_if_eq13(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq15(VALUE) submacro_apc_if_eq14(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq16(VALUE) submacro_apc_if_eq15(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq17(VALUE) submacro_apc_if_eq16(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq18(VALUE) submacro_apc_if_eq17(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq19(VALUE) submacro_apc_if_eq18(submacro_apc_dec(VALUE))
#define submacro_apc_if_eq20(VALUE) submacro_apc_if_eq19(submacro_apc_dec(VALUE))
#endif


/**

 #define APC_Define_BasicValueHookOfGetter_Define_HookIMPMapper(funcname)\
 \
 APCTemplate_NSNumber_HookOfGetter(c,char,funcname,char)\
 APCTemplate_NSNumber_HookOfGetter(i,int,funcname,int)\
 APCTemplate_NSNumber_HookOfGetter(s,short,funcname,short)\
 APCTemplate_NSNumber_HookOfGetter(l,long,funcname,long)\
 APCTemplate_NSNumber_HookOfGetter(q,long long,funcname,longLong)\
 APCTemplate_NSNumber_HookOfGetter(C,unsigned char,funcname,unsignedChar)\
 APCTemplate_NSNumber_HookOfGetter(I,unsigned int,funcname,unsignedInt)\
 APCTemplate_NSNumber_HookOfGetter(S,unsigned short,funcname,unsignedShort)\
 APCTemplate_NSNumber_HookOfGetter(L,unsigned long,funcname,unsignedLong)\
 APCTemplate_NSNumber_HookOfGetter(Q,unsigned long long,funcname,unsignedLongLong)\
 APCTemplate_NSNumber_HookOfGetter(f,float,funcname,float)\
 APCTemplate_NSNumber_HookOfGetter(d,double,funcname,double)\
 APCTemplate_NSNumber_HookOfGetter(B,BOOL,funcname,bool)\
 APCTemplate_NSValue_HookOfGetter(charptr,char*,funcname)\
 APCTemplate_NSValue_HookOfGetter(class,Class,funcname)\
 APCTemplate_NSValue_HookOfGetter(sel,SEL,funcname)\
 APCTemplate_NSValue_HookOfGetter(ptr,void*,funcname)\
 APCTemplate_NSValue_HookOfGetter(rect,APCRect,funcname)\
 APCTemplate_NSValue_HookOfGetter(point,APCPoint,funcname)\
 APCTemplate_NSValue_HookOfGetter(size,APCSize,funcname)\
 APCTemplate_NSValue_HookOfGetter(range,NSRange,funcname)\
 \
 void* _Nullable funcname##_HookIMPMapper(NSString* _Nonnull encodeString)\
 {\
 if([encodeString isEqualToString:@"c"]){\
 return funcname##_c;\
 }\
 else if ([encodeString isEqualToString:@"i"]){\
 return funcname##_i;\
 }\
 else if ([encodeString isEqualToString:@"s"]){\
 return funcname##_s;\
 }\
 else if ([encodeString isEqualToString:@"l"]){\
 return funcname##_l;\
 }\
 else if ([encodeString isEqualToString:@"q"]){\
 return funcname##_q;\
 }\
 else if ([encodeString isEqualToString:@"C"]){\
 return funcname##_C;\
 }\
 else if ([encodeString isEqualToString:@"I"]){\
 return funcname##_I;\
 }\
 else if ([encodeString isEqualToString:@"S"]){\
 return funcname##_S;\
 }\
 else if ([encodeString isEqualToString:@"L"]){\
 return funcname##_L;\
 }\
 else if ([encodeString isEqualToString:@"Q"]){\
 return funcname##_Q;\
 }\
 else if ([encodeString isEqualToString:@"f"]){\
 return funcname##_f;\
 }\
 else if ([encodeString isEqualToString:@"d"]){\
 return funcname##_d;\
 }\
 else if ([encodeString isEqualToString:@"B"]){\
 return funcname##_B;\
 }\
 else if ([encodeString isEqualToString:@"*"]){\
 return funcname##_charptr;\
 }\
 else if ([encodeString isEqualToString:@"#"]){\
 return funcname##_class;\
 }\
 else if ([encodeString isEqualToString:@":"]){\
 return funcname##_sel;\
 }\
 else if ([encodeString characterAtIndex:0] == '^'){\
 return funcname##_ptr;\
 }\
 else if ([encodeString isEqualToString:@(@encode(APCRect))]){\
 return funcname##_rect;\
 }\
 else if ([encodeString isEqualToString:@(@encode(APCPoint))]){\
 return funcname##_point;\
 }\
 else if ([encodeString isEqualToString:@(@encode(APCSize))]){\
 return funcname##_size;\
 }\
 else if ([encodeString isEqualToString:@(@encode(NSRange))]){\
 return funcname##_range;\
 }\
 return nil;\
 }
 ///enc-m

 */


/**


 #define APC_Define_BasicValueHookOfSetter_Define_HookIMPMapper(funcname)\
 \
 APCTemplate_NSNumber_HookOfSetter(c,char,funcname,Char)\
 APCTemplate_NSNumber_HookOfSetter(i,int,funcname,Int)\
 APCTemplate_NSNumber_HookOfSetter(s,short,funcname,Short)\
 APCTemplate_NSNumber_HookOfSetter(l,long,funcname,Long)\
 APCTemplate_NSNumber_HookOfSetter(q,long long,funcname,LongLong)\
 APCTemplate_NSNumber_HookOfSetter(C,unsigned char,funcname,UnsignedChar)\
 APCTemplate_NSNumber_HookOfSetter(I,unsigned int,funcname,UnsignedInt)\
 APCTemplate_NSNumber_HookOfSetter(S,unsigned short,funcname,UnsignedShort)\
 APCTemplate_NSNumber_HookOfSetter(L,unsigned long,funcname,UnsignedLong)\
 APCTemplate_NSNumber_HookOfSetter(Q,unsigned long long,funcname,UnsignedLongLong)\
 APCTemplate_NSNumber_HookOfSetter(f,float,funcname,Float)\
 APCTemplate_NSNumber_HookOfSetter(d,double,funcname,Double)\
 APCTemplate_NSNumber_HookOfSetter(B,BOOL,funcname,Bool)\
 APCTemplate_NSValue_HookOfSetter(charptr,char*,funcname)\
 APCTemplate_NSValue_HookOfSetter(class,Class,funcname)\
 APCTemplate_NSValue_HookOfSetter(sel,SEL,funcname)\
 APCTemplate_NSValue_HookOfSetter(ptr,void*,funcname)\
 APCTemplate_NSValue_HookOfSetter(rect,APCRect,funcname)\
 APCTemplate_NSValue_HookOfSetter(point,APCPoint,funcname)\
 APCTemplate_NSValue_HookOfSetter(size,APCSize,funcname)\
 APCTemplate_NSValue_HookOfSetter(range,NSRange,funcname)\
 \
 void* _Nullable funcname##_HookIMPMapper(NSString* _Nonnull encodeString)\
 {\
 if([encodeString isEqualToString:@"c"]){\
 return funcname##_c;\
 }\
 else if ([encodeString isEqualToString:@"i"]){\
 return funcname##_i;\
 }\
 else if ([encodeString isEqualToString:@"s"]){\
 return funcname##_s;\
 }\
 else if ([encodeString isEqualToString:@"l"]){\
 return funcname##_l;\
 }\
 else if ([encodeString isEqualToString:@"q"]){\
 return funcname##_q;\
 }\
 else if ([encodeString isEqualToString:@"C"]){\
 return funcname##_C;\
 }\
 else if ([encodeString isEqualToString:@"I"]){\
 return funcname##_I;\
 }\
 else if ([encodeString isEqualToString:@"S"]){\
 return funcname##_S;\
 }\
 else if ([encodeString isEqualToString:@"L"]){\
 return funcname##_L;\
 }\
 else if ([encodeString isEqualToString:@"Q"]){\
 return funcname##_Q;\
 }\
 else if ([encodeString isEqualToString:@"f"]){\
 return funcname##_f;\
 }\
 else if ([encodeString isEqualToString:@"d"]){\
 return funcname##_d;\
 }\
 else if ([encodeString isEqualToString:@"B"]){\
 return funcname##_B;\
 }\
 else if ([encodeString isEqualToString:@"*"]){\
 return funcname##_charptr;\
 }\
 else if ([encodeString isEqualToString:@"#"]){\
 return funcname##_class;\
 }\
 else if ([encodeString isEqualToString:@":"]){\
 return funcname##_sel;\
 }\
 else if ([encodeString characterAtIndex:0] == '^'){\
 return funcname##_ptr;\
 }\
 else if ([encodeString isEqualToString:@(@encode(APCRect))]){\
 return funcname##_rect;\
 }\
 else if ([encodeString isEqualToString:@(@encode(APCPoint))]){\
 return funcname##_point;\
 }\
 else if ([encodeString isEqualToString:@(@encode(APCSize))]){\
 return funcname##_size;\
 }\
 else if ([encodeString isEqualToString:@(@encode(NSRange))]){\
 return funcname##_range;\
 }\
 return nil;\
 }
 ///enc-m

 */

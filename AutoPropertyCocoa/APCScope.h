#ifndef __APCScope__H__
#define __APCScope__H__

#import "APCBasicValueVersionScope.h"
#import <Foundation/Foundation.h>
#import "apc-objc-runtimelock.h"
#import "APCTypeEncodings.h"
#import <objc/NSObject.h>
#import <objc/runtime.h>
#import "APCExtScope.h"


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
typedef _Atomic(NSUInteger) APCAtomicUInteger;
typedef _Atomic(void*)      APCAtomicPtr;
typedef _Atomic(IMP)        APCAtomicIMP;
#define APCMemoryBarrier    atomic_thread_fence(memory_order_seq_cst)
#else
typedef NSUInteger          APCAtomicUInteger
typedef void*               APCAtomicPtr
typedef _Atomic(IMP)        IMP;
#define APCMemoryBarrier
#endif

#define APCThreadID ([NSThread currentThread])

#if DEBUG & APCDebugLogSwitch
#define APCDlog(...) NSLog(__VA_ARGS__)
#else
#define APCDlog(...)
#endif

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
FOUNDATION_EXPORT NSString *const APCProgramingType_Bool;

FOUNDATION_EXPORT char *const APCDeallocMethodEncoding;
FOUNDATION_EXPORT char *const APCGetterMethodEncoding;
FOUNDATION_EXPORT char *const APCSetterMethodEncoding;

static inline void APCBoxedInvokeBasicValueSetterIMP(id _SELF,SEL _CMD,IMP imp,const char* enc, id arg)
{
    NSCAssert(*enc != '\0', @"APC: Type encoding can not be nil.");
    
    unsigned long encode = APCCoderValue(enc);
    if(APCCoderEqualMask(encode, APCObjectCoderValue)){
    
        ((void(*)(id,SEL,id))imp)(_SELF, _CMD, arg);
        return;
    }
    
    ///Boxed basic-value.
    NSCAssert([arg isKindOfClass:[NSValue class]]
              , @"APC: Unexpected type!");
    
    
    if_APCCoderCompare(encode, APCCharCoderValue) {
        
#define APCSubTemplate_InBoxedSetter_CaseType(type)\
    \
        type value;\
        [arg getValue:&value];\
        ((void(*)(id,SEL,type))imp)(_SELF,_CMD,value);\
        return;

        APCSubTemplate_InBoxedSetter_CaseType(char)
    }
    else if_APCCoderCompare(encode, APCIntCoderValue) {
        APCSubTemplate_InBoxedSetter_CaseType(int)
    }
    else if_APCCoderCompare(encode, APCShortCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(short)
    }
    else if_APCCoderCompare(encode, APCLonglCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(long)
    }
    else if_APCCoderCompare(encode, APCLongLongCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(long long)
    }
    else if_APCCoderCompare(encode, APCUCharCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(unsigned char)
    }
    else if_APCCoderCompare(encode,APCUIntCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(unsigned int)
    }
    else if_APCCoderCompare(encode,APCUShortCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(unsigned short)
    }
    else if_APCCoderCompare(encode,APCULongLongCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(unsigned long)
    }
    else if_APCCoderCompare(encode,APCULongLongCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(unsigned long long)
    }
    else if_APCCoderCompare(encode,APCFloatCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(float)
    }
    else if_APCCoderCompare(encode,APCDoubleCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(double)
    }
    else if_APCCoderCompare(encode,APC_BoolCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(bool)
    }
    else if_APCCoderCompare(encode,APCCharPtrCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(char *)
    }
    else if_APCCoderCompare(encode,APCClassCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(Class)
    }
    else if_APCCoderCompare(encode,APCSELCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(SEL)
    }
    else if(APCCoderEqualMask(encode, APCPtrCoderMaskValue)){
        APCSubTemplate_InBoxedSetter_CaseType(void*)
    }
    else if_APCCoderCompare(encode,APCRectCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(APCRect)
    }
    else if_APCCoderCompare(encode,APCPointCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(APCPoint)
    }
    else if_APCCoderCompare(encode,APCSizeCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(APCSize)
    }
    else if_APCCoderCompare(encode,APCEdgeInsetsCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(APCEdgeinsets)
    }
    else if_APCCoderCompare(encode,APCRangeCoderValue){
        APCSubTemplate_InBoxedSetter_CaseType(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"APC: This type is not supported.");
}


static inline id APCBoxedInvokeBasicValueGetterIMP(id _SELF,SEL _CMD,IMP imp,const char* enc)
{
    NSCAssert(*enc != '\0', @"APC: Type encoding can not be nil.");
    
    unsigned long encode = APCCoderValue(enc);
    if(APCCoderEqualMask(encode, APCObjectCoderValue)){
        
        return ((id(*)(id,SEL))imp)(_SELF,_CMD);
    }
    
    if_APCCoderCompare(encode,APCCharCoderValue){
        
        #define apc_Ginvok_rbox_num_by(type,methodSuffix)\
        \
        type returnValue = ((type(*)(id,SEL))imp)(_SELF,_CMD);\
        \
        return [NSNumber numberWith##methodSuffix:returnValue];
        
        apc_Ginvok_rbox_num_by(char,Char)
    }
    else if_APCCoderCompare(encode,APCIntCoderValue){
        apc_Ginvok_rbox_num_by(int,Int)
    }
    else if_APCCoderCompare(encode,APCShortCoderValue){
        apc_Ginvok_rbox_num_by(short,Short)
    }
    else if_APCCoderCompare(encode,APCLonglCoderValue){
        apc_Ginvok_rbox_num_by(long,Long)
    }
    else if_APCCoderCompare(encode,APCLongLongCoderValue){
        apc_Ginvok_rbox_num_by(long long,LongLong)
    }
    else if_APCCoderCompare(encode,APCUCharCoderValue){
        apc_Ginvok_rbox_num_by(unsigned char,UnsignedChar)
    }
    else if_APCCoderCompare(encode,APCUIntCoderValue){
        apc_Ginvok_rbox_num_by(unsigned int,UnsignedInt)
    }
    else if_APCCoderCompare(encode,APCUShortCoderValue){
        apc_Ginvok_rbox_num_by(unsigned short,UnsignedShort)
    }
    else if_APCCoderCompare(encode,APCULongCoderValue){
        apc_Ginvok_rbox_num_by(unsigned long,UnsignedLong)
    }
    else if_APCCoderCompare(encode,APCULongLongCoderValue){
        apc_Ginvok_rbox_num_by(unsigned long long,UnsignedLongLong)
    }
    else if_APCCoderCompare(encode,APCFloatCoderValue){
        apc_Ginvok_rbox_num_by(float,Float)
    }
    else if_APCCoderCompare(encode,APCDoubleCoderValue){
        apc_Ginvok_rbox_num_by(double,Double)
    }
    else if_APCCoderCompare(encode,APC_BoolCoderValue){
        apc_Ginvok_rbox_num_by(_Bool,Bool)
    }
    else if_APCCoderCompare(encode,APCCharPtrCoderValue){
        
#define apc_Ginvok_rbox_value_by(type)\
\
type returnValue = ((type(*)(id,SEL))imp)(_SELF,_CMD);\
return [NSValue valueWithBytes:&returnValue objCType:enc];
        
        apc_Ginvok_rbox_value_by(char *)
    }
    else if_APCCoderCompare(encode,APCClassCoderValue){
        apc_Ginvok_rbox_value_by(Class)
    }
    else if_APCCoderCompare(encode,APCSELCoderValue){
        apc_Ginvok_rbox_value_by(SEL)
    }
    else if(APCCoderEqualMask(encode, APCPtrCoderMaskValue)){
        apc_Ginvok_rbox_value_by(void*)
    }
    else if_APCCoderCompare(encode,APCRectCoderValue){
        apc_Ginvok_rbox_value_by(APCRect)
    }
    else if_APCCoderCompare(encode,APCPointCoderValue){
        apc_Ginvok_rbox_value_by(APCPoint)
    }
    else if_APCCoderCompare(encode,APCSizeCoderValue){
        apc_Ginvok_rbox_value_by(APCSize)
    }
    else if_APCCoderCompare(encode,APCEdgeInsetsCoderValue){
        apc_Ginvok_rbox_value_by(APCEdgeinsets)
    }
    else if_APCCoderCompare(encode,APCRangeCoderValue){
        apc_Ginvok_rbox_value_by(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"APC: This type is not supported.");
    return nil;
}


#pragma mark - Fast

#define APCPropertiesArray(...)\
\
submacro_apc_concat(submacro_apc_plist_,submacro_apc_argcount(__VA_ARGS__))(__VA_ARGS__)


#pragma mark - submacros

#if DEBUG
#define submacro_apc_keywordify                 autoreleasepool {}
#define submacro_apc_keywordify_inner(...)      autoreleasepool {__VA_ARGS__}
#else
#define submacro_apc_keywordify                 try {} @catch (...) {}
#endif


#define submacro_apc_plist_2(OBJ, P1)\
((void)(NO && ((void)OBJ.P1, NO)), @[@# P1])

#define submacro_apc_plist_3(OBJ, P1, P2)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO)), @[@# P2, @# P1])

#define submacro_apc_plist_4(OBJ, P1, P2, P3)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO)), @[@# P3, @# P2, @ #P1])

#define submacro_apc_plist_5(OBJ, P1, P2, P3, P4)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO)), @[@# P4, @# P3, @ #P2, @ #P1])

#define submacro_apc_plist_6(OBJ, P1, P2, P3, P4, P5)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO)), @[@# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_7(OBJ, P1, P2, P3, P4, P5, P6)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)), @[@# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_8(OBJ, P1, P2, P3, P4, P5, P6, P7)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO)), @[@# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_9(OBJ, P1, P2, P3, P4, P5, P6, P7, P8)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO)), @[@# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_10(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO)), @[@# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_11(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO)), @[@# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_12(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO)), @[@# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_13(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO)), @[@# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_14(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO)), @[@# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_15(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO)), @[@# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_16(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO)), @[@# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_17(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO)), @[@# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_18(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO)), @[@# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_19(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17, P18)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO) && ((void)OBJ.P18, NO)), @[@# P18, @# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_20(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17, P18, P19)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO) && ((void)OBJ.P18, NO) && ((void)OBJ.P19, NO)), @[@# P19, @# P18, @# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

#define submacro_apc_plist_21(OBJ, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14, P15, P16, P17, P18, P19, P20)\
((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO) && ((void)OBJ.P4, NO) && ((void)OBJ.P5, NO) && ((void)OBJ.P6, NO)) && ((void)OBJ.P7, NO) && ((void)OBJ.P8, NO) && ((void)OBJ.P9, NO) && ((void)OBJ.P10, NO) && ((void)OBJ.P11, NO) && ((void)OBJ.P12, NO) && ((void)OBJ.P13, NO) && ((void)OBJ.P14, NO) && ((void)OBJ.P15, NO) && ((void)OBJ.P16, NO) && ((void)OBJ.P17, NO) && ((void)OBJ.P18, NO) && ((void)OBJ.P19, NO) && ((void)OBJ.P20, NO)), @[@# P20, @# P19, @# P18, @# P17, @# P16, @# P15, @# P14, @# P13, @# P12, @# P11, @# P10, @# P9, @# P8, @# P7, @# P6, @# P5, @# P4, @ #P3, @ #P2, @ #P1])

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

#define submacro_apc_default_numbervalue        0
#define submacro_apc_default_structvalue        {0}
#define submacro_apc_defualt_value_c            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_i            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_s            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_l            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_q            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_C            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_I            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_S            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_L            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_Q            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_f            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_d            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_B            submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_charptr      submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_class        submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_sel          submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_ptr          submacro_apc_default_numbervalue
#define submacro_apc_defualt_value_rect         submacro_apc_default_structvalue
#define submacro_apc_defualt_value_point        submacro_apc_default_structvalue
#define submacro_apc_defualt_value_size         submacro_apc_default_structvalue
#define submacro_apc_defualt_value_range        submacro_apc_default_structvalue

#define submacro_apc_defaultvalue(Type,Encodename) \
\
((Type)submacro_apc_defualt_value_##Encodename)

#endif

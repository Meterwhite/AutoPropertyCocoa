#ifndef __APCScope__H__
#define __APCScope__H__

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if TARGET_OS_IPHONE || TARGET_OS_TV

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

#ifdef __STDC_NO_ATOMICS__
#import <libkern/OSAtomic.h>
#define APCAtomicUInteger   NSUInteger
#define APCMemoryBarrier    OSMemoryBarrier()
#else

#import <stdatomic.h>
#define APCAtomicUInteger   _Atomic(NSUInteger)
#define APCMemoryBarrier    atomic_thread_fence(memory_order_seq_cst)
#endif

#define APCThreadID ([NSThread currentThread])

typedef Class       APCProxyClass;
typedef NSObject    APCProxyInstance;

FOUNDATION_EXPORT NSString *const APCProgramingType_point;
FOUNDATION_EXPORT NSString *const APCProgramingType_chars;
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

static inline void apc_setterimp_boxinvok(id _SELF,SEL _CMD,IMP imp,const char* enc, id arg)
{
    NSCAssert(*enc != '\0', @"APC: Type encoding can not be nil.");
    
    if(enc[0] == _C_ID){
    
        ((void(*)(id,SEL,id))imp)(_SELF,_CMD,arg);
        return;
    }
    
    ///Boxed basic-value.
    if(NO == [arg isKindOfClass:[NSValue class]]){
        
        ///@throw
    }
    
    if(strcmp(enc, "c") == 0){
        
#define apc_invokS_rbox_by(type)\
    \
type value;\
[arg getValue:&value];\
((void(*)(id,SEL,type))imp)(_SELF,_CMD,value);\
return;

        apc_invokS_rbox_by(int)
    }
    else if(strcmp(enc, "i") == 0){
        apc_invokS_rbox_by(int)
    }
    else if(strcmp(enc, "s") == 0){
        apc_invokS_rbox_by(short)
    }
    else if(strcmp(enc, "l") == 0){
        apc_invokS_rbox_by(long)
    }
    else if(strcmp(enc, "q") == 0){
        apc_invokS_rbox_by(long long)
    }
    else if(strcmp(enc, "C") == 0){
        apc_invokS_rbox_by(unsigned char)
    }
    else if(strcmp(enc, "I") == 0){
        apc_invokS_rbox_by(unsigned int)
    }
    else if(strcmp(enc, "S") == 0){
        apc_invokS_rbox_by(unsigned short)
    }
    else if(strcmp(enc, "L") == 0){
        apc_invokS_rbox_by(unsigned long)
    }
    else if(strcmp(enc, "Q") == 0){
        apc_invokS_rbox_by(unsigned long long)
    }
    else if(strcmp(enc, "f") == 0){
        apc_invokS_rbox_by(float)
    }
    else if(strcmp(enc, "d") == 0){
        apc_invokS_rbox_by(double)
    }
    else if(strcmp(enc, "B") == 0){
        apc_invokS_rbox_by(bool)
    }
    else if(strcmp(enc, "*") == 0){
        apc_invokS_rbox_by(char *)
    }
    else if(strcmp(enc, "#") == 0){
        apc_invokS_rbox_by(Class)
    }
    else if(strcmp(enc, ":") == 0){
        apc_invokS_rbox_by(SEL)
    }
    else if(enc[0] == _C_PTR){
        apc_invokS_rbox_by(void*)
    }
    else if(strcmp(enc, @encode(APCRect)) == 0){
        apc_invokS_rbox_by(APCRect)
    }
    else if(strcmp(enc, @encode(APCPoint)) == 0){
        apc_invokS_rbox_by(APCPoint)
    }
    else if(strcmp(enc, @encode(APCSize)) == 0){
        apc_invokS_rbox_by(APCSize)
    }
    else if(strcmp(enc, @encode(APCEdgeinsets)) == 0){
        apc_invokS_rbox_by(APCEdgeinsets)
    }
    else if(strcmp(enc, @encode(NSRange)) == 0){
        apc_invokS_rbox_by(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"Types that are not supported.");
}


static inline id apc_getterimp_boxinvok(id _SELF,SEL _CMD,IMP imp,const char* enc)
{
    NSCAssert(*enc != '\0', @"APC: Type encoding can not be nil.");
    
    if(enc[0] == _C_ID){
        
        return ((id(*)(id,SEL))imp)(_SELF,_CMD);
    }
    
    
    if(strcmp(enc, "c") == 0){
        
#define apc_invokNG_rbox_by(type,ftype)\
\
type returnValue = ((type(*)(id,SEL))imp)(_SELF,_CMD);\
return [NSNumber numberWith##ftype:returnValue];
        
        apc_invokNG_rbox_by(char,Char)
    }
    else if(strcmp(enc, "i") == 0){
        apc_invokNG_rbox_by(int,Int)
    }
    else if(strcmp(enc, "s") == 0){
        apc_invokNG_rbox_by(short,Short)
    }
    else if(strcmp(enc, "l") == 0){
        apc_invokNG_rbox_by(long,Long)
    }
    else if(strcmp(enc, "q") == 0){
        apc_invokNG_rbox_by(long long,LongLong)
    }
    else if(strcmp(enc, "C") == 0){
        apc_invokNG_rbox_by(unsigned char,UnsignedChar)
    }
    else if(strcmp(enc, "I") == 0){
        apc_invokNG_rbox_by(unsigned int,UnsignedInt)
    }
    else if(strcmp(enc, "S") == 0){
        apc_invokNG_rbox_by(unsigned short,UnsignedShort)
    }
    else if(strcmp(enc, "L") == 0){
        apc_invokNG_rbox_by(unsigned long,UnsignedLong)
    }
    else if(strcmp(enc, "Q") == 0){
        apc_invokNG_rbox_by(unsigned long long,UnsignedLongLong)
    }
    else if(strcmp(enc, "f") == 0){
        apc_invokNG_rbox_by(float,Float)
    }
    else if(strcmp(enc, "d") == 0){
        apc_invokNG_rbox_by(double,Double)
    }
    else if(strcmp(enc, "B") == 0){
        apc_invokNG_rbox_by(bool,Bool)
    }
    else if(strcmp(enc, "*") == 0){
        
#define apc_invokG_rbox_by(type)\
\
type returnValue = ((type(*)(id,SEL))imp)(_SELF,_CMD);\
return [NSValue valueWithBytes:&returnValue objCType:enc];
        
        apc_invokG_rbox_by(char *)
    }
    else if(strcmp(enc, "#") == 0){
        apc_invokG_rbox_by(Class)
    }
    else if(strcmp(enc, ":") == 0){
        apc_invokG_rbox_by(SEL)
    }
    else if(enc[0] == _C_PTR){
        apc_invokG_rbox_by(void*)
    }
    else if(strcmp(enc, @encode(APCRect)) == 0){
        apc_invokG_rbox_by(APCRect)
    }
    else if(strcmp(enc, @encode(APCPoint)) == 0){
        apc_invokG_rbox_by(APCPoint)
    }
    else if(strcmp(enc, @encode(APCSize)) == 0){
        apc_invokG_rbox_by(APCSize)
    }
    else if(strcmp(enc, @encode(APCEdgeinsets)) == 0){
        apc_invokG_rbox_by(APCEdgeinsets)
    }
    else if(strcmp(enc, @encode(NSRange)) == 0){
        apc_invokG_rbox_by(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"Types that are not supported.");
    return nil;
}


#define apc_def_vGHook(enc,type,oghook)\
\
type oghook##_##enc(_Nullable id _SELF,SEL _CMD)\
{\
    NSValue* value = oghook(_SELF, _CMD);\
    \
    type ret;\
    [value getValue:&ret];\
    \
    return ret;\
}

#define apc_def_vNGHook(enc,type,oghook,ftype)\
\
type oghook##_##enc(_Nullable id _SELF,SEL _CMD)\
{\
    return [((NSNumber*)oghook(_SELF, _CMD)) ftype##Value];\
}


#define apc_def_vGHook_and_impimage(oghook)\
    \
apc_def_vNGHook(c,char,oghook,char)\
apc_def_vNGHook(i,int,oghook,int)\
apc_def_vNGHook(s,short,oghook,short)\
apc_def_vNGHook(l,long,oghook,long)\
apc_def_vNGHook(q,long long,oghook,longLong)\
apc_def_vNGHook(C,unsigned char,oghook,unsignedChar)\
apc_def_vNGHook(I,unsigned int,oghook,unsignedInt)\
apc_def_vNGHook(S,unsigned short,oghook,unsignedShort)\
apc_def_vNGHook(L,unsigned long,oghook,unsignedLong)\
apc_def_vNGHook(Q,unsigned long long,oghook,unsignedLongLong)\
apc_def_vNGHook(f,float,oghook,float)\
apc_def_vNGHook(d,double,oghook,double)\
apc_def_vNGHook(B,BOOL,oghook,bool)\
apc_def_vGHook(chars,char*,oghook)\
apc_def_vGHook(class,Class,oghook)\
apc_def_vGHook(sel,SEL,oghook)\
apc_def_vGHook(ptr,void*,oghook)\
apc_def_vGHook(rect,APCRect,oghook)\
apc_def_vGHook(point,APCPoint,oghook)\
apc_def_vGHook(size,APCSize,oghook)\
apc_def_vGHook(range,NSRange,oghook)\
\
void* _Nullable oghook##_impimage(NSString* _Nonnull enc)\
{\
    if([enc isEqualToString:@"c"]){\
        return oghook##_c;\
    }\
    else if ([enc isEqualToString:@"i"]){\
        return oghook##_i;\
    }\
    else if ([enc isEqualToString:@"s"]){\
        return oghook##_s;\
    }\
    else if ([enc isEqualToString:@"l"]){\
        return oghook##_l;\
    }\
    else if ([enc isEqualToString:@"q"]){\
        return oghook##_q;\
    }\
    else if ([enc isEqualToString:@"C"]){\
        return oghook##_C;\
    }\
    else if ([enc isEqualToString:@"I"]){\
        return oghook##_I;\
    }\
    else if ([enc isEqualToString:@"S"]){\
        return oghook##_S;\
    }\
    else if ([enc isEqualToString:@"L"]){\
        return oghook##_L;\
    }\
    else if ([enc isEqualToString:@"Q"]){\
        return oghook##_Q;\
    }\
    else if ([enc isEqualToString:@"f"]){\
        return oghook##_f;\
    }\
    else if ([enc isEqualToString:@"d"]){\
        return oghook##_d;\
    }\
    else if ([enc isEqualToString:@"B"]){\
        return oghook##_B;\
    }\
    else if ([enc isEqualToString:@"*"]){\
        return oghook##_chars;\
    }\
    else if ([enc isEqualToString:@"#"]){\
        return oghook##_class;\
    }\
    else if ([enc isEqualToString:@":"]){\
        return oghook##_sel;\
    }\
    else if ([enc characterAtIndex:0] == '^'){\
        return oghook##_ptr;\
    }\
    else if ([enc isEqualToString:@(@encode(APCRect))]){\
        return oghook##_rect;\
    }\
    else if ([enc isEqualToString:@(@encode(APCPoint))]){\
        return oghook##_point;\
    }\
    else if ([enc isEqualToString:@(@encode(APCSize))]){\
        return oghook##_size;\
    }\
    else if ([enc isEqualToString:@(@encode(NSRange))]){\
        return oghook##_range;\
    }\
    return nil;\
}


#define apc_def_vSHook(enc,type,oshook)\
\
void oshook##_##enc(_Nullable id _SELF,SEL _CMD,type val)\
{\
    \
    oshook(_SELF, _CMD, [NSValue valueWithBytes:&val objCType:@encode(type)]);\
}

#define apc_def_vNSHook(enc,type,oshook,ftype)\
\
void oshook##_##enc(_Nullable id _SELF,SEL _CMD,type val)\
{\
    \
    oshook(_SELF, _CMD, [NSNumber numberWith##ftype:val]);\
}

#define apc_def_vSHook_and_impimage(oshook)\
\
apc_def_vNSHook(c,char,oshook,Char)\
apc_def_vNSHook(i,int,oshook,Int)\
apc_def_vNSHook(s,short,oshook,Short)\
apc_def_vNSHook(l,long,oshook,Long)\
apc_def_vNSHook(q,long long,oshook,LongLong)\
apc_def_vNSHook(C,unsigned char,oshook,UnsignedChar)\
apc_def_vNSHook(I,unsigned int,oshook,UnsignedInt)\
apc_def_vNSHook(S,unsigned short,oshook,UnsignedShort)\
apc_def_vNSHook(L,unsigned long,oshook,UnsignedLong)\
apc_def_vNSHook(Q,unsigned long long,oshook,UnsignedLongLong)\
apc_def_vNSHook(f,float,oshook,Float)\
apc_def_vNSHook(d,double,oshook,Double)\
apc_def_vNSHook(B,BOOL,oshook,Bool)\
apc_def_vSHook(chars,char*,oshook)\
apc_def_vSHook(class,Class,oshook)\
apc_def_vSHook(sel,SEL,oshook)\
apc_def_vSHook(ptr,void*,oshook)\
apc_def_vSHook(rect,APCRect,oshook)\
apc_def_vSHook(point,APCPoint,oshook)\
apc_def_vSHook(size,APCSize,oshook)\
apc_def_vSHook(range,NSRange,oshook)\
\
void* _Nullable oshook##_impimage(NSString* _Nonnull enc)\
{\
if([enc isEqualToString:@"c"]){\
    return oshook##_c;\
}\
else if ([enc isEqualToString:@"i"]){\
    return oshook##_i;\
}\
else if ([enc isEqualToString:@"s"]){\
    return oshook##_s;\
}\
else if ([enc isEqualToString:@"l"]){\
    return oshook##_l;\
}\
else if ([enc isEqualToString:@"q"]){\
    return oshook##_q;\
}\
else if ([enc isEqualToString:@"C"]){\
    return oshook##_C;\
}\
else if ([enc isEqualToString:@"I"]){\
    return oshook##_I;\
}\
else if ([enc isEqualToString:@"S"]){\
    return oshook##_S;\
}\
else if ([enc isEqualToString:@"L"]){\
    return oshook##_L;\
}\
else if ([enc isEqualToString:@"Q"]){\
    return oshook##_Q;\
}\
else if ([enc isEqualToString:@"f"]){\
    return oshook##_f;\
}\
else if ([enc isEqualToString:@"d"]){\
    return oshook##_d;\
}\
else if ([enc isEqualToString:@"B"]){\
    return oshook##_B;\
}\
else if ([enc isEqualToString:@"*"]){\
    return oshook##_chars;\
}\
else if ([enc isEqualToString:@"#"]){\
    return oshook##_class;\
}\
else if ([enc isEqualToString:@":"]){\
    return oshook##_sel;\
}\
else if ([enc characterAtIndex:0] == '^'){\
    return oshook##_ptr;\
}\
else if ([enc isEqualToString:@(@encode(APCRect))]){\
    return oshook##_rect;\
}\
else if ([enc isEqualToString:@(@encode(APCPoint))]){\
    return oshook##_point;\
}\
else if ([enc isEqualToString:@(@encode(APCSize))]){\
    return oshook##_size;\
}\
else if ([enc isEqualToString:@(@encode(NSRange))]){\
    return oshook##_range;\
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

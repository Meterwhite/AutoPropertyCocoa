#ifndef __APCScope__H__
#define __APCScope__H__

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE || TARGET_OS_TV

#import <UIKit/UIKit.h>
#define APC_RECT            CGRect
#define APC_POINT           CGPoint
#define APC_SIZE            CGSize
#define APC_EDGEINSETS      UIEdgeInsets

#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>
#define APC_RECT            NSRect
#define APC_POINT           NSPoint
#define APC_SIZE            NSSize
#define APC_EDGEINSETS      NSEdgeInsets

#endif



#define APC_ProxyClassNameForLazyLoad(class) \
    ([NSString stringWithFormat:@"%@%@",NSStringFromClass(class),APCClassSuffixForLazyLoad])

/**
 Class.property
 */
#define keyForCachedPropertyMap(class,propertyName)\
    ([NSString stringWithFormat:@"%@.%@",NSStringFromClass(class),propertyName])

typedef void*(*APCFunc_S)(id,SEL,id);
typedef void*(*APCFunc_G_ptr)(id,SEL);


FOUNDATION_EXPORT NSString *const APCClassSuffixForLazyLoad;

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

NS_INLINE void apc_setterimp_boxinvok(id _SELF,SEL _CMD,IMP imp,const char* enc, id arg)
{
    NSCAssert(*enc != '\0', @"APC: Type encoding can not be nil.");
    
    if(enc[0] == _C_ID){
        
        ((void(*)(id,SEL,id))imp)(_SELF,_CMD,arg);
    }
    
    ///Boxed basic-value.
    if(![arg isKindOfClass:[NSValue class]]){
        
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
    else if(strcmp(enc, @encode(APC_RECT)) == 0){
        apc_invokS_rbox_by(APC_RECT)
    }
    else if(strcmp(enc, @encode(APC_POINT)) == 0){
        apc_invokS_rbox_by(APC_POINT)
    }
    else if(strcmp(enc, @encode(APC_SIZE)) == 0){
        apc_invokS_rbox_by(APC_SIZE)
    }
    else if(strcmp(enc, @encode(APC_EDGEINSETS)) == 0){
        apc_invokS_rbox_by(APC_EDGEINSETS)
    }
    else if(strcmp(enc, @encode(NSRange)) == 0){
        apc_invokS_rbox_by(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"Types that are not supported.");
}


NS_INLINE id apc_getterimp_boxinvok(id _SELF,SEL _CMD,IMP imp,const char* enc)
{
    NSCAssert(*enc != '\0', @"APC: Type encoding can not be nil.");
    
    if(enc[0] == _C_ID){
        
        return ((id(*)(id,SEL))imp)(_SELF,_CMD);
    }
    
    
    if(strcmp(enc, "c") == 0){
#define apc_invokG_rbox_by(type)\
    \
type returnValue = ((type(*)(id,SEL))imp)(_SELF,_CMD);\
return [NSValue valueWithBytes:&returnValue objCType:enc];
        
        apc_invokG_rbox_by(char)
    }
    else if(strcmp(enc, "i") == 0){
        apc_invokG_rbox_by(int)
    }
    else if(strcmp(enc, "s") == 0){
        apc_invokG_rbox_by(short)
    }
    else if(strcmp(enc, "l") == 0){
        apc_invokG_rbox_by(long)
    }
    else if(strcmp(enc, "q") == 0){
        apc_invokG_rbox_by(long long)
    }
    else if(strcmp(enc, "C") == 0){
        apc_invokG_rbox_by(unsigned char)
    }
    else if(strcmp(enc, "I") == 0){
        apc_invokG_rbox_by(unsigned int)
    }
    else if(strcmp(enc, "S") == 0){
        apc_invokG_rbox_by(unsigned short)
    }
    else if(strcmp(enc, "L") == 0){
        apc_invokG_rbox_by(unsigned long)
    }
    else if(strcmp(enc, "Q") == 0){
        apc_invokG_rbox_by(unsigned long long)
    }
    else if(strcmp(enc, "f") == 0){
        apc_invokG_rbox_by(float)
    }
    else if(strcmp(enc, "d") == 0){
        apc_invokG_rbox_by(double)
    }
    else if(strcmp(enc, "B") == 0){
        apc_invokG_rbox_by(bool)
    }
    else if(strcmp(enc, "*") == 0){
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
    else if(strcmp(enc, @encode(APC_RECT)) == 0){
        apc_invokG_rbox_by(APC_RECT)
    }
    else if(strcmp(enc, @encode(APC_POINT)) == 0){
        apc_invokG_rbox_by(APC_POINT)
    }
    else if(strcmp(enc, @encode(APC_SIZE)) == 0){
        apc_invokG_rbox_by(APC_SIZE)
    }
    else if(strcmp(enc, @encode(APC_EDGEINSETS)) == 0){
        apc_invokG_rbox_by(APC_EDGEINSETS)
    }
    else if(strcmp(enc, @encode(NSRange)) == 0){
        apc_invokG_rbox_by(NSRange)
    }
    ///enc-m
    NSCAssert(NO, @"Types that are not supported.");
    return nil;
}

#define APCPropertysArray(...)\
@[APCPropertys(__VA_ARGS__)]

#define APCPropertys(...)\
APCmacro_if_eq(2,APCmacro_argcount(__VA_ARGS__))(APCPropertys1(__VA_ARGS__))\
(APCmacro_if_eq(3,APCmacro_argcount(__VA_ARGS__))(APCPropertys2(__VA_ARGS__))(APCPropertys3(__VA_ARGS__)))

#define APCPropertys1(OBJ, P1)\
(((void)(NO && ((void)OBJ.P1, NO)), @# P1))

#define APCPropertys2(OBJ, P1, P2)\
(((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO)), (@# P1, @# P2)))

#define APCPropertys3(OBJ, P1, P2, P3)\
(((void)(NO && ((void)OBJ.P1, NO) && ((void)OBJ.P2, NO) && ((void)OBJ.P3, NO)), (@# P1, @# P2, @ #P3)))

#define APCGetPath(...) \
APCmacro_if_eq(1, APCmacro_argcount(__VA_ARGS__))(aKpath1(__VA_ARGS__))(aKpath2(__VA_ARGS__))


#define APCmacro_concat_(A, B) A ## B

#define APCmacro_concat(A, B) \
APCmacro_concat_(A, B)

#define APCmacro_at(N, ...) \
APCmacro_concat(APCmacro_at, N)(__VA_ARGS__)

#define APCmacro_argcount(...) \
APCmacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

#define APCmacro_if_eq(A, B) \
APCmacro_concat(APCmacro_if_eq, A)(B)

#define aKpath1(PATH) \
(((void)(NO && ((void)PATH, NO)), strchr(# PATH, '.') + 1))

#define aKpath2(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))


#define APCmacro_head_(FIRST, ...) FIRST

#define APCmacro_head(...) \
APCmacro_head_(__VA_ARGS__, 0)

// APCmacro_at expansions
#define APCmacro_at0(...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at1(_0, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at2(_0, _1, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at3(_0, _1, _2, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at4(_0, _1, _2, _3, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at5(_0, _1, _2, _3, _4, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at6(_0, _1, _2, _3, _4, _5, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at7(_0, _1, _2, _3, _4, _5, _6, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) APCmacro_head(__VA_ARGS__)
#define APCmacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) APCmacro_head(__VA_ARGS__)


#define APCmacro_consume_(...)

#define APCmacro_expand_(...) __VA_ARGS__

#define APCmacro_dec(VAL) \
APCmacro_at(VAL, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19)

// ak_if_eq expansions
#define APCmacro_if_eq0(VALUE) \
APCmacro_concat(APCmacro_if_eq0_, VALUE)

#define APCmacro_if_eq0_0(...) __VA_ARGS__ APCmacro_consume_
#define APCmacro_if_eq0_1(...) APCmacro_expand_
#define APCmacro_if_eq0_2(...) APCmacro_expand_
#define APCmacro_if_eq0_3(...) APCmacro_expand_
#define APCmacro_if_eq0_4(...) APCmacro_expand_
#define APCmacro_if_eq0_5(...) APCmacro_expand_
#define APCmacro_if_eq0_6(...) APCmacro_expand_
#define APCmacro_if_eq0_7(...) APCmacro_expand_
#define APCmacro_if_eq0_8(...) APCmacro_expand_
#define APCmacro_if_eq0_9(...) APCmacro_expand_
#define APCmacro_if_eq0_10(...) APCmacro_expand_
#define APCmacro_if_eq0_11(...) APCmacro_expand_
#define APCmacro_if_eq0_12(...) APCmacro_expand_
#define APCmacro_if_eq0_13(...) APCmacro_expand_
#define APCmacro_if_eq0_14(...) APCmacro_expand_
#define APCmacro_if_eq0_15(...) APCmacro_expand_
#define APCmacro_if_eq0_16(...) APCmacro_expand_
#define APCmacro_if_eq0_17(...) APCmacro_expand_
#define APCmacro_if_eq0_18(...) APCmacro_expand_
#define APCmacro_if_eq0_19(...) APCmacro_expand_
#define APCmacro_if_eq0_20(...) APCmacro_expand_

#define APCmacro_if_eq1(VALUE) APCmacro_if_eq0(APCmacro_dec(VALUE))
#define APCmacro_if_eq2(VALUE) APCmacro_if_eq1(APCmacro_dec(VALUE))
#define APCmacro_if_eq3(VALUE) APCmacro_if_eq2(APCmacro_dec(VALUE))
#define APCmacro_if_eq4(VALUE) APCmacro_if_eq3(APCmacro_dec(VALUE))
#define APCmacro_if_eq5(VALUE) APCmacro_if_eq4(APCmacro_dec(VALUE))
#define APCmacro_if_eq6(VALUE) APCmacro_if_eq5(APCmacro_dec(VALUE))
#define APCmacro_if_eq7(VALUE) APCmacro_if_eq6(APCmacro_dec(VALUE))
#define APCmacro_if_eq8(VALUE) APCmacro_if_eq7(APCmacro_dec(VALUE))
#define APCmacro_if_eq9(VALUE) APCmacro_if_eq8(APCmacro_dec(VALUE))
#define APCmacro_if_eq10(VALUE) APCmacro_if_eq9(APCmacro_dec(VALUE))
#define APCmacro_if_eq11(VALUE) APCmacro_if_eq10(APCmacro_dec(VALUE))
#define APCmacro_if_eq12(VALUE) APCmacro_if_eq11(APCmacro_dec(VALUE))
#define APCmacro_if_eq13(VALUE) APCmacro_if_eq12(APCmacro_dec(VALUE))
#define APCmacro_if_eq14(VALUE) APCmacro_if_eq13(APCmacro_dec(VALUE))
#define APCmacro_if_eq15(VALUE) APCmacro_if_eq14(APCmacro_dec(VALUE))
#define APCmacro_if_eq16(VALUE) APCmacro_if_eq15(APCmacro_dec(VALUE))
#define APCmacro_if_eq17(VALUE) APCmacro_if_eq16(APCmacro_dec(VALUE))
#define APCmacro_if_eq18(VALUE) APCmacro_if_eq17(APCmacro_dec(VALUE))
#define APCmacro_if_eq19(VALUE) APCmacro_if_eq18(APCmacro_dec(VALUE))
#define APCmacro_if_eq20(VALUE) APCmacro_if_eq19(APCmacro_dec(VALUE))


#endif

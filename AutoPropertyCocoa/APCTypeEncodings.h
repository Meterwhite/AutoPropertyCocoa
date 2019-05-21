//
//  APCTypeEncodings.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/7.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APCCharCoderValue       99//c
#define APCIntCoderValue        105//i
#define APCShortCoderValue      115//s
#define APCLonglCoderValue      108//l
#define APCLongLongCoderValue   113//q
#define APCUCharCoderValue      67//C
#define APCUIntCoderValue       73//I
#define APCUShortCoderValue     83//S
#define APCULongCoderValue      76//L
#define APCULongLongCoderValue  81//Q
#define APCFloatCoderValue      102//f
#define APCDoubleCoderValue     100//d
#define APC_BoolCoderValue      66//B
#define APCVoidCoderValue       118//v
#define APCCharPtrCoderValue    42//*
#define APCObjectCoderValue     64//@
#define APCClassCoderValue      35//#
#define APCSELCoderValue        58//:
#define APCVoidPtrCoderValue    30302//^v
#define APCOtherCoderValue      63//?

#define APCPtrCoderMaskValue    94//^
#define APCArrayCoderMaskValue  91//[
#define APCStructCoderMaskValue 123//{
#define APCUnionCoderMaskValue  40//(

#if __LP64__
#define APCRectCoderValue       4428273620435288955//{CGRect=
#define APCPointCoderValue      8389759082646946683//{CGPoint
#define APCSizeCoderValue       4424076801748714363//{CGSize=

#if TARGET_OS_MAC
#define APCEdgeInsetsCoderValue 5288747017773993595//{NSEdg
#else
#define APCEdgeInsetsCoderValue 5288747017773340027//{UIEdgeI
#endif

#define APCRangeCoderValue      7453001439557607291//{_NSRang

#else ///LP32

#define APCRectCoderValue       1380402043//{CGR
#define APCPointCoderValue      1346847611//{CGP
#define APCSizeCoderValue       1397179259//{CGS

#if TARGET_OS_MAC
#define APCEdgeInsetsCoderValue  1163087483//{NSE
#else
#define APCEdgeInsetsCoderValue  1162433915//{UIE
#endif

#define APCRangeCoderValue      1397645179//{_NS

#endif

/**
 APCCoderEqualMask(@encode(CGRect), APCStructCoderMaskValue)
 */
#define APCCoderEqualMask(encstring , mask) \
\
(mask == ((*((unsigned long*)encstring)) & mask))

#define APCCoderCompare(encstring, codevalue) (*((unsigned long*)encstring) == codevalue)

#define if_APCCoderCompare(encstring, codevalue) if(APCCoderCompare(encstring, codevalue))


union apc_coder_t {
    
    char        mask;
    char        encode[sizeof(unsigned long)];
#if __LP64__
    uint64_t    value;
#else
    uint32      value;
#endif
    uintptr_t       : sizeof(uintptr_t);
    uintptr_t   imp : sizeof(uintptr_t);
};

typedef union apc_coder_t APCCoder;

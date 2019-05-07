//
//  APCTypeEncodings.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/7.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APCCharCodeValue      99//c
#define APCIntCodeValue       105//i
#define APCShortCodeValue     115//s
#define APCLonglCodeValue     108//l
#define APCLongLongCodeValue  113//q
#define APCUCharCodeValue     67//C
#define APCUIntCodeValue      73//I
#define APCUShortCodeValue    83//S
#define APCULongCodeValue     76//L
#define APCULongLongCodeValue 81//Q
#define APCFloatCodeValue     102//f
#define APCDoubleCodeValue    100//d
#define APC_BoolCodeValue     66//B
#define APCVoidCodeValue      118//v
#define APCCharPtrCodeValue   42//*
#define APCObjectCodeValue    64//@
#define APCClassCodeValue     35//#
#define APCSELCodeValue       58//:
#define APCPtrCodeValue       94//^
#define APCVoidPtrCodeValue   30302//^v
#define APCOtherCodeValue     63//?

#if __LP64__
#define APCRectCodeValue      4428273620435288955//{CGRect=
#define APCPointCodeValue     8389759082646946683//{CGPoint
#define APCSizeCodeValue      4424076801748714363//{CGSize=

#if TARGET_OS_MAC
#define APCEdgeInsetsCodeValue        5288747017773993595//{NSEdgeI
#else
#define APCEdgeInsetsCodeValue        5288747017773340027//{UIEdgeI
#endif

#define APCRangeCodeValue      7453001439557607291//{_NSRang

#else
#define APCRectCodeValue      1380402043//{CGRect=
#define APCPointCodeValue     1346847611//{CGPoint
#define APCSizeCodeValue      1397179259//{CGSize=

#if TARGET_OS_MAC
#define APCEdgeInsetsCodeValue        1163087483//{NSEdgeI
#else
#define APCEdgeInsetsCodeValue        1162433915//{UIEdgeI
#endif

#define APCRangeCodeValue      1397645179//{_NSRang

#endif


#define APCMTypesFunction(funcBody, APCCodeValue) funcBody##APCCodeValue





/**
 
 Encode/0/IMP
 */
union apc_coder_t {
    
    char mask;
    char encode[sizeof(unsigned long)];
#if __LP64__
    unsigned long value;
#else
    uint32 value;
#endif
    char alloc[2*sizeof(unsigned long) + 1];
};

typedef union apc_coder_t APCCoder;

APCCoder APCMakeTypeEncodings(const char* encode)
{
    APCCoder s = {0};
    s.value = *(unsigned long*)encode;
    return s;
}

IMP APCCoderGetIMP(APCCoder enc)
{
    return *(IMP*)(&enc + sizeof(sizeof(unsigned long) + 1));
}

void APCTypeEncodingsSetIMP(APCCoder enc , IMP* imp)
{
    void* des = (void*)(&enc + sizeof(sizeof(unsigned long) + 1));
    memcpy(des, imp, sizeof(uintptr_t));
}


static APCCoder apc_int_coder = {.encode = "i\0"};

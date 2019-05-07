//
//  main.m
//  TestRuntime+APC
//
//  Created by NOVO on 2019/5/5.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "Person.h"
#import "Man.h"



/**
 
 Encode/0/IMP
 */
union apc_code_t {
    
    char mask;
    char encode[sizeof(unsigned long)];
#if __LP64__
    unsigned long value;
#else
    uint32 value;
#endif
    char alloc[2*sizeof(unsigned long) + 1];
};


typedef union apc_code_t APCCode;

APCCode APCMakeTypeEncodings(const char* encode)
{
    APCCode s = {0};
    s.value = *(unsigned long*)encode;
    return s;
}

IMP APCTypeEncodingsGetIMP(APCCode enc)
{
    return *(IMP*)(&enc + sizeof(sizeof(unsigned long) + 1));
}

void APCTypeEncodingsSetIMP(APCCode enc , IMP* imp)
{
    void* des = (void*)(&enc + sizeof(sizeof(unsigned long) + 1));
    memcpy(des, imp, sizeof(uintptr_t));
}


#define APCCharEnc      99//c
#define APCIntEnc       105//i
#define APCShortEnc     115//s
#define APCLonglEnc     108//l
#define APCLongLongEnc  113//q
#define APCUCharEnc     67//C
#define APCUIntEnc      73//I
#define APCUShortEnc    83//S
#define APCULongEnc     76//L
#define APCULongLongEnc 81//Q
#define APCFloatEnc     102//f
#define APCDoubleEnc    100//d
#define APC_BoolEnc     66//B
#define APCVoidEnc      118//v
#define APCCharPtrEnc   42//*
#define APCObjectEnc    64//@
#define APCClassEnc     35//#
#define APCSELEnc       58//:
#define APCPtrEnc       94//^
#define APCVoidPtrEnc   30302//^v
#define APCOtherEnc     63//?

#if __LP64__
#define APCRectEnc      4428273620435288955//{CGRect=
#define APCPointEnc     8389759082646946683//{CGPoint
#define APCSizeEnc      4424076801748714363//{CGSize=

#if TARGET_OS_MAC
#define APCEdgeInsetsEnc        5288747017773993595//{NSEdgeI
#else
#define APCEdgeInsetsEnc        5288747017773340027//{UIEdgeI
#endif

#define APCRangeEnc      7453001439557607291//{_NSRang

#else
#define APCRectEnc      1380402043//{CGRect=
#define APCPointEnc     1346847611//{CGPoint
#define APCSizeEnc      1397179259//{CGSize=

#if TARGET_OS_MAC
#define APCEdgeInsetsEnc        1163087483//{NSEdgeI
#else
#define APCEdgeInsetsEnc        1162433915//{UIEdgeI
#endif

#define APCRangeEnc      1397645179//{_NSRang

#endif

#define print_encdoe(type) \
{\
    char* enc = (char*)@encode(type);\
    char newEnc[9] = {0};\
    \
    strncpy(newEnc, enc, 8);\
    newEnc[8] = '\0';\
    \
    printf("%luUL<---" #type "--->%s" "\n", *(unsigned long*)newEnc, enc);\
    \
}

void apc_testingEncode()
{
    print_encdoe(char);
    print_encdoe(int);
    print_encdoe(short);
    print_encdoe(long);
    print_encdoe(long long);
    print_encdoe(unsigned char);
    print_encdoe(unsigned int);
    print_encdoe(unsigned short);
    print_encdoe(unsigned long);
    print_encdoe(unsigned long long);
    print_encdoe(float);
    print_encdoe(double);
    print_encdoe(_Bool);
    print_encdoe(char *);
    print_encdoe(id);
    print_encdoe(Class);
    print_encdoe(SEL);
    print_encdoe(void*);
    
    print_encdoe(CGRect);
    print_encdoe(CGPoint);
    print_encdoe(CGSize);
    print_encdoe(NSEdgeInsets);
    print_encdoe(NSRange);
    
}

static APCCode _code = {.encode = "iiiiiii\0"};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
//        APCCode code = {0};
//        strncpy(code.encode, @encode(CGRect), 8);
//        unsigned long v = code.value;
//        uint32 v32 = code.value32;
        
        
//        printf("%u\n",(uint32)APCRectEnc);
//        printf("%u\n",(uint32)APCPointEnc);
//        printf("%u\n",(uint32)APCSizeEnc);
//        printf("%u\n",(uint32)APCEdgeInsetsEnc);
//        printf("%u\n",(uint32)APCRangeEnc);
//        printf("%u\n",(uint32)5288747017773340027);
        
        APCCode dd = _code;
        
        apc_testingEncode();
    }
    return 0;
}

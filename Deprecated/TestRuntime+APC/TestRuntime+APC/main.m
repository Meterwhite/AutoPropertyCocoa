//
//  main.m
//  TestRuntime+APC
//
//  Created by NOVO on 2019/5/5.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCTypeEncodings.h"
#import "apc-objc-private.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Person.h"
#import "Man.h"


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
        
        class_removeMethod_APC_OBJC2_NONRUNTIMELOCK([Person class], @selector(name));
        
        if(APCCoderEqualMask(@encode(CGRect), APCStructCoderMaskValue)){
            
            printf("1");
        }
    }
    return 0;
}

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
#import "apc-objc-private.h"
#import "Person.h"
#import "Man.h"

NS_INLINE int apc_func0()
{
    return 0;
}

void apc_func1(int a)
{
    
}

NSString* apc_func2()
{
    return @"";
}


union apc_imp_t {
    char c;
    CGRect imp;
};

typedef union apc_imp_t APCIMP;


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        uintptr_t a = (uintptr_t)&apc_func0;
        uintptr_t b = (uintptr_t)&apc_func1;
        uintptr_t c = (uintptr_t)&apc_func2;
        
        APCIMP aimp;
        aimp.c = 'A';
        
        
        NSLog(@"%lX / %lX / %lX",a,b,c);
        
//        Class m_cls = [Man class];
//
//        apc_objc_removeMethod(m_cls, @selector(name));
//
//        Man* m = [Man new];
//        id name = m.name;
    }
    return 0;
}

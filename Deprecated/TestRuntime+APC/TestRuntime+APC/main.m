//
//  main.m
//  TestRuntime+APC
//
//  Created by NOVO on 2019/5/5.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "fishhook.h"
#import "pthread.h"
#import "Person.h"
#import "Man.h"

static char *(*ptr0)(const char *str);

char * apc_strdupIfMutable(const char *str)
{
    return ptr0(str);
}

static Class(*ptr1)(Class _Nullable superclass, const char * _Nonnull name,
                    size_t extraBytes);

Class _Nullable
apc_objc_allocateClassPair(Class _Nullable superclass, const char * _Nonnull name,
                           size_t extraBytes)
{
    return ptr1(superclass,  name, extraBytes);
}

static void(*ptr3)(size_t __count, size_t __size);
void apc_calloc(size_t __count, size_t __size)
{
    return ptr3(__count,__size);
}

static pthread_t _thread_0;
static pthread_t _thread_1;
static pthread_t _thread_1;
static pthread_t _thread_2;
static pthread_t _thread_3;
static pthread_t _thread_4;

int main(int argc, const char * argv[]) {
    
//    struct rebinding rbd3
//    =
//    {
//        .name = "calloc",
//        .replacement = apc_calloc,
//        .replaced = (void*)&ptr3
//    };
//
//    rebind_symbols((struct rebinding[1]){rbd3} , 1);
    
    dispatch_group_t group = dispatch_group_create();
    _thread_0 = pthread_self();
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        printf("1\n");
        _thread_1 = pthread_self();
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_queue_t q2 = dispatch_get_global_queue(0, 0);
    dispatch_async(q2, ^{

        printf("2\n");
        _thread_2  = pthread_self();
        dispatch_group_leave(group);
    });
    
    printf("wait\n");
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{

        printf("0=1 -> %u", _thread_0 == _thread_1);
        printf("1=2 -> %u", _thread_1 == _thread_2);
        printf("0=2 -> %u", _thread_0 == _thread_2);
    });
    
//    while (1) ;
    
    return 0;
}


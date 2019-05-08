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

int main(int argc, const char * argv[]) {
    
    
    struct rebinding rbd3
    =
    {
        .name = "calloc",
        .replacement = apc_calloc,
        .replaced = (void*)&ptr3
    };
//    open();
    rebind_symbols((struct rebinding[1]){rbd3} , 1);
    
    objc_allocateProtocol("15620540095");
    
//    objc_allocateClassPair([NSObject class],"15620540095",0);
//    Protocol* protocol = objc_allocateProtocol("15620540095");
//    objc_registerProtocol(protocol);
//    objc_registerClassPair([NSObject class]);
    
//    class_setSuperclass([Man class],[Person class]);
    
    return 0;
}

/**

 
 struct rebinding rbd
 =
 {
 .name = "strdupIfMutable",
 .replacement = apc_strdupIfMutable,
 .replaced = (void*)&ptr0
 };




 */

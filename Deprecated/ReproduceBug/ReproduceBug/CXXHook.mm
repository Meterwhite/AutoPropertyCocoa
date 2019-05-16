//
//  CXXHook.m
//  ReproduceBug
//
//  Created by NOVO on 2019/5/16.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import <objc/runtime.h>
#import "apc-objc-os.h"
#import "CXXHook.h"

class cxxClass
{
    
    
public:
    int age;
    cxxClass(int iAge)
    {
        age = iAge;
    }
    ~cxxClass()
    {
        age = 0;
    }
};

@implementation CXXHook
{
    void* _voidPtr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _voidPtr = (void*)CFBridgingRetain([NSObject new]);
        cxxClass xxx(123);
    }
    return self;
}

- (void)dealloc
{
    
    
    if(_voidPtr){
        
        CFRelease(_voidPtr);
    }
}
@end

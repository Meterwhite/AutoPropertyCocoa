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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Class m_cls = [Man class];

        apc_objc_removeMethod(m_cls, @selector(name));
        
        Man* m = [Man new];
        id name = m.name;
    }
    return 0;
}

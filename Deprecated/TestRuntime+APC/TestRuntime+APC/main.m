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

        class_removeMethod_APC_OBJC2_NONRUNTIMELOCK(m_cls, @selector(name2));
        
        Man* m = [Man new];
        [m name0];
        [m name1];
        [m name];
        [m name2];
    }
    return 0;
}

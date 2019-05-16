//
//  AppDelegate.m
//  ReproduceBug
//
//  Created by NOVO on 2019/5/16.
//  Copyright © 2019 NOVO. All rights reserved.
//

#import "APCProxyInstanceDisposer.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "CXXHook.h"
#import "Person.h"
#import "OCHook.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

const char _key = '\0';
static NSMapTable* _refMap;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _refMap = [NSMapTable weakToStrongObjectsMapTable];
    
    @autoreleasepool {
        
        Person* p = [Person new];
        
        Class newClass = objc_allocateClassPair([Person class], "ProxyPerson", 0);
        objc_registerClassPair(newClass);
        
        object_setClass(p, newClass);
        p.obj = @"obj";
        p->_proxyClass = newClass;
        
        CXXHook* cxxHook0 = [CXXHook new];
        cxxHook0->_instance = p;
        CXXHook* cxxHook1 = [CXXHook new];
        cxxHook1->_instance = p;
        NSMapTable* tab = [NSMapTable strongToStrongObjectsMapTable];
        [tab setObject:cxxHook0 forKey:@"A"];
        [tab setObject:cxxHook1 forKey:@"B"];
        objc_setAssociatedObject(p
                                 , &_key
                                 , tab
                                 , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
//        [_refMap setObject:[[APCProxyInstanceDisposer alloc] initWithClass:newClass]
//                    forKey:@""];
        
        //recover
        objc_disposeClassPair(newClass);
        
        object_setClass(p, objc_getClass("Person"));
    }
    
    printf("End");
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

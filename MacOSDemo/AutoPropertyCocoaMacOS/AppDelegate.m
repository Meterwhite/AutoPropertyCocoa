//
//  AppDelegate.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AppDelegate.h"
#import "APCScope.h"
#import "APCTest.h"
#import "JiNvW.h"

#warning <#message#>
#import "apc-objc-runtimelock.h"
#import "apc-objc-extension.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

//    [APCTest testDemo:0];
//    [APCTest testDemo:101];
//    [APCTest testDemo:106];
    
//    JiNvW
    
    class_removeMethod_APC_OBJC2([JiNvW class], @selector(xB));
    
    
    JiNvW* jn = [JiNvW new];
//    id xx  = jn.xB;
    
    class_removeMethod_APC_OBJC2([JiNvW class], @selector(zB));
    id zz  = jn.zB;
    
    [APCTest testDemoFrom:102 to:103];
    
//    [APCTest testDemo:10086];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

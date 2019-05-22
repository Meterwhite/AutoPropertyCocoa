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
#warning <#message#>
#import "apc-objc-runtimelock.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

//    [APCTest testDemo:0];
//    [APCTest testDemo:101];
//    [APCTest testDemo:106];
    
    [APCTest testDemoFrom:100 to:106];
    
//    [APCTest testDemo:10086];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

//
//  AppDelegate.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AutoPropertyCocoa.h"
#import "AppDelegate.h"
#import "APCScope.h"
#import "APCTest.h"
#import "Person.h"

#warning <#message#>
#import "apc-objc-runtimelock.h"
#import "apc-objc-extension.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
//    [APCTest testDemoFrom:100 to:106];
    [APCTest testDemo:107];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

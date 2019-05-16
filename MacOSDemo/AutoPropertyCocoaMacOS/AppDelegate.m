//
//  AppDelegate.m
//  AutoPropertyCocoaMacOS
//
//  Created by MDLK on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AppDelegate.h"
#import "APCScope.h"
#import "APCTest.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

//    [APCTest testDemo:0];
//    [APCTest testDemo:101];
    [APCTest testDemo:103];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

//
//  AppDelegate.m
//  AutoPropertyCocoaMacOS
//
//  Created by MDLK on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "AppDelegate.h"
#import "APCTest.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //    [APCTest testDemoFrom:0 to:100];
    //    [APCTest testDemoFrom:2 to:10];
    
    [APCTest testDemo:911];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

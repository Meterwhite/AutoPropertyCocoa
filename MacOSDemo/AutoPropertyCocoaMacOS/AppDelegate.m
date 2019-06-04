//
//  AppDelegate.m
//  AutoPropertyCocoa
//
//  Created by Meterwhite on 2019/4/8.
//  Copyright © 2019 Meterwhite. All rights reserved.
//

#import "AutoPropertyCocoa.h"
#import "AppDelegate.h"
#import "APCTest.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [APCTest testDemoFrom:100 to:113];
    
    APCLazyload(self,window,superclass);
    
    
    APCClassUnbindLazyload(AppDelegate, window, superclass,window);
    
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

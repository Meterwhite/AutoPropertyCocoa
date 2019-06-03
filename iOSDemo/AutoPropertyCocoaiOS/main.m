//
//  main.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import "AutoPropertyCocoa.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"


int main(int argc, char * argv[]) {
    
    apc_main_classHookFullSupport();
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

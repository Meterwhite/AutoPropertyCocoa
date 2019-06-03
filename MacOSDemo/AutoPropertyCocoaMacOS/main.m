//
//  main.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/8.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "APCScope.h"

int main(int argc, const char * argv[]) {
    
    apc_main_classHookFullSupport();
    return NSApplicationMain(argc, argv);
}

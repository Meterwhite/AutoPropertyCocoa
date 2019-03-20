#ifndef __AutoWorkPropertyConst__H__
#define __AutoWorkPropertyConst__H__

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE || TARGET_OS_TV

#import <UIKit/UIKit.h>
#define APC_RECT            CGRect
#define APC_POINT           CGPoint
#define APC_SIZE            CGSize
#define APC_EDGEINSETS      UIEdgeInsets

#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>
#define APC_RECT            NSRect
#define APC_POINT           NSPoint
#define APC_SIZE            NSSize
#define APC_EDGEINSETS      NSEdgeInsets

#endif



FOUNDATION_EXPORT NSString *const AWProgramingType_point;
FOUNDATION_EXPORT NSString *const AWProgramingType_chars;
FOUNDATION_EXPORT NSString *const AWProgramingType_id;
FOUNDATION_EXPORT NSString *const AWProgramingType_NSBlock;
FOUNDATION_EXPORT NSString *const AWProgramingType_SEL;
FOUNDATION_EXPORT NSString *const AWProgramingType_char;
FOUNDATION_EXPORT NSString *const AWProgramingType_unsignedchar;
FOUNDATION_EXPORT NSString *const AWProgramingType_int;
FOUNDATION_EXPORT NSString *const AWProgramingType_unsignedint;
FOUNDATION_EXPORT NSString *const AWProgramingType_short;
FOUNDATION_EXPORT NSString *const AWProgramingType_unsignedshort;
FOUNDATION_EXPORT NSString *const AWProgramingType_long;
FOUNDATION_EXPORT NSString *const AWProgramingType_unsignedlong;
FOUNDATION_EXPORT NSString *const AWProgramingType_longlong;
FOUNDATION_EXPORT NSString *const AWProgramingType_unsignedlonglong;
FOUNDATION_EXPORT NSString *const AWProgramingType_float;
FOUNDATION_EXPORT NSString *const AWProgramingType_double;
FOUNDATION_EXPORT NSString *const AWProgramingType_bool;

#endif

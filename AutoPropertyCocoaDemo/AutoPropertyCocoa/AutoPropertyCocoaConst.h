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

#define APC_BoxSelector(sel) (NSStringFromSelector(@selector(sel)))

#define APC_ProxyClassNameForLazyLoad(class) \
    ([NSString stringWithFormat:@"%@%@",NSStringFromClass(class),APCClassSuffixForLazyLoad])

/**
 Class.property
 */
#define keyForCachedPropertyMap(class,propertyName)\
    ([NSString stringWithFormat:@"%@.%@",NSStringFromClass(class),propertyName])

FOUNDATION_EXPORT NSString *const APCClassSuffixForLazyLoad;

FOUNDATION_EXPORT NSString *const APCProgramingType_point;
FOUNDATION_EXPORT NSString *const APCProgramingType_chars;
FOUNDATION_EXPORT NSString *const APCProgramingType_id;
FOUNDATION_EXPORT NSString *const APCProgramingType_NSBlock;
FOUNDATION_EXPORT NSString *const APCProgramingType_SEL;
FOUNDATION_EXPORT NSString *const APCProgramingType_char;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedchar;
FOUNDATION_EXPORT NSString *const APCProgramingType_int;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedint;
FOUNDATION_EXPORT NSString *const APCProgramingType_short;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedshort;
FOUNDATION_EXPORT NSString *const APCProgramingType_long;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedlong;
FOUNDATION_EXPORT NSString *const APCProgramingType_longlong;
FOUNDATION_EXPORT NSString *const APCProgramingType_unsignedlonglong;
FOUNDATION_EXPORT NSString *const APCProgramingType_float;
FOUNDATION_EXPORT NSString *const APCProgramingType_double;
FOUNDATION_EXPORT NSString *const APCProgramingType_bool;

#endif

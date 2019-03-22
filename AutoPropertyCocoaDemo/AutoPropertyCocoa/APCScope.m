#ifndef __APCScope__H__
#define __APCScope__H__

#import <Foundation/Foundation.h>

NSString *const  APCClassSuffixForLazyLoad          =   @"/APCProxyClassLazyLoad";

NSString *const  APCProgramingType_point             =   @"void*";
NSString *const  APCProgramingType_chars             =   @"char*";
NSString *const  APCProgramingType_id                =   @"id";
NSString *const  APCProgramingType_NSBlock           =   @"NSBlock";
NSString *const  APCProgramingType_SEL               =   @"SEL";
NSString *const  APCProgramingType_char              =   @"char";
NSString *const  APCProgramingType_unsignedchar      =   @"unsigned char";
NSString *const  APCProgramingType_int               =   @"int";
NSString *const  APCProgramingType_unsignedint       =   @"unsigned int";
NSString *const  APCProgramingType_short             =   @"short";
NSString *const  APCProgramingType_unsignedshort     =   @"unsigned short";
NSString *const  APCProgramingType_long              =   @"long";
NSString *const  APCProgramingType_unsignedlong      =   @"unsigned long";
NSString *const  APCProgramingType_longlong          =   @"long long";
NSString *const  APCProgramingType_unsignedlonglong  =   @"unsigned long long";
NSString *const  APCProgramingType_float             =   @"float";
NSString *const  APCProgramingType_double            =   @"double";
NSString *const  APCProgramingType_bool              =   @"bool";

#endif

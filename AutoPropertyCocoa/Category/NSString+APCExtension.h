//
//  NSString+APCExtension.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/25.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(APCExtension)

#pragma mark - kvc search order
///https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/SearchImplementation.html
/** set<Key>: */
- (nonnull NSString*)apc_kvcAssumedSetterName1;
/** _set<Key> */
- (nonnull NSString*)apc_kvcAssumedSetterName2;

/** _<key> */
- (nonnull NSString*)apc_kvcAssumedIvarName1;
/** _is<Key> */
- (nonnull NSString*)apc_kvcAssumedIvarName2;
/**  <key> */
- (nonnull NSString*)apc_kvcAssumedIvarName3;
/** is<Key> */
- (nonnull NSString*)apc_kvcAssumedIvarName4;


- (nonnull NSString*)apc_firstCharUpper;
@end

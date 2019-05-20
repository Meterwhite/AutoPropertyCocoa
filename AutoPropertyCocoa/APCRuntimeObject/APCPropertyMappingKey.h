//
//  APCPropertyMappingKey.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/5/18.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 The optimization of this Class is 'faster comparison'.
 */
@interface APCPropertyMappingKey : NSObject<NSFastEnumeration>

- (nonnull instancetype)initWithMatchingProperty:(nonnull NSString*)property;

- (nonnull instancetype)initWithProperty:(nonnull NSString*)property
                                  getter:(nullable NSString*)getter
                                  setter:(nullable NSString*)setter;

/**
 Oneway , [p1 isEqual: p3] -> YES, [p3 isEqual: p1] -> NO;
 */
- (BOOL)isEqual:(nonnull APCPropertyMappingKey*)object;

@end



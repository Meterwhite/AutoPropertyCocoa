//
//  APCPropertyMapperKey.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE NSString* apc_desMapperKeyString(Class desClass,NSString* propertyName){
    return [NSString stringWithFormat:@"%@.%@",NSStringFromClass(desClass),propertyName];
}

NS_INLINE NSString* apc_srcMapperKeyString(Class srcClass){
    return NSStringFromClass(srcClass);
}


@interface APCPropertyMapperKey : NSObject<NSCopying>

+ (instancetype)keyWithClass:(Class _Nonnull)aClass;

+ (instancetype)keyWithClass:(Class _Nonnull)aClass
                    property:(NSString* _Nonnull)property;

- (NSUInteger)hash;
@end


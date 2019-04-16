//
//  APCMethod.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS (NSUInteger,APCMethodStyle){
    ///v@:
    APCMethodDeallocStyle       =   0,
    
    ///@@:
    APCMethodGetterStyle        =   1,
    
    ///v@:@
    APCMethodSetterStyle        =   2,
};

@protocol APCMethodProtocol <NSObject>

@required
@property (nonatomic,assign,readonly) APCMethodStyle methodStyle;

@end


@interface APCMethod : NSObject<APCMethodProtocol>


@property (nonatomic,assign,readonly) APCMethodStyle methodStyle;

@end


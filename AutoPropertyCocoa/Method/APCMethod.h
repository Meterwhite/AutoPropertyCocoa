//
//  APCMethod.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright (c) 2019 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS (char,APCMethodStyle){
    ///v@:
    APCMethodDeallocStyle       =   'D',
    
    ///@@:
    APCMethodGetterStyle        =   'G',
    
    ///v@:@
    APCMethodSetterStyle        =   'S',
};

@protocol APCMethodProtocol <NSObject>

@required
@property (nonatomic,readonly) APCMethodStyle methodStyle;

@end


@interface APCMethod : NSObject<APCMethodProtocol>


@property (nonatomic,readonly) APCMethodStyle methodStyle;

@end


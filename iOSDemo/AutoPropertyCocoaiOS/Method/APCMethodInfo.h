//
//  APCMethodInfo.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS (NSUInteger,APCMethodStyle){
    
    APCMethodGetterStyle        =   0,
    
    APCMethodSetterStyle        =   1,
};

@interface APCMethodInfo : NSObject

@property (nonatomic,assign) APCMethodStyle methodStyle;

@end


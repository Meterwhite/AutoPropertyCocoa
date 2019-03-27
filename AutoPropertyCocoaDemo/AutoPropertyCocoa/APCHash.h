//
//  APCHash.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE BOOL apc_mul_overflow_UL(unsigned long long x,unsigned long long y)
{
    return (ULONG_LONG_MAX/x) < y;
}

NS_INLINE NSUInteger apc_hash_pairing(unsigned long long x,unsigned long long y)
{
//    NSDecimal;
//    [NSExpression new];
    return
    
    apc_mul_overflow_UL((x+y),(long double)0.5*(x+y+1))
    ? 0
    : (unsigned long long)((long double)0.5*(x+y+1)*(x+y)+y);
}

NS_INLINE void apc_hash_depairing(unsigned long long z,unsigned long long* x,unsigned long long* y)
{
//    NSDecimalNumber* zNum = [[NSDecimalNumber alloc] initWithUnsignedLong:z];   
    
    unsigned long long w =  floorl((long double)0.5*(sqrtl((8 * z) + 1) - 1));
    
    *y = (unsigned long long)(z - (long double)0.5 * w * (w + 1));
    
    *x = w - *y;
}

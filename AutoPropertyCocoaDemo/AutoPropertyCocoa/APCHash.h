//
//  APCHash.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE BOOL apc_mul_overflow_UL(NSUInteger x,NSUInteger y)
{
    return (ULONG_MAX/x) < y;
}


/**
 http://szudzik.com/ElegantPairing.pdf
 */
NS_INLINE NSUInteger apc_hash_szudzikpairing(NSUInteger x,NSUInteger y)
{
    return (NSUInteger)(x >= y)?(x*x + x + y):(y*y + x);
}

NS_INLINE void apc_hash_deszudzikpairing(NSUInteger z,NSUInteger* x,NSUInteger* y)
{
    long double sqrtz = floorl(sqrtl(z));
    unsigned long long sqz = sqrtz * sqrtz;
    if((((unsigned long long)z - sqz) >= sqrtz)){
        
        *x = sqrtz;
        *y = (unsigned long long)z - sqz - sqrtz;
    }else{
        
        *x = (unsigned long long)z - sqz;
        *y = sqrtz;
    };
}

/**
 This function that is offen to overflow.
 https://en.wikipedia.org/wiki/Pairing_function#Cantor_pairing_function
 */
NS_INLINE NSUInteger apc_hash_cantorpairing(NSUInteger x,NSUInteger y)
{
    return (NSUInteger)(((long double)0.5)*(x+y+1)*(x+y)+y);
}

NS_INLINE void apc_hash_decantorpairing(NSUInteger z,NSUInteger* x,NSUInteger* y) //OBJC2_UNAVAILABLE
{
    NSUInteger w =  floorl(((long double)0.5)*(sqrtl((8 * z) + 1) - 1));
    
    *y = (NSUInteger)(z - ((long double)0.5) * w * (w + 1));
    
    *x = w - *y;
}

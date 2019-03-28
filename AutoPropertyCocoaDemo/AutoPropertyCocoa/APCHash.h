//
//  APCHash.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/3/27.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#define _APC_HASHFACTOR 2654435761U

NS_INLINE NSUInteger apc_hash_UL(NSUInteger i) {
    return i  * _APC_HASHFACTOR;
}

NS_INLINE NSUInteger apc_UL_rotateLeft(NSUInteger i) {
    
    return (i << sizeof(NSUInteger)/2) | (i >> sizeof(NSUInteger)/2);
}

NS_INLINE NSUInteger apc_hash_UL2(NSUInteger i,NSUInteger j) {
    
    return apc_hash_UL(i) ^ apc_UL_rotateLeft(apc_hash_UL(j));
}

CF_EXPORT NSUInteger CFHashBytes(uint8_t *_Nullable bytes, CFIndex len);

NS_INLINE NSUInteger apc_hash_bytes(uint8_t *_Nullable bytes, CFIndex len) {
    return CFHashBytes(bytes, len);
}

NS_INLINE BOOL apc_mul_overflow_UL(NSUInteger x,NSUInteger y)
{
    return (ULONG_MAX/x) < y;
}


NS_INLINE NSUInteger apc_hash_szudzikpairing(NSUInteger x,NSUInteger y) OBJC2_UNAVAILABLE
{
    return (NSUInteger)(x >= y)?(x*x + x + y):(y*y + x);
}

NS_INLINE void apc_hash_deszudzikpairing(NSUInteger z,NSUInteger* _Nonnull x,NSUInteger* _Nonnull y) OBJC2_UNAVAILABLE
{
    double sqrtz = floor(sqrt(z));
    NSUInteger sqz = sqrtz * sqrtz;
    if(((z - sqz) >= sqrtz)){
        
        *x = sqrtz;
        *y = z - sqz - sqrtz;
    }else{
        
        *x = z - sqz;
        *y = sqrtz;
    };
}

NS_INLINE NSUInteger apc_hash_cantorpairing(NSUInteger x,NSUInteger y) OBJC2_UNAVAILABLE
{
    return (NSUInteger)(((double)0.5)*(x+y+1)*(x+y)+y);
}

NS_INLINE void apc_hash_decantorpairing(NSUInteger z,NSUInteger* _Nonnull x,NSUInteger* _Nonnull y) OBJC2_UNAVAILABLE
{
    NSUInteger w =  floor(((double)0.5)*(sqrt((8 * z) + 1) - 1));
    
    *y = (NSUInteger)(z - ((double)0.5) * w * (w + 1));
    
    *x = w - *y;
}

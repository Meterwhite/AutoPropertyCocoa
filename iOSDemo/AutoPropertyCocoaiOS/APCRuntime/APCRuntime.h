//
//  APCRuntime.h
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoPropertyInfo.h"


OBJC_EXPORT AutoPropertyInfo* _Nullable
apc_property_getSuperProperty(AutoPropertyInfo* _Nonnull p);

//OBJC_EXPORT AutoPropertyInfo* _Nullable
//apc_property_nextBoundProperty(AutoPropertyInfo* _Nullable p);

OBJC_EXPORT NSArray<__kindof AutoPropertyInfo*>* _Nonnull
apc_classBoundProperties(Class _Nonnull cls, NSString* _Nonnull property);

//OBJC_EXPORT void
//apc_property_isRegistered(AutoPropertyInfo* _Nullable p);

OBJC_EXPORT void
apc_addProperty(AutoPropertyInfo* _Nonnull p);


OBJC_EXPORT void
apc_removeProperty(AutoPropertyInfo* _Nonnull p);

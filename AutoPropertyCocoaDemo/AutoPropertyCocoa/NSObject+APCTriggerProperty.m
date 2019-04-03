//
//  NSObject+APCTriggerProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCInstancePropertyCacheManager.h"
#import "NSObject+APCTriggerProperty.h"



#pragma mark - hook getter
id _Nullable apc_trigger_getter(id _Nonnull _SELF, SEL _Nonnull _CMD)
{
    AutoTriggerPropertyInfo* triggerPropertyInfo;
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterFrontTrigger){
        
        [triggerPropertyInfo performGetterFrontTriggerBlock:_SELF];
    }
    
    id ret = [triggerPropertyInfo performOldPropertyFromTarget:_SELF];
    
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterPostTrigger){
        
        [triggerPropertyInfo performGetterPostTriggerBlock:_SELF value:ret];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterUserTrigger){
        
        if([triggerPropertyInfo performGetterConditionBlock:_SELF value:ret]){
            
            [triggerPropertyInfo performGetterUserTriggerBlock:_SELF value:ret];
        }
    }
    
    return ret;
}

apc_def_vGHook_and_impimage(apc_trigger_getter)

#pragma mark - hook setter
void apc_trigger_setter(id _Nonnull _SELF, SEL _Nonnull _CMD, id _Nullable value)
{
    AutoTriggerPropertyInfo* triggerPropertyInfo;
    
    if(nil == (triggerPropertyInfo = [APCInstancePropertyCacheManager boundPropertyFromInstance:_SELF cmd:NSStringFromSelector(_CMD)]))
        
        if(nil == (triggerPropertyInfo = [AutoTriggerPropertyInfo cachedWithClass:[_SELF class] propertyName:NSStringFromSelector(_CMD)]))
            
            NSCAssert(NO, @"APC: Lose property info.");
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterFrontTrigger){
        
        [triggerPropertyInfo performSetterFrontTriggerBlock:_SELF value:value];
    }
    
    [triggerPropertyInfo performOldSetterFromTarget:_SELF withValue:value];
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterPostTrigger){
        
        [triggerPropertyInfo performSetterPostTriggerBlock:_SELF value:value];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterUserTrigger){
        
        if([triggerPropertyInfo setterPerformConditionBlock:_SELF value:value]){
            
            [triggerPropertyInfo performSetterUserTriggerBlock:_SELF value:value];
        }
    }
}

apc_def_vSHook_and_impimage(apc_trigger_setter)

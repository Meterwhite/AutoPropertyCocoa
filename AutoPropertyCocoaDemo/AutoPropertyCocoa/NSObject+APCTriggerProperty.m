//
//  NSObject+APCTriggerProperty.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/1.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "NSObject+APCTriggerProperty.h"

@implementation NSObject (APCTriggerProperty)

@end

#pragma mark - hook getter
id _Nullable apc_trigger_getter(id _Nonnull _SELF, SEL _Nonnull _CMD)
{
    AutoTriggerPropertyInfo* triggerPropertyInfo;
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterFrontTrigger){
        
        [triggerPropertyInfo getterPerformFrontTriggerBlock:_SELF];
    }
    
    id ret  = nil;
    if(triggerPropertyInfo.accessOption & AutoPropertyComponentOfGetter){
        
        ret = [triggerPropertyInfo performOldPropertyFromTarget:_SELF];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterPostTrigger){
        
        [triggerPropertyInfo getterPerformPostTriggerBlock:_SELF value:ret];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertyGetterUserTrigger){
        
        if([triggerPropertyInfo getterPerformConditionBlock:_SELF value:ret]){
            
            [triggerPropertyInfo getterPerformUserTriggerBlock:_SELF value:ret];
        }
    }
    
    return ret;
}

apc_def_vGHook_and_impimage(apc_trigger_getter)

#pragma mark - hook setter
void apc_trigger_setter(id _Nonnull _SELF, SEL _Nonnull _CMD, id _Nullable value)
{
    AutoTriggerPropertyInfo* triggerPropertyInfo;
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterFrontTrigger){
        
        [triggerPropertyInfo setterPerformFrontTriggerBlock:_SELF value:value];
    }
    
    if(triggerPropertyInfo.accessOption & AutoPropertyComponentOfSetter){
        
        [triggerPropertyInfo performOldSetterFromTarget:_SELF withValue:value];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterPostTrigger){
        
        [triggerPropertyInfo setterPerformPostTriggerBlock:_SELF value:value];
    }
    
    if(triggerPropertyInfo.triggerOption & AutoPropertySetterUserTrigger){
        
        if([triggerPropertyInfo setterPerformConditionBlock:_SELF value:value]){
            
            [triggerPropertyInfo setterPerformUserTriggerBlock:_SELF value:value];
        }
    }
}

apc_def_vSHook_and_impimage(apc_trigger_setter)

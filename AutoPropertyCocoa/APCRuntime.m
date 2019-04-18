//
//  APCRuntime.m
//  AutoPropertyCocoa
//
//  Created by Novo on 2019/4/15.
//  Copyright © 2019 Novo. All rights reserved.
//

#import "APCPropertyHook.h"
#import "APCMethodHook.h"
#import "APCRuntime.h"
#import "APCScope.h"

NS_INLINE APCPropertyHook* apc_instance_propertyhook(id instance, NSString* property);

#pragma mark - For class - private

#define APC_RUNTIME_LOCK \
\
dispatch_semaphore_wait(_apc_runtime_mapperlock, DISPATCH_TIME_FOREVER)

#define APC_RUNTIME_UNLOCK \
\
dispatch_semaphore_signal(_apc_runtime_mapperlock)

static dispatch_semaphore_t _apc_runtime_mapperlock;

///Class : Property_key : Hook(:Properties)
static NSMapTable*  _apc_runtime_property_classmapper;

static NSMapTable* apc_runtime_property_classmapper()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _apc_runtime_mapperlock = dispatch_semaphore_create(1);
        _apc_runtime_property_classmapper = [NSMapTable strongToStrongObjectsMapTable];
    });
    return _apc_runtime_property_classmapper;
}

NS_INLINE APCPropertyHook* _Nonnull
apc_runtime_propertyhook(Class __unsafe_unretained _Nonnull clazz, NSString* _Nonnull property)
{
    return [[apc_runtime_property_classmapper() objectForKey:clazz] objectForKey:property];
}

#pragma mark - For hook - export
APCPropertyHook* apc_lookup_propertyhook(Class clazz, NSString* property)
{
    return apc_runtime_propertyhook(clazz, property);
}

APCPropertyHook* apc_lookup_propertyhook_range(Class from, Class to, NSString* property)
{
    if([from isSubclassOfClass:to]){
        
        APCPropertyHook* ret;
        do {
            
            if(NULL != [apc_runtime_property_classmapper() objectForKey:from])
                
                if(NULL != (ret = apc_runtime_propertyhook(from, property)))
                    
                    return ret;
            
        } while (to != (from = class_getSuperclass(from)));
    }
    
    return (APCPropertyHook*)0;
}

APCPropertyHook* apc_lookup_superPropertyhook(Class cls, NSString* property)
{
    APCPropertyHook* ret;
    while (NULL != (cls = class_getSuperclass(cls))){
        
        if(NULL != [apc_runtime_property_classmapper() objectForKey:cls])
            
            if(NULL != (ret = apc_runtime_propertyhook(cls, property)))
                
                return ret;
    }
    
    return (APCPropertyHook*)0;
}

APCPropertyHook* apc_propertyhook_rootHook(APCPropertyHook* hook)
{
    APCPropertyHook* root = hook;
    
    do {
        if(root.superhook == NULL){
            
            break;
        }
        root = root.superhook;
    } while (true);
    
    return root;
}

APCPropertyHook* apc_lookup_instancePropertyhook(APCProxyInstance* instance, NSString* property)
{
    return apc_instance_propertyhook(instance, property);
}

#pragma mark - For class - export
void apc_registerProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    NSMutableDictionary*dictionary = [apc_runtime_property_classmapper() objectForKey:p->_des_class];
    APCPropertyHook*    superhook;
    APCPropertyHook*    hook;
    
    if(dictionary == NULL){
        
        dictionary = [NSMutableDictionary dictionary];
        [apc_runtime_property_classmapper() setObject:dictionary forKey:p->_des_class];
    }
    
    hook = dictionary[p->_hooked_name];
    
    if(hook == NULL){
        
        hook = [APCPropertyHook hookWithProperty:p];
        dictionary[p->_hooked_name] = hook;
    }else{
        
        [hook bindProperty:p];
    }
#warning <#message#>
    ///Update superhook
    superhook
    = apc_lookup_superPropertyhook(p->_des_class, p->_hooked_name);
    //apc_runtime_propertyhook
    for (Class cls in apc_runtime_property_classmapper()) {
        
        if([cls isSubclassOfClass:p->_des_class]){
            
//            if((NULL != superhook && item.superhook == superhook)
//               || (NULL == superhook && (item->_superhook == NULL))){
//
//                item->_superhook = hook;
//            }
        }
    }
    hook->_superhook = superhook;
    
    APC_RUNTIME_UNLOCK;
}

void apc_disposeProperty(APCHookProperty* p)
{
    APC_RUNTIME_LOCK;
    
    APCPropertyHook* hook = apc_runtime_propertyhook( p->_des_class, p->_hooked_name);
    [hook unbindProperty:p];
    
    if(hook.isEmpty){
        ///Reset subhook's superhook
        
        APCPropertyHook* item;
        NSEnumerator* e = apc_runtime_property_classmapper().objectEnumerator;
        while (NULL != (item = e.nextObject)) {
            
            if(class_getSuperclass(item.hookclass) == p->_des_class){
                
                item->_superhook = hook->_superhook;
            }
        }
        
        [apc_runtime_property_classmapper() removeObjectForKey:p->_hooked_name];
    }
    
    APC_RUNTIME_UNLOCK;
}

NSArray* apc_classBoundProperties(Class cls, NSString* property)
{
    return [apc_runtime_propertyhook(cls , property) boundProperties];
}

APCHookProperty* apc_property_getRootProperty(APCHookProperty* p)
{
    APCPropertyHook* hook
    = apc_propertyhook_rootHook(apc_runtime_propertyhook(p->_des_class, p->_hooked_name));
    
    for (APCHookProperty* item in hook) {
        
        if(p.class == item.class){
            
            return item;
        }
    }
    return (APCHookProperty*)0;
}

APCHookProperty* apc_property_getSuperProperty(APCHookProperty* p)
{
    APCPropertyHook* hook = [apc_runtime_propertyhook(p->_des_class, p->_hooked_name)
                          superhook];
    for (APCHookProperty* item in hook) {
        
        if(p.class == item.class){
            
            return item;
        }
    }
    return (APCHookProperty*)0;
}

NSArray<__kindof APCHookProperty*>*
apc_property_getSuperPropertyList(APCHookProperty* p)
{
    APCPropertyHook* hook
    = [apc_runtime_propertyhook(p->_des_class, p->_hooked_name)
       superhook];
    NSMutableArray*  ret = [NSMutableArray array];
    
    for (APCHookProperty* item in hook) {
        
        if(p.class == item.class){
            
            [ret addObject:item];
        }
    }
    return [ret copy];
}


#pragma mark - For instance - private
/** Instance : Property : Hook */
const static char _keyForAPCInstanceBoundMapper = '\0';
static NSMapTable* apc_instanceBoundMapper(id instance)
{
    NSMapTable*         mapper;
    
    if(NULL == (mapper = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundMapper))){
        
        @synchronized (instance) {
            
            if(NULL == (mapper = objc_getAssociatedObject(instance, &_keyForAPCInstanceBoundMapper))){
                
                mapper = [NSMapTable strongToStrongObjectsMapTable];
                objc_setAssociatedObject(instance
                                         , &_keyForAPCInstanceBoundMapper
                                         , mapper
                                         , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    return mapper;
}

NS_INLINE APCPropertyHook*
apc_instance_propertyhook(id instance, NSString* property)
{
    return [apc_instanceBoundMapper(instance) objectForKey:property];
}
#pragma mark - For instance - export
void apc_instance_setAssociatedProperty(APCProxyInstance* instance, APCHookProperty* p)
{
    
    if(NO == apc_class_conformsProxyClass(object_getClass(instance))){
        
        return;
    }
    
    APCPropertyHook* hook = [apc_instanceBoundMapper(instance) objectForKey:p->_hooked_name];
    
    if(hook == NULL){
        
        @synchronized (instance) {
            
            if(NULL == (hook = [apc_instanceBoundMapper(instance) objectForKey:p->_hooked_name])){
                
                hook = [APCPropertyHook hookWithProperty:p];
                [apc_instanceBoundMapper(instance) setObject:hook forKey:p->_hooked_name];
            }
        }
    }else{
        
        [hook bindProperty:p];
    }
}

void apc_instance_removeAssociatedProperty(APCProxyInstance* instance, APCHookProperty* p)
{
    if(NO == apc_class_conformsProxyClass(object_getClass(instance))){
        
        return;
    }
    
    [apc_instance_propertyhook(instance, p->_hooked_name) unbindProperty:p];
}

NSArray<__kindof APCHookProperty*>* apc_instance_boundPropertyies(APCProxyInstance* instance, NSString* property)
{
    if(NO == apc_class_conformsProxyClass(object_getClass(instance))){
        
        return (NSArray*)0;
    }
    
    return [apc_instance_propertyhook(instance,property) boundProperties];
}

#pragma mark - Recursive(For instance) private
/**
 (weak)ThreadID : (weak)Instance : (strong)CMDs
 
 */
static NSMapTable* _apc_object_hookRecursiveMapper;
static NSMapTable* apc_object_hookRecursiveMapper()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _apc_object_hookRecursiveMapper = [NSMapTable weakToWeakObjectsMapTable];
    });
    return _apc_object_hookRecursiveMapper;
}

NS_INLINE NSMapTable* apc_object_hookRecursiveCurrentMapper()
{
    return [apc_object_hookRecursiveMapper() objectForKey:APCThreadID];
}

NS_INLINE NSMutableSet* apc_object_hookRecursiveCurrentLoops(id instance)
{
    return [apc_object_hookRecursiveCurrentMapper() objectForKey:instance];
}

#pragma mark - Recursive(For instance) export
BOOL apc_object_hookRecursive_testing(id instance, SEL _Nonnull _CMD)
{
    return
    
    [apc_object_hookRecursiveCurrentLoops(instance) containsObject:NSStringFromSelector(_CMD)];
}

void apc_object_hookRecursive_loop(id instance, SEL _Nonnull _CMD)
{
    NSMutableSet* loops;
    if(NULL == (loops = apc_object_hookRecursiveCurrentLoops(instance))){
        
        @synchronized (instance) {
            
            if(NULL == (loops = apc_object_hookRecursiveCurrentLoops(instance))){
                
                if(NULL == apc_object_hookRecursiveCurrentMapper()){
                    
                    _apc_object_hookRecursiveMapper = [NSMapTable weakToStrongObjectsMapTable];
                    [_apc_object_hookRecursiveMapper setObject:instance forKey:APCThreadID];
                }
                loops = [NSMutableSet set];
                [loops addObject:NSStringFromSelector(_CMD)];
                [apc_object_hookRecursiveCurrentMapper() setObject:loops forKey:instance];
            }
        }
        return;
    }
    [loops addObject:NSStringFromSelector(_CMD)];
}

void apc_object_hookRecursive_break(id instance, SEL _Nonnull _CMD)
{
    [apc_object_hookRecursiveCurrentLoops(instance) removeObject:NSStringFromSelector(_CMD)];
}

#pragma mark - Proxy class - private
static const char* _apcProxyClassID = ".APCProxyClass+";
/** free! */
static char* apc_instanceProxyClassName(id instance)
{
    const char* cname = class_getName(object_getClass(instance));
    char h_str[2*sizeof(NSUInteger)] = {0};
    sprintf(h_str,"%lX",[instance hash]);
    char* buf = malloc(strlen(cname) + strlen(_apcProxyClassID) + strlen(h_str) + 1);
    buf[0] = '\0';
    strcat(buf, cname);
    strcat(buf, _apcProxyClassID);
    strcat(buf, h_str);
    return buf;
}

#pragma mark - Proxy class - export
BOOL apc_class_conformsProxyClass(Class cls)
{
    return ('\0' != strstr(class_getName(cls), _apcProxyClassID));
}

Class apc_class_unproxyClass(APCProxyClass cls)
{
    const char* cname = class_getName(cls);
    char* loc = strstr(cname, _apcProxyClassID);
    if(loc != '\0'){
        
        char* name = malloc(1 + loc - cname);
        strncpy(name, cname, loc - cname);
        name[loc - cname] = '\0';
        Class ret = objc_getClass(name);
        free(name);
        return ret;
    }
    return (Class)0;
}

void apc_class_disposeProxyClass(APCProxyClass cls)
{
    if(YES == apc_class_conformsProxyClass(cls)){
        
        objc_disposeClassPair(cls);
    }
}

BOOL apc_object_isProxyInstance(id instance)
{
    return apc_class_conformsProxyClass(object_getClass(instance));
}

APCProxyClass apc_object_hookWithProxyClass(id _Nonnull instance)
{
    char*           name = apc_instanceProxyClassName(instance);
    APCProxyClass   cls  = objc_allocateClassPair(object_getClass(instance), name, 0);
    if(cls != NULL){
        
        objc_registerClassPair(cls);
        object_setClass(instance, cls);
    }else if (NULL == (cls = objc_getClass(name))){
        
        fprintf(stderr, "APC: Can not register class '%s' at runtime.",name);
    }
    free(name);
    
    return cls;
}

APCProxyClass apc_instance_unhookFromProxyClass(APCProxyInstance* instance)
{
    if(NO == apc_class_conformsProxyClass(object_getClass(instance))){
        
        return (APCProxyClass)0;
    }
    
    return (APCProxyClass)
    
    object_setClass(instance, apc_class_unproxyClass(object_getClass(instance)));
}

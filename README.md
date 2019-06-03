!
[Logo](http://ico.ooopic.com/ajax/iconpng/?id=98399.png)
AutoPropertyCocoa
===
## Introduction
- Provides `lazy loadind` of property and object-oriented `property hook` by objc runtime.Can freely uninstall any function.More powerful than lazy loading of macro definitions.
- Key words :`iOS`/`macOS`/`cocoa`/`lazy load`/`property hook`/`懒加载`/`属性钩子`

## Import
- Drag directory `AutoPropertyCocoa` into project or use cocoapods
```objc
#import "AutoPropertyCocoa.h"
```
## Examples
```objc
//Instance lazy-load
APCLazyload(instance, property, ...);
APCUnbindLazyload(instance, property, ...);

//Class lazy-load
APCClassLazyload(Class, property, ...);
APCClassUnbindLazyload(Class, property, ...);

//Front-trigger hook
[anyone apc_frontOfPropertyGetter:key bindWithBlock:^(id_apc_t instance, id value) {

    ///Before getter of property called.
}];

//Post-trigger hook
[anyone apc_backOfPropertySetter:key bindWithBlock:^(id_apc_t instance, id value) {

    ///After setter of property called.
}];

//Condition-trigger hook
[anyone apc_propertySetter:key bindUserCondition:^BOOL(id_apc_t instance, id value) {
    
    ///Your condition when setter called...
} withBlock:^(id_apc_t instance, id value) {
    
    ///If your condition has been triggered.
}];

```

## User super method.
- APCUserEnvironment supports user call user method in super class.
- `id_apc_t` marks the id object as supporting APCUserEnvironment.
```objc
[Person apc_lazyLoadForProperty:key  usingBlock:^id (id_apc_t instance) {

    return @"Person.gettersetterobj";
}];

[Man apc_lazyLoadForProperty:key  usingBlock:^id (id_apc_t instance) {
    //Call above ↑
    return APCSuperPerformedAsId(instance);
}];

[Superman apc_lazyLoadForProperty:key usingBlock:^id (id_apc_t instance) {
    //Call above ↑
    return APCSuperPerformedAsId(instance);
}];
```

## Hook for instance.
- You can ignore here, If you don't access the property while binding the property, or access the property while unbinding the property, or bind the property when unbinding the property.
- In a large number of `multi-threaded` concurrency, bind - unbind, bind - access property, unbind - access property, has a small probability of generating an error : 'Attempt to use unknown class.'The error occurred when an object was accessed when object_setClass() was not completed. Although this probability is relatively small, it is still worthy of attention.This project has implemented the hooking of the runtimelock, which is used to achieve thread safety, but this seriously affects the efficiency, so instead of adopting the scheme, the scheme below is used.
- It is absolutely safe to use the following form in multi-threaded :
```objc

///Thread-A...
apc_safe_instance(instance, ^(id object) {

    APCLazyload(object, property);
});

///Thread-B...
apc_safe_instance(instance, ^(id object) {

    APCUnbindLazyload(object, property);
});


///Thread-C...
apc_safe_instance(instance, ^(Man* object) {

    [object accessProperty];
});

```

## Hook for class.
- You can ignore here, if you nerver unbind class hook.
- Bind or unbind a class hook is `thread safe`.
- If the hooked class needs to be unbind, it is recommended that you implement the following method in main().
```objc

int main(int argc, const char * argv[]) {

    /*
        1. Call before app or runtime load!
        2. This method will implement the function of deleting the method at runtime, 
           and if it is not called, it will adopt the scheme of analog deletion,
           which will affect the user's use of the method swizzle.
           The effect is that the correct class must be used to method-swizzle , 
           get Method , get imp.
           Exp :
           class_replaceMethod(CorrectClass, ...);
           class_getInstanceMethod(CorrectClass, ...);
    */
    apc_main_classHookFullSupport();
    return ... ...(argc, argv);
}
```

## Basic-value type
- The currently supported structure types are: XReact, XPoint, XSize, XEdgeinsets, NSRange.
- Lazy-load is invalid on the base-value type property of the class hook.But is valid on the instance, The lazy loading method is triggered when the instance's underlying value type property is first accessed.

## Possible to do
- Support all structure types
- New border

## Author
- Emergency : meterwhite@outlook.com


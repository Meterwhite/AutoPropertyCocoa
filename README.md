# AutoPropertyCocoa

![AutoPropertyCocoa icon](http://ico.ooopic.com/ajax/iconpng/?id=98399.png)

## Introduction
* Mainly provides `lazy loadind` of property and object-oriented `property hook`. 
* Key words :`iOS`/`macOS`/`cocoa`/`lazy load`/`property hook`/`懒加载`/`属性钩子`

## Import
* Drag directory `AutoPropertyCocoa` into project
* `#import "AutoPropertyCocoa.h"`
* Pod is suported.
```objc
#import "AutoPropertyCocoa.h"
```


## Examples
```objc

APCLazyload(instance, property, ...);
APCUnbindLazyload(instance, property, ...);

APCClassLazyload(Class, property, ...);
APCClassUnbindLazyload(Class, property, ...);

[anyone apc_frontOfPropertyGetter:key bindWithBlock:^(id_apc_t instance, id value) {

    ///Before getter of property called.
}];

[anyone apc_backOfPropertySetter:key bindWithBlock:^(id_apc_t instance, id value) {

    ///After setter of property called.
}];

[anyone apc_propertySetter:key bindUserCondition:^BOOL(id_apc_t _Nonnull instance, id  _Nullable value) {
    
    ///Your condition when setter called...
} withBlock:^(id_apc_t  _Nonnull instance, id  _Nullable value) {
    
    ///If your condition has been triggered.
}];

```

## User super method.
### APCUserEnvironment supports user call user method in super class.
### `id_apc_t` marks the id object as supporting APCUserEnvironment.
```objc
[Person apc_lazyLoadForProperty:key  usingBlock:^id _Nullable(id_apc_t instance) {

    return @"Person.gettersetterobj";
}];

[Man apc_lazyLoadForProperty:key  usingBlock:^id _Nullable(id_apc_t instance) {
    //Call ↑
    return APCSuperPerformedAsId(instance);
}];

[Superman apc_lazyLoadForProperty:key usingBlock:^id _Nullable(id_apc_t instance) {
    //Call ↑
    return APCSuperPerformedAsId(instance);
}];
```

## Hook for instance.
### In a large number of `multi-threaded` concurrency, bind-unbind, bind-access property, unbind-access property, has a small probability of generating an error : Attempt to use unknown class.
### It is absolutely safe to use the following form in multi-threaded :
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
### Bind or unbind a class is `thread safe`.
### It is rare to hook a class in general development.
### If the hooked class needs to be unbind, it is recommended that you implement the following method in main().
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

## Author
- Me : quxingyi@outlook.com


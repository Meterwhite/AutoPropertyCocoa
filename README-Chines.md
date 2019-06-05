
![Logo](https://raw.githubusercontent.com/qddnovo/AutoPropertyCocoa/master/Taoist.png)
AutoPropertyCocoa
===
## 简介
- 该三方主要提供Cocoa的属性懒加载和属性钩子的功能。完美闭环，绿色环保可增加可卸载，优于宏定义形式的懒加载。
- 关键词 :`iOS懒加载` `属性钩子` `macOS` `cocoa` `class_removeMethods` `runtimelock`
- [English documentation](https://github.com/qddnovo/AutoPropertyCocoa)

## 引用
- 拖拽文件夹`AutoPropertyCocoa`到项目 或者使用cocoapods
```objc
#import "AutoPropertyCocoa.h"
```
## 目标
```objc

- (id)lazyloadProperty{

    if(_lazyloadProperty == nil){
    
        _lazyloadProperty = [XClass ...];
    }
    return _lazyloadProperty;
}

=>

[instance apc_lazyLoadForProperty:@lazyloadProperty usingBlock:^id(id_apc_t instance){

    return [XClass ...];
}];

```
## 示例
#### 针对实例的懒加载。低耦合，无类型污染，推荐！
```objc

APCLazyload(instance, @propertyA, @propertyB, ...);

[instance apc_lazyLoadForProperty:@property usingBlock:^id(id_apc_t instance){

    return ...;
}];

[instance apc_lazyLoadForProperty:@arrayProperty selector:@selector(array)];

```
#### 支持解绑 针对实例的懒加载。
```objc

APCUnbindLazyload(instance, @propertyA, @propertyB, ...);

[instance apc_unbindLazyLoadForProperty:@keyForTabView];

```
#### 针对类的懒加载
```objc

APCClassLazyload(Class, propertyA, propertyB, ...);

APCClassUnbindLazyload(Class, propertyA, propertyB, ...);

```
#### 前触发钩子.在一个属性调用前调用。
```objc

[anyone apc_frontOfPropertyGetter:key bindWithBlock:^(id_apc_t instance, id value) {

    ///Before getter of property called.
}];

```
#### 后触发钩子.在一个属性调用后调用。
```objc

[anyone apc_backOfPropertySetter:key bindWithBlock:^(id_apc_t instance, id value) {

    ///After setter of property called.
}];

```
#### 条件触发钩子.当满足用户条件时调用。
```objc

[anyone apc_propertySetter:key bindUserCondition:^BOOL(id_apc_t instance, id value) {

    ///Your condition when setter called...
} withBlock:^(id_apc_t instance, id value) {

    ///If your condition has been triggered.
}];

```

![Quickview](https://raw.githubusercontent.com/qddnovo/AutoPropertyCocoa/master/Quickview.png)

## 基础值类型
#### 目前支持的结构体类型有: XReact, XPoint, XSize, XEdgeinsets, NSRange.
- 针对类型的钩子属性如果是基础值类型，那么将会是无效的并且会报错。但是针对实例的基础值类型是支持懒加载的，它和对象类型那种判断对象是否存在不同，它只在该属性第一次被访问时触发懒加载。

## 调用用户的super方法.
- APCUserEnvironment提供了用户环境，支持用户调用父级的业务方法。
- `id_apc_t`标记了这个id对象是支持APCUserEnvironment的。
```objc
[Person apc_lazyLoadForProperty:key  usingBlock:^id (id_apc_t instance) {

    return @"Person.gettersetterobj";
}];

[Man apc_lazyLoadForProperty:key  usingBlock:^id (id_apc_t instance) {
    //调用上方 ↑
    return APCSuperPerformedAsId(instance);
}];

[Superman apc_lazyLoadForProperty:key usingBlock:^id (id_apc_t instance) {
    //调用上方 ↑
    return APCSuperPerformedAsId(instance);
}];
```

## 针对实例的钩子的线程安全.
- 如果你不会在绑定/解绑实例属性钩子的同时访问这个属性，你可以忽略此处的说明。
- 在大量的多线程访问中，绑定/解绑实例属性钩子的同时访问这个属性有很小的概率产生异常： 'Attempt to use unknown class.'。这是由于object_setClass()还没有执行完的时候访问了实例对象。该问题除了进行同步没有办法解决。项目中已经钩住了runtimelock，使用它会影响效率，所以推荐下列的可靠的方案来解决多线程的问题：
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

## 针对类的钩子的线程安全.
- 如果你没有对针对类的钩子进行解绑操作的需求，忽略此处说明。
- 针对类的钩子是线程安全的。
- 对针类的钩子进行解绑操作建议在main()方法中实现apc_main_classHookFullSupport().
```objc

int main(int argc, const char * argv[]) {

    /*
        1.在应用启动器或在runtime加载前调用.
        2.该方法实现了删除runtiem中method的功能。如果不调用该方法则会采用模拟删除方法的策略，也就是用一个空方法来占据本应删除的方法，该方法将调用向父级传递。但是这会影响method swizzle，影响获取method ，影响从类中获取imp。具体表现在使用这几类沿着继承链查找方法相关的API的时候会获取到APC项目提供的占位方法。解决方案就是，使用准确的类型或者实现apc_main_classHookFullSupport()：
        class_replaceMethod(CorrectClass, ...);
        class_getInstanceMethod(CorrectClass, ...);
    */
    apc_main_classHookFullSupport();
    return ... ...(argc, argv);
}
```

## 可能会做
- 支持所有结构体类型，如果有需求的话。
- 动态边界

## 作者
- 紧急 : meterwhite@outlook.com


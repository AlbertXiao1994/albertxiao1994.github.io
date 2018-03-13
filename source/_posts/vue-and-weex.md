---
title: Vue和Weex——春招读书笔记（六）
date: 2018-03-12 12:32:17
categories: 前端
tags:
- Vue
- Weex
- Object.defineProperty
- 观察者模式
cover: http://wx3.sinaimg.cn/mw690/a98da548gy1fpa1oybt5pj20zk0p5jtq.jpg
---

## Vue数据绑定实现原理

![原理](http://wx1.sinaimg.cn/mw690/a98da548gy1fp9xl22hdoj20ns0chgmd.jpg)

一句话概括：利用Object.defineProperty重写数据的`setter`、`getter`，结合发布-订阅模式，当数据变化时，发布消息，调用回调函数更新视图。

它有三个核心模块：

* Observer：观测数据，发布消息。
* Compile：编译模板，添加订阅者，绑定更新函数。
* Watcher：产生订阅者实例，执行绑定的回调函数更新视图。

### Observer
它通过`defineReactive()`函数递归给`data`的属性、子属性设置`setter`、`getter`。在`setter`、`getter`里通过一个Dep对象实现发布-订阅功能。Dep对象实例有一个订阅者集合数组，以及一个`notify`方法。

每个订阅者是一个订阅者，都是一个Watcher对象实例，对应Vue里定义的一条数据。

当设置新值时将会调用`notify`方法，它会依次触发订阅者的`update`函数。

那我们来看看Watcher实例又是如何关联节点的呢？奥秘在`Compile`里。

### Compile

它干三件事：

 将挂载节点下的所有子节点加入`documentFragment`。
 编译模板，给每条数据新建一个Watcher实例，绑定更新回调函数。
 将批处理后的`documentFragment`一次性插入挂载的根节点。

重点讲讲它是如何编译模板的。

它遍历每一子节点，依次取出它的所有属性attribution。如果是指令，通过`substring(2)`取出指令类型，通过正则表达式取出指令内容。对于事件指令，则注册给该节点注册事件；如果是其他类型的，则生成一个Watcher实例，传入Vue实例，数据，回调。

Watcher实例化时，会调用自身的`get`方法，它通过将Dep.target属性临时赋值为当前Watcher实例。这样就建立起了订阅者与节点的关系。

### Watcher

每个Watcher都有一个`update`方法，前面已经说过了，它在数据更新时将会调用，而它将会执行更新视图的回调函数，实现视图响应数据变化。

## Weex

区别：浏览器，HTML，客户端，JS Bundle，还需适配和页面生命周期相关的行为，如创建、刷新、销毁。

解决平台接口差异：
提供Weex DOM API适配不同前端框架，针对Weex和浏览器也调用不同的接口实现跨平台渲染。根据VDOM构建渲染指令树，它是遵照W3C标准对DOM的精简。它可以序列化为JSON格式以渲染指令的形式发送给原生渲染引擎。

不同的 Weex 页面对应到浏览器上就相当于不同的“标签页”， 在 JS Framework 中实现了[JS Service](http://weex-project.io/cn/references/js-service.html)的功能，主要就是用来解决跨页面复用和状态共享的问题的。

事件传递：

Vue调用JS Framework提供的addEvent将事件类型、回调函数传递给JS Framework。
JS Framework在构建渲染树是，将事件类型添加至节点中。将在原生组件上将监听这一事件。事件触发时通过fireElemt节点信息回传给JS Framework，在JS Framework里执行。

这种方式效率很低，可能一次触发多次执行回调。可以表达式绑定将回调以字符串的形式直接传给客户端。
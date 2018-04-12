---
title: React新的生命周期
date: 2018-04-12 20:30:34
categories: 前端
tags:
- React
- 生命周期
cover: http://wx4.sinaimg.cn/mw690/a98da548gy1fqa5getgnij20i20c8dfy.jpg
---

这张图非常清楚地说明了React 16.3后的生命周期：

![新生命周期](http://wx2.sinaimg.cn/mw690/a98da548gy1fq8n7mtwcoj20j60d175l.jpg)

## static getDerivedStateFromProps()

这个新的方法的主要作用，从它的名字中能看出：从`props`中生成新的`state`。

它通过返回一个对象来更新`state`，而不是以前的调用`setState` API。如果`state`的更新不依赖于属性变化，那么

以前，我们要拿到新的属性，一般通过`componentWillReceiveProps`。现在React推荐使用`getDerivedStateFromProps`，而`componentWillReceiveProps`将在17版里移除。

从上面这个图中可以看到，它跨越了两个阶段：组件挂载和组件更新阶段。

### 组件挂载阶段

它在组件实例后调用，用于从`props`中生成初始的`state`；

另一种情况是，父组件重新渲染了。这时，即使属性没有更新，它也会被调用。

### 组件更新阶段

最常用的使用场景，就是组件接受新属性。

## getSnapshotBeforeUpdate()
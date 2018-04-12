---
title: 为什么出现React们
date: 2018-04-10 09:14:22
categories: 前端
tags:
- React
- Vue
- 组件化
- VDOM
cover: http://wx3.sinaimg.cn/mw690/a98da548gy1fq7cqpxvjxj20go0bwabc.jpg
---

{% note info %}

前端发展史上，前端框架层出不穷。如今，最流行的当属React、Vue。那为什么是它们？

{% endnote %}

有人算过，前端框架目前还活着的有54种。[了解详情](https://javascriptreport.com/the-ultimate-guide-to-javascript-frameworks/)

![活着的框架](http://wx3.sinaimg.cn/mw690/a98da548gy1fq7b2fqyrkj20dx0nvtc1.jpg)

从JQuery到Backbone，再到现在的React、Vue，Why？

**我的理解原因主要是以下三点：**

* **数据驱动视图**

* **组件化开发**

* **虚拟DOM**

## 数据驱动视图

原来的JQuery之类，它主要是对原生JS的一层封装。只能说是类库，还不能说是框架。框架应该提供一套解决方案。

将逻辑与UI解耦的事，Backbone们就在做。但把这事做得彻底还是现在的三巨头：React、Vue、Angular。

视图由数据驱动，开发者将只需关注变动数据，而更新视图的工作框架来帮你做。

在Vue中，通过`Dep`和`Watcher`，进行数据依赖收集和绑定视图更新方法。

在React中，当`props`和`state`变化时，重新构建虚拟DOM，通过diff比较进行视图更新。

## 组件化开发

类库式的开发模式，将逻辑和UI耦合，使逻辑和UI都很难复用。

在大规模协作开发的背景下，组件式开发更是刚需。

因此，React们都采用了组件式开发的模式。

## 虚拟DOM

虚拟DOM，是React的一个首创。Vue在2.0后也引入了它。

DOM是很慢的，每个节点都有很多的属性和方法。甚至连注释都是一个节点。以前，调用DOM API将会导致DOM树的重新创建，这是一件开销很大的事情。

因此，虚拟DOM应运而生，按需分配。按需分配，是共产社会的追求，也是现在各种人工智能、大数据的最终目标。

引入了虚拟DOM，使用对象来描述DOM节点，只需要更新真正变化了那部分视图，将开销降低到了最小。


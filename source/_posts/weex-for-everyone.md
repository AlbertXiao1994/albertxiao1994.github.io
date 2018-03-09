---
title: Weex! This is for everyone
date: 2018-03-06 09:40:50
categories: 前端
tags:
- weex
- vue
cover: http://wx1.sinaimg.cn/mw690/a98da548gy1fp2fzv06njj20ge0960tl.jpg
---

{% note info %}

Weex，一个让我神往已久的技术。终于到了可以谈一谈的地步。接触weex5天了，坑踩了不少，差不多可以算入门了吧！正式说它之前先谈谈web吧！

{% endnote %}

## 前言
web开发技术完全可以说是人类历史上的大量优秀科学家、工程师理论与实践的结果，特别能体现互联网精神：共享、开放。它自诞生之日起，就担负着传播人类文化知识的重任。可以说，web完全不输于人类历史上那些响当当的重要发明，比如：蒸汽机、电灯、智能手机。

如果说，我崇拜谁呢，就蒂姆·伯纳斯·李绝对算一个。当初看央视的纪录片[《互联网时代》](http://tv.sohu.com/20140827/n403819720.shtml)，一个场面让我叹为观止：蒂姆·伯纳斯·李在2012年当你编写世界上第一个web服务器和客户端的电脑上敲出“This is for everyone”。

![《互联网时代》1](http://wx1.sinaimg.cn/mw690/a98da548gy1fp2cenpipej20fi08aq3b.jpg)

![《互联网时代》2](http://wx1.sinaimg.cn/mw690/a98da548gy1fp2cen7kw5j20fh08vdgu.jpg)

太帅了！

## 为什么是Weex？

web开放包容、跨平台的特性，带来了互联网的繁荣，但它也有天生的缺点：

* 各浏览器厂商对JS标准的实现不同，导致了兼容性问题；

* 每次打开网页需要去远程下载，天然地慢一拍；

* DOM设计的缺陷，每次更新页面浏览器需要进行大量的操作。

在移动互联时代，第一个问题已不那么明显。后两个问题，无法根治。只能不断优化，对于第二个问题一般是采取减小请求数、缓存的机制；对于最后一个问题，现在比较流行的做法是Facebook最早在React中运用的虚拟DOM，还有通过Canvas图的方式。

而移动互联时代绝对主角——原生应用，它安装在本地，直接运行在系统中，具有高性能，那它有什么缺点呢？主要有二：

* 平台差异：同一产品一般至少需要开发web、android、ios三端，需要三波开发团队；

* 上线周期慢：一款应用上线一般需要一到几周，而这对时机稍纵即逝的互联网圈基本是不能容忍的。

如果有一个解决方案具有web跨平台、社区繁荣的优点，又兼备原生应用的高性能就好了。

今天的主角该出场了：Weex们。

## 闪亮登场

Weex们，是社区中诞生的使用web开发过程开发端应用的技术。

通俗说，就是写一套web前端代码，编译成web、android、ios三端都可用的应用。

之所以加“们”，是因为除了Weex，社区还有现在最流行的React Native。

## 一探究竟

我在原来学习Vue时做的项目中，选了个难度适中的来做weex重构。

### 效果

![效果](http://wx4.sinaimg.cn/mw690/a98da548gy1fp2bbgf623j20xy0cago3.jpg)

项目源码：[weex-eleme](https://github.com/AlbertXiao1994/weex-eleme)
### 名存实亡的标签

weex中，基本上可以说没有标签一说。

weex只支持一组内置的组件和在内置组件的基础上自定义的组件。

如果你要写一个weex，首先要做的就是把原来习惯的所有文本相关的标签换成`<text>`，图片相关的换成`<image>`。

### CSS的差异

weex中只支持单个类名，不允许使用关系选择器来定义类名。这一点官方文档里并没有说，但确是网友们踩坑总结出来的经验。

``` css
// 单个类名，允许
.a {
  color: #fff;
 }

// 关系选择器，无效
.a .b {
  color: #000;
}
```

社区里有人成功地通过安装开发依赖和配置webpack的module选项使用了向sass这样的样式预处理器，也有说weex集成了常用的几种css预处理器，直接使用下面这样的标签写样式就行：

```vue
<style lang="sass" scope>
```

### 动态绑定类名

在Vue中，我们通常像下面这样动态绑定类名：

```vue
// 在weex中，类名可以成功加到渲染后的标签属性中，但样式不起作用
<div class="nav" :class="{active: flag}"></div>
```

这是个比较奇怪的坑，最后找到一个解决方案：

```vue
// 使用数组语法，数组里可以是三目运算或者函数调用
<div class="nav" :class="[flag?'active':'']"></div>
```

### 元素内联

weex中，`<text>`会被渲染成`<p>`，`<image>`会被渲染出`<figure>`，所有的`display`属性无法使用。如果你需要达到元素内联的效果，那你可以使用FlexBox：

```vue
 <div class="wrapper">
    <text>some text</text>
    // image必须设置宽高
    <image
      style="width: 300;height: 300;border-width:2px;"       
      src="https://cn.vuejs.org/images/logo.png1
    >
    </image>
  </div>

.wrapper {
  flex-direction: row;
 }
```

### scroller、list组件的坑

weex提供了一个高效的适合显示长列表的`<list>`组件。它在加载包含大量图片的场景下威力就发挥出来了。

它初始时只会加载首屏的图片，在快滚到底部时再去请求新的图片。但，你**必须给`<list>`（或者`<scroller>`）设置一个高度**（水平使用时设置宽度）。

这个坑我是深有感受，没有给`<list>`设置高度，你滚动时`<list>`总是也到不了底部，下部的图片时不会加载的，而且`scrollElement`方法是不会奏效的。

![list原理](http://wx3.sinaimg.cn/mw690/a98da548gy1fp2f8fgaaij20n20hkjrx.jpg)

如图所示，你设置的是wrapper的高度，wrapper不动，而content长度是超出wrapper的，你滚动时其实只是content在相对wrapper变化。只有这样，才能获取content相对于wrapper的位置，进行`loadmore`、`scrollElement`等事件或方法。

不然，wrapper的高度是被content撑开的，那它们就一起滚动了。

### 文本截断

在官方的示例中，可以给`<text>`设置`lines`属性限制文本的行数：

![官方示例](http://wx3.sinaimg.cn/mw690/a98da548gy1fp2fkqxoe3j20vp0isq3s.jpg)

其中有一个错误，就是`lines`设置再标签上是没有用的，**只有通过类名指定才会起效**。

然而，我电脑上并没有什么用！囧。

如果你的电脑也不起效，你可以向下面这样：

```vue
<text class="text">
  some text some text some text some text some text some text
</text>

.text {
  // 设置在css里，不一定起效
  lines: 1
  // 替代方案，官方示例渲染后的真实属性
  -webkit-line-clapm: 1;
}
```

### 占坑

bug常有，坑常有，来日填。
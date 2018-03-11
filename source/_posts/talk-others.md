---
title: 杂七杂八——春招读书笔记（四）
date: 2018-03-11 16:00:31
categories: 前端
tags:
- vue
- ES6
- HTTP
cover: http://wx2.sinaimg.cn/mw690/a98da548gy1fp97bxb7m7j215o0rsto6.jpg
---

## data必须是个函数

一个常见的问题，就是为什么data必须是个函数。

可是，这个问题并不是一定成立的。它得在组件中才有意义。

官方文档说：

> 在组件中，多数的组件选项可以传递给Vue构造函数，然后共享于多个组件实例，然而有一个特例：data 必须是一个函数。

这句话有点隐晦，应该data不是定义在构造函数中，而是定义在原型中。

如果像下面这样：

```js
Vue.component('my-component', {
  template: '<span>{{ message }}</span>',
  data: {
    message: 'hello'
  }
})
```

直接将data定义为一个引用类型的值，那就会出现原型中的经典问题——对该值的操作，为所有实例共享。

因此，Vue有个规避设计。这样写直接报错，告诉你必须是一个函数，无法运行。

但是有种方法可以悄无声息的通过检查，但却导致错误的运行结果：

```js
var data = { counter: 0 }

Vue.component('comp', {
  data: function () {
    return data
  }
})
```

它把`data`定义为一个函数，但实际运行时却因为返回的是同一个对对象的引用，还是那个问题。

最后，解决方案就是，直接返回一个新对象。

```js
Vue.component('comp', {
  data: function () {
    return {
      counter: 0
    }
  }
})
```

其实，第二种错误只是文档为了帮助我们理解，实际使用时一般不会这么做。


## get和post的区别

* 1）get主要用于获取数据，post主要用于新增数据

* 2）get使用cookie或者url传数据，而post使用实体主体。

* 3）get有长度限制，post则可以很大。

* 4）get数据外漏，不安全。

* 5）get具有幂等性，多次请求，同结果。


## ES6模块与CommonJS模块有什么区别

* 1）前者是编译时输出接口，后者是运行时加载。

* 2）前者是值引用，后者是值复制。


关于第一点，前者是静态解析时得到一个引用，后者是运行时创建一个`module.exports`对象。

关于第二点，前者是得到一个引用，那模块内部的变化就可得到。因此，在不同地方加载得到的是同一个实例。

而对于CommonJS模块，基本数据类型的值，无法获得实时的值:

```js
// lib.js
var counter = 3;
function incCounter() {
  counter++;
}
module.exports = {
  counter: counter,
  incCounter: incCounter,
};


// main.js
var mod = require('./lib');

console.log(mod.counter);  // 3
mod.incCounter();
console.log(mod.counter); // 3
```

在`main.js`中，`mod`是原模块的一份复制，`couter`的值得到后就不会变了。

## viewport

在做移动web时，我们经常使用下面这样的头：

```HTML
<meta name="viewport" content="width=device-width;initial-scale=1.0;max-scale=1.0;min-scale=1.0;user-scalable=no">
```

下面一一讲讲我的理解：

`width=device-width`：设置的是布局视口的宽度等于设备的dip宽度。这个值在媒体查询时发挥作用。

`*-scale=1.0`：这个`sacle`，等于设备的dip与web里的dip的比值。

那dip是什么呢？逻辑像素。CSS的1px就是1个逻辑像素。而它控制设备的几个物理像素，得根据dpr的值来定。而不同设备（PC和移动端）的dip是不一样的，我们通过设置这个`scale`得到了他们的关系。

## CSS草图布局

草图布局是首屏优化的一大方法，我们再支付宝、饿了么中可以看到。通过给元素设置`:empty`伪类样式，即可避免白屏：

```HTML
<div class="wrapper"></div>

wrapper:empty {
  margin: auto;
  width: 500px;
  height: 600px;

  background-image:
      radial-gradient( circle 50px at 50px 50px, lightgray 99%, transparent 0),
      linear-gradient( 100deg, rgba(255, 255, 255, 0), rgba(255, 255, 255, 0.5) 50%, rgba(255, 255, 255, 0) 80% ),
      linear-gradient( lightgray 20px, transparent 0 ),
      linear-gradient( lightgray 20px, transparent 0 ),
      linear-gradient( lightgray 20px, transparent 0 ),
      linear-gradient( lightgray 20px, transparent 0 );

    background-repeat: repeat-y;

    background-size:
      100px 200px, /* circle */
      50px 200px, /* highlight */
      150px 200px,
      350px 200px,
      300px 200px,
      250px 200px;

    background-position:
      0 0, /* circle */
      0 0, /* highlight */
      120px 0,
      120px 40px,
      120px 80px,
      120px 120px;
}
```

![草图布局](http://wx3.sinaimg.cn/mw690/a98da548gy1fp93843kddj20el07tq2q.jpg)

## XSS和CSRF

XSS：跨站脚本攻击，就是想办法在你的电脑上执行脚本获取cookie。

防范：

* 过滤用户输入，过滤掉除了合法值以外的所有。

* 进行HTML编码。

* 设置cookie的httpOnly属性。

* 对url进行编码，过滤。

CSRF：跨站请求伪装，主要就是通过图片`src`的形式，诱导你的浏览器去加载它，并将cookie上传。

防范：

* 检查referer。

* 设置验证码。

* 将请求方法限制为POST。

* 设置token。

## Event Loop

![事件循环](http://www.ruanyifeng.com/blogimg/asset/2014/bg2014100802.png)

1. JS引擎通过执行栈去执行同步代码

2. 对同步代码里的异步API，如I/O操作、点击、滚动，只将请求发出，而将它回调函数挂起。

3. 异步任务完成后，以事件的形式加入“任务队列”

4. 执行栈同步代码执行完成后，去遍历执行“任务队列”里事件的回调函数。

5. 这一过程循还往复。
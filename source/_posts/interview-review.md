---
title: Interview Review
date: 2018-03-22 11:19:22
categories: 前端
tags:
- 递归
- CSS
cover: http://wx3.sinaimg.cn/mw690/a98da548gy1fplfmo4ozrj21400gcmyd.jpg
---

{% note info %}

昨天面了一个下午，强度可真大，车轮战，4轮，3个半小时。暴露了一些问题，在此自我复查下。

{% endnote %}

## 你真的懂递归？

我遇到这样一题：

> 不使用`for`和`while`，实现一个函数prefill(n, v)：返回一个数组a = [v, v, ..., v]，其中含有n个v。

当时想到了用递归实现，但卡在了递归调用上。

先上递归的经典例子：

```js
// 求阶乘
function factorial(n) {
  if (n === 1) {
    return n;
  }
  return n*factorial(n-1)
}
```

递归，其实都有一样的套路。先是终止条件，然后递归调用：
```js
function prefill(n, v) {
  var arr = [];

  function recurse(k) {
    if (k === 0) {
      return arr;
    }
    arr[arr.length] = v
    return recurse(k-1);
  }
  
  // 递归调用
  recurse(n)

  return arr;
}

prefill(5, 1) // [1, 1, 1, 1, 1]
```
递归还有一个尾递归优化，像上面的求阶乘的函数：

```js
function factorial(n, total) {
  if (n === 1) {
    return total;
  }
  return factorial(n-1, n*total)
}

factorial(5, 1)  // 120
```

将一个递归函数改成尾递归，仅需将原来使用到的局部变量变成函数参数。这样系统仅需保存一个调用记录，而不用维护一个庞大的调用栈，防止了内存溢出。

## CSS优先级

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Document</title>
  <style>
    /*.text {
      color: red;
    }*/
    #parent .em {
      color: green;
    }
    .child .em {
      color: black;
    }
  </style>
</head>
<body>
  <div class="parent" id="parent">
    <div class="child" id="child">
      <div class="em">
        <p class="text">Hello World</p>
      </div>
    </div>
  </div>
</body>
</html>

// 为红色
```
针对上面的例子，可以总结出几点规则：

### 1. 指定样式优先于继承样式

就像上面这样。

### 2. 离得近的继承样式优先级高

加入内部样式像这样：

```HTML
<style>
  .parent {
    color: green;
  }
  .child {
    color: black;
  }
<.style>
// 黑色
```

### 3. 权重大的选择器优先级高

有这么一个规则：

继承<通用选择器<元素选择器<类选择器=属性选择器=伪类<ID选择器<内联样式

```HTML
<style>
  #child {
    color: green;
  }
  .child {
    color: black;
  }
<.style>

// ...
<div class="child" id="child">
  <div class="em" id="em">
    <p class="text">Hello World</p>
  </div>
</div>

// 绿色
```

属性选择器=类选择器=伪类：
```HTML
<style>
  .text {
    color: green;
  }
  [class="text"] {
    color: red;
  }
  .text:hover {
    color: black;
</style>

// ...
<p class="text">Hello World</p>

// 起初：红色；悬停：黑色
```

### 4. 隔代距离不影响优先级

```HTML
<style>
  .parent .em {
    color: green;
  }
  .child .em {
    color: black;
  }
<.style>

// ...
<div class="parent" id="parent">
  <div class="child" id="child">
    <div class="em" id="em">
      <p class="text">Hello World</p>
    </div>
  </div>
</div>

// 黑色
```

### 5. 直接计算优先级

以上四点，基本够日常使用。但有时会出现些特殊情况，我们可以通过计算优先级来比较：

权重：

* 内联样式：1000
* ID选择器：100,出现了a次
* 类选择器=属性选择器=伪类：10,出现了b次
* 元素选择器：1,出现了c次
* 通用选择器：0

优先级=100a+10b+c

你猜下面这个是什么结果：

```HTML
<style>
  #child .text {
    color: red;
  }
  #em p {
    color: green;
  }
</style>

// ...
<div class="child" id="child">
  <div class="em" id="em">
    <p class="text">Hello World</p>
  </div>
</div>

// 红色
```

第一组选择器的优先级=100+10=110

第二组选择器的优先级=100+1=101

有了上面5条大法，基本够用了。妈妈再也不用担心我的样式覆盖错乱了。

## 声明提升

```js
F = 0;
function F() {}
var F = 11;

console.log(typeof F) // 'number'
console.log(F) // 11
```

变量、函数声明都会提升到当前作用域的顶部。所以，上面这个例子相当于：

```js
function F() {}
var F;
F = 0;
F = 11;
```

## 再谈异步编程

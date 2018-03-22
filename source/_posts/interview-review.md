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

## 手写代码

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

递归，都是这样的套路：
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

  

## 声明提升

---
title: 异步编程——春招读书笔记（五）
date: 2018-03-11 21:15:22
categories: 前端
tags:
- Promise
- Generator
- async
cover: http://wx3.sinaimg.cn/mw690/a98da548gy1fp97c62vb8j20xc0iiwhp.jpg
---

## ES5异步编程

* 回调函数

* 注册事件

* 发布-订阅模式

* Promise（我并没有在ES5接触过）

## ES6异步编程

### Promise

它有三种状态：`pending`、`fullfilled`、`reject`。

用法：

```js
let promise = new Promise(function() {
  $.getJSON('url', function(data)
  resolve(data))
  })

promise.then((res) => {
  console.log(res.data)
  })
```

有一点需要注意：

```js
setTimeout(function () {
  console.log(3);
}, 0);

new Promise((resolve, reject) => {
  resolve(4);
  console.log(2);
}).then(r => {
  console.log(r);
});

console.log(1);

// 2
// 1
// 4
// 3
```

它的参数函数是同步执行的，所以最早打印4，接着是同步打印1。

这个`Promise`是直接`resolve`的，它将在本轮事件循环的结束时执行，而`setTimeout`将在下一轮事件循环的开始时执行。

### generator函数

```js
function * gen() {
  yield '1'
  yield '2'
  return '3'
}

var g = gen()

g.next() // {value: '1', done: false}
g.next() // {value: '2', done: false}
g.next() // {value: '3', done: true}
```

执行generator函数返回Iterator对象。调用`next`方法控制它的进行。

再上自动执行器，它就可以完成自动完成异步操作。

有两种方法：

* Thunk函数

* Co模块

Thunk函数把多参数函数变成单参数函数，而这个参数就是异步回调。如下面定义一个用于异步读取文件的Thunk函数：

```js
const Thunk = function (fn) {
  return function(...args) {
    return function(callback) {
      return fn.call(this, ...args, callback)
    }
  }
}

var readFileThunk = Thunk(fs.readFile)

// 调用
readFileThunk('./1.png')(callback)
```

定义我们需要的生成器函数：

```js
var gen = function* (){
  var r1 = yield readFileThunk('/etc/fstab');
  console.log(r1.toString());
  var r2 = yield readFileThunk('/etc/shells');
  console.log(r2.toString());
};
```

那怎么让它自动执行呢？

```js
function run (fn) {
  // 返回迭代器对象，指针在生成器函数头部
  var gen = fn()

  // next为异步操作的回调函数
  function next(err, data) {
    var result = gen.next(data);
    if (result.done) return;
    // 传入回调函数，执行
    result.value(next);
  }

  next();
}

run (gen)
```
还可以通过Co模块实现自动化。

它有两种方法：一是通过`Promise`，而是通过`Thunk`。

讲讲`Promise`怎么实现。关键点两个：一是`yield`返回`Promise`；二是next函数里通过`then`继续进行。

```js
var fs = require('fs');

var readFile = function (fileName){
  return new Promise(function (resolve, reject){
    fs.readFile(fileName, function(error, data){
      if (error) return reject(error);
      resolve(data);
    });
  });
};

var gen = function* (){
  var f1 = yield readFile('/etc/fstab');
  var f2 = yield readFile('/etc/shells');
  console.log(f1.toString());
  console.log(f2.toString());
};
```

上面是第一个关键点。

```js
function run(gen){
  // 返回迭代器对象，指针在生成器函数头部
  var g = gen();

  function next(data){
    var result = g.next(data);
    if (result.done) return result.value;
    // 给它注册then方法，传入next方法，执行promise
    result.value.then(function(data){
      next(data);
    });
  }

  next();
}

run(gen);
```

### async函数

async函数它就是generate函数的语法糖。

```js
const asyncReadFile = async function () {
  const f1 = await fs.readFile('./1.txt')
  const f2 = await fs.readFile('./2.txt')
}
```

它更加简洁、语义化，自动执行，而且返回`Promise`对象。

而它的原理，就是Co模块的`Promise`式嘛

好了，到此你就可以愉快地异步编程了！
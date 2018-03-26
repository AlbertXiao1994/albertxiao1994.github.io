---
title: setState后发生了什么——春招读书笔记（七）
date: 2018-03-26 09:58:33
categories: 前端
tags:
- React
- setState
cover: http://wx2.sinaimg.cn/mw690/a98da548gy1fppzz6oz81j20m80ci0tw.jpg
---

关于`setState`的批处理，有个经典的问题：

```js
class Example extends React.Component {
  constructor() {
    super();
    this.state = {
      val: 0
    };
  }
  
  componentDidMount() {
    this.setState({val: this.state.val + 1});
    console.log(this.state.val);    // 第 1 次 log

    this.setState({val: this.state.val + 1});
    console.log(this.state.val);    // 第 2 次 log

    setTimeout(() => {
      this.setState({val: this.state.val + 1});
      console.log(this.state.val);  // 第 3 次 log

      this.setState({val: this.state.val + 1});
      console.log(this.state.val);  // 第 4 次 log
    }, 0);
  }

  render() {
    return null;
  }
};

// 输出0,0,2,3
```

在网上看了很多博客，但没有一个完全讲清楚的。

下面说说我的理解。



`batchingStrategy`对象里的事务`transaction`，这个事务的`wrapper`长这样：

```js
var RESET_BATCHED_UPDATES = {
  initialize: emptyFunction,
  close: function() {
    ReactDefaultBatchingStrategy.isBatchingUpdates = false;
  },
};

var FLUSH_BATCHED_UPDATES = {
  initialize: emptyFunction,
  close: ReactUpdates.flushBatchedUpdates.bind(ReactUpdates),
};
```

可以看到，一个事务可以有多个`wrapper`，依次执行。

## 1、`this.setstate`

我们调用`setstate`，实际上干了这么一件事：

```js
ReactComponent.prototype.setState = function(partialState, callback) {
  ...
  this.updater.enqueueSetState(this, partialState);
  if (callback) {
    this.updater.enqueueCallback(this, callback, 'setState');
  }
};
```
里面的`updater`是一个`ReactUpdateQueue`对象，它在组件初始化时被注入。

## 2、 `enqueueSetState`

它将新的局部`state`放入当前组件实例的`_pendingStateQueue`，之后调用`enqueueUpdate`：

```js
enqueueSetState: function(publicInstance, partialState) {
  ...

  var internalInstance = getInternalInstanceReadyForUpdate(
    publicInstance,
    'setState'
  );

  if (!internalInstance) {
    return;
  }

  var queue =
    internalInstance._pendingStateQueue ||
    (internalInstance._pendingStateQueue = []);
  queue.push(partialState);

  enqueueUpdate(internalInstance);
}
```

那`enqueueUpdate`函数起什么作用呢？

## 3、`enqueueUpdate`

```js
function enqueueUpdate(component) {
  ensureInjected();

  ...

  if (!batchingStrategy.isBatchingUpdates) {
    batchingStrategy.batchedUpdates(enqueueUpdate, component);
    return;
  }

  dirtyComponents.push(component);
  if (component._updateBatchNumber == null) {
    component._updateBatchNumber = updateBatchNumber + 1;
  }
}
```

它的核心功能是：判断当前是否是批处理状态，如果不是，则将`enqueueUpdate`作为事务的回调执行。

你可能会好奇事务是什么？

事务的功能就是提供一个`wrapper`包装一个函数，使得能在函数执行前后通过`initial`、`close`方法执行一些逻辑。

一个事务的执行流程：`initial`-->`callback`-->`close`。

`enqueueUpdate`注入了两个依赖，其中一个很重要的就是下面的`batchingStrategy`。

## 4、`batchedUpdates`

可以看到，它有一个
```js
var ReactDefaultBatchingStrategy = {
  isBatchingUpdates: false,

  batchedUpdates: function(callback, a, b, c, d, e) {
    var alreadyBatchingUpdates = ReactDefaultBatchingStrategy.isBatchingUpdates;

    ReactDefaultBatchingStrategy.isBatchingUpdates = true;

    // The code is written this way to avoid extra allocations
    if (alreadyBatchingUpdates) {
      return callback(a, b, c, d, e);
    } else {
      return transaction.perform(callback, null, a, b, c, d, e);
    }
  },
};
```

6. `flushBatchedUpdates`

7. `runBatchedUpdates`

8. `ReactReconciler.performUpdateIfNecessary`

9. `updateComponent`

10. `_processPendingState`

11. `_performComponentUpdate`


## 参考资料

1. [React 源码剖析系列 － 解密 setState](https://zhuanlan.zhihu.com/p/20328570)

2. [Batch Update 浅析](https://zhuanlan.zhihu.com/p/28532725)

3. [React setState 解读](https://www.lxxyx.win/2018/01/13/2018/setstate/)

4. [拆解setState[一][一源看世界][之React]](https://www.jianshu.com/p/47f24add2b5e)

5. [拆解setState[二][一源看世界][之React]](https://www.jianshu.com/p/d392d6bd8f05)

6. [拆解setState[三][一源看世界][之React]](https://www.jianshu.com/p/3965c4bdc1ea)
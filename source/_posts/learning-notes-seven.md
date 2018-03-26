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

它的核心功能是：判断当前是否是批处理状态，如果不是，则将`enqueueUpdate`作为事务的回调执行，并将当前组件加入`dirtyComponents`数组。

你可能会好奇事务是什么？

事务的功能就是提供一个`wrapper`包装一个函数，使得能在函数执行前后通过`initial`、`close`方法执行一些逻辑。

一个事务的执行流程：`initial`-->`callback`-->`close`。

`enqueueUpdate`注入了两个依赖，其中一个很重要的就是下面的`batchingStrategy`。

## 4、`batchedUpdates`

可以看到，它有一个`isBatchingUpdates`，标志当前是否处于批量更新阶段。

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

`batchingStrategy`对象里有个事务`transaction`，它的`wrapper`长这样：

```js
// 函数执行后重置标志isBatchingUpdates
var RESET_BATCHED_UPDATES = {
  initialize: emptyFunction,
  close: function() {
    ReactDefaultBatchingStrategy.isBatchingUpdates = false;
  },
};

// 函数执行后执行批量更新
var FLUSH_BATCHED_UPDATES = {
  initialize: emptyFunction,
  close: ReactUpdates.flushBatchedUpdates.bind(ReactUpdates),
};
```

可见，一个事务可以有多个`wrapper`，依次执行。

6. `flushBatchedUpdates`

```js
var flushBatchedUpdates = function() {
  while (dirtyComponents.length || asapEnqueued) {
    if (dirtyComponents.length) {
      var transaction = ReactUpdatesFlushTransaction.getPooled();
      // 关键
      transaction.perform(runBatchedUpdates, null, transaction);
      ReactUpdatesFlushTransaction.release(transaction);
    }

    if (asapEnqueued) {
      asapEnqueued = false;
      var queue = asapCallbackQueue;
      asapCallbackQueue = CallbackQueue.getPooled();
      queue.notifyAll();
      CallbackQueue.release(queue);
    }
  }
};
```

这个方法当`dirtyComponents`长度大于0时，执行“刷新事务”，调用`runBatchedUpdates`方法。

## 6、`runBatchedUpdates`

```js
function runBatchedUpdates(transaction) {
  // ...
  for (var i = 0; i < len; i++) {
    var component = dirtyComponents[i];
    // ...
    ReactReconciler.performUpdateIfNecessary(
      component,
      transaction.reconcileTransaction,
      updateBatchNumber,
    );
    // ...
  }
}
```

它的核心功能是依次对“脏组件”执行`performUpdateIfNecessary`。

## 7、`performUpdateIfNecessary`

```js
performUpdateIfNecessary: function(
    internalInstance,
    transaction,
    updateBatchNumber
  ) {
    ...
    internalInstance.performUpdateIfNecessary(transaction);
    ...
  }
```

而它其实调用实例本身的`performUpdateIfNecessary`方法。

## 8、`updateComponent`

```js
performUpdateIfNecessary: function(transaction) {
    if (this._pendingElement != null) {
      ReactReconciler.receiveComponent(
        this,
        this._pendingElement,
        transaction,
        this._context
      );
    } else if (this._pendingStateQueue !== null || this._pendingForceUpdate) {
      this.updateComponent(
        transaction,
        this._currentElement,
        this._currentElement,
        this._context,
        this._context
      );
    } else {
      this._updateBatchNumber = null;
    }
  }
```

它核心的是`updateComponent`方法。

## 9、`updateComponent`

```js
updateComponent: function(
    transaction,
    prevParentElement,
    nextParentElement,
    prevUnmaskedContext,
    nextUnmaskedContext
  ) {
    var inst = this._instance;
    ...

    var willReceive = false;
    var nextContext;
    var nextProps;

    // Determine if the context has changed or not
    if (this._context === nextUnmaskedContext) {
      nextContext = inst.context;
    } else {
      nextContext = this._processContext(nextUnmaskedContext);
      willReceive = true;
    }

    nextProps = nextParentElement.props;

    // Not a simple state update but a props update
    if (prevParentElement !== nextParentElement) {
      willReceive = true;
    }

    // An update here will schedule an update but immediately set
    // _pendingStateQueue which will ensure that any state updates gets
    // immediately reconciled instead of waiting for the next batch.
    if (willReceive && inst.componentWillReceiveProps) {
      ...
      inst.componentWillReceiveProps(nextProps, nextContext);
      ...
    }

    var nextState = this._processPendingState(nextProps, nextContext);
    var shouldUpdate = true;

    if (!this._pendingForceUpdate && inst.shouldComponentUpdate) {
      ...
      shouldUpdate = inst.shouldComponentUpdate(nextProps, nextState, nextContext);
      ...
    }

    ...

    this._updateBatchNumber = null;
    if (shouldUpdate) {
      this._pendingForceUpdate = false;
      // Will set `this.props`, `this.state` and `this.context`.
      this._performComponentUpdate(
        nextParentElement,
        nextProps,
        nextState,
        nextContext,
        transaction,
        nextUnmaskedContext
      );
    } else {
      // If it's determined that a component should not update, we still want
      // to set props and state but we shortcut the rest of the update.
      this._currentElement = nextParentElement;
      this._context = nextUnmaskedContext;
      inst.props = nextProps;
      inst.state = nextState;
      inst.context = nextContext;
    }
  }
```

这个方法有三个功能：

* 判断`context`是否改变，改变则传入`nextContext`

* 比较父元素，判断`props`是否改变，改变则触发`componentWillReceiveProps`

* 通过`_processPendingState`更新`state`，根据`shouldComponentUpdate`的值决定是否调用`_pendingForceUpdate`更新组件。

## 10、`_processPendingState`

它是批量更新的关键：

```js
_processPendingState: function(props, context) {
    var inst = this._instance;
    var queue = this._pendingStateQueue;
    var replace = this._pendingReplaceState;
    this._pendingReplaceState = false;
    this._pendingStateQueue = null;

    if (!queue) {
      return inst.state;
    }

    if (replace && queue.length === 1) {
      return queue[0];
    }

    var nextState = assign({}, replace ? queue[0] : inst.state);
    for (var i = replace ? 1 : 0; i < queue.length; i++) {
      var partial = queue[i];
      assign(
        nextState,
        typeof partial === 'function' ?
          partial.call(inst, nextState, props, context) :
          partial
      );
    }

    return nextState;
  }
```

我们可以看到，它是通过`Object.assign`来更新`state`的。这样做有两点效果：

* 批量更新`state`

* 相同的`partialState`，只会作用一次

## 批量更新的核心实现

上面说了这么多，看得人头昏眼花，但都不足以实现批量更新。那批量更新的核心是什么呢？

**由React触发的事件都会被包装成“批量更新事务”**

```js
// ReactEventListener.js
dispatchEvent: function(topLevelType, nativeEvent) {
  if (!ReactEventListener._enabled) {
    return;
  }

  var bookKeeping = TopLevelCallbackBookKeeping.getPooled(
    topLevelType,
    nativeEvent,
  );
  try {
    // Event queue being processed in the same cycle allows
    // `preventDefault`.
    ReactUpdates.batchedUpdates(handleTopLevelImpl, bookKeeping);
  } finally {
    TopLevelCallbackBookKeeping.release(bookKeeping);
  }
}
```

我们可以看到，`React`派发事件时，会调用`batchedUpdates`。

## 总结

说到这我们可以来理一理了：

1. 初始时，`isBatchingUpdates`为`false`。

2. 我们通过`React`调用一个函数，如`componentDidMount`，它将被作为事务回调。

3. 执行`batchedUpdates`，`isBatchingUpdates`置为`true`，执行函数的内部逻辑。

4. 函数内部的若干个`this.setstate`依次，这时由于`isBatchingUpdates`置为`true`,相关组件被标记为“脏组件”。

5. 当函数执行完毕时，`isBatchingUpdates`置为`false`，执行`flushBatchedUpdates`批量更新`state`，组件更新。

6. 当函数被的异步操作完成后，调用的`this.setstate`，此时`isBatchingUpdates`为`false`，`enqueueUpdate`作为事务回调。

7. isBatchingUpdates`置为`false`，`enqueueUpdate`再次执行，当前组件被标记为“脏组件”，回调执行完毕，调用`close`，执行
`flushBatchedUpdates`直接更新`state`

至此，就完整解释了`this.setstate`的原理。

## 参考资料

1. [React 源码剖析系列 － 解密 setState](https://zhuanlan.zhihu.com/p/20328570)

2. [Batch Update 浅析](https://zhuanlan.zhihu.com/p/28532725)

3. [React setState 解读](https://www.lxxyx.win/2018/01/13/2018/setstate/)

4. [拆解setState[一][一源看世界][之React]](https://www.jianshu.com/p/47f24add2b5e)

5. [拆解setState[二][一源看世界][之React]](https://www.jianshu.com/p/d392d6bd8f05)

6. [拆解setState[三][一源看世界][之React]](https://www.jianshu.com/p/3965c4bdc1ea)
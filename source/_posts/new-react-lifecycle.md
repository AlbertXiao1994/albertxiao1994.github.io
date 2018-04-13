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

![新生命周期](http://wx2.sinaimg.cn/mw690/a98da548gy1fqatwqb3y0j20ut0ia0ul.jpg)

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

从它的名字可以看出，它能够在组件更新前保存一份原组件的快照。

官方文档有这么一个例子来说明它的使用场景：

```js
class ScrollingList extends React.Component {
  listRef = React.createRef();

  getSnapshotBeforeUpdate(prevProps, prevState) {
    // 获取更新前的列表高度
    if (prevProps.list.length < this.props.list.length) {
      // 返回更新前的值
      return this.listRef.current.scrollHeight;
    }
    return null;
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    // 如在列表头部增加新项，调整scrollTop以防将旧的元素顶出视口
    if (snapshot !== null) {
      this.listRef.current.scrollTop +=
        this.listRef.current.scrollHeight - snapshot;
    }
  }

  render() {
    return (
      <div ref={this.listRef}>{/* ...contents... */}</div>
    );
  }
}
```

上面的例子通过记录更新前的滚动位置并进行相应的调整，保存了界面的原始状态。

原来，有个`componentWillUpdate`也能在组件更新前做一些操作。

不过似乎使用它会有一些问题。官方文档举了个例子：

> 如果一个用户在这期间做了像改变浏览器尺寸的事，从componentWillUpdate中读出的scrollHeight值将是滞后的。

而`getSnapshotBeforeUpdate()`则不存在这个问题，我的理解是因为它是在最新的渲染输出提交给DOM前调用，已经是最新状态了，只是没体现在DOM上。

从上面这个新的生命周期图中左侧的说明也能看出，它处于预提交阶段，完全可以读取“DOM”了。
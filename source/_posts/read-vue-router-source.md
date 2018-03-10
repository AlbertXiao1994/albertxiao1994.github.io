--- vue router的原理-春招读书笔记（一）
title: read-vue-router-source
date: 2018-03-10 15:45:14
categories: 前端
tags:
- vue
- vue router
- 观察者模式
cover: http://wx3.sinaimg.cn/mw690/a98da548gy1fp7rtyt75ij20xc0iraei.jpg
---

{% note info %}

找工作真是累，现在是感受到了。不但学习强度高，一刻不能懈怠，而且还要承受被面试官面到怀疑人生的境地。过两天就要一面了，在此总结下这段时间基础知识查缺补漏的一些难啃的骨头。但求有一个好人品，到时有一个好结果。

{% endnote %}

vue router有三种模式：hash、history、abstract。它们在新建Router实例时通过`mode`选项设置。

this.$router大家都很熟悉，根据我的理解，它其实是一个特殊的`history`实例。在路由实例初始化时，在构造函数中根据`mode`和程序运行的环境的支持情况，生成相应的`history`。如：

```js
// 根据mode确定history实际的类并实例化
    switch (mode) {
      case 'history':
        this.history = new HTML5History(this, options.base)
        break
      case 'hash':
        this.history = new HashHistory(this, options.base, this.fallback)
        break
      case 'abstract':
        this.history = new AbstractHistory(this, options.base)
        break
      default:
        if (process.env.NODE_ENV !== 'production') {
          assert(false, `invalid mode: ${mode}`)
        }
    }
```

所以，你调用`this.$router.push`其实是调用这个特殊的`history`的`push`方法。那`history.push`里发生了什么呢？

所有类型里的`history.push`大概长这样：
```js
push (location: RawLocation, onComplete?: Function, onAbort?: Function) {
  const { current: fromRoute } = this
  this.transitionTo(location, route => {
    // HashHistory
    pushHash(...params)
    // HTML5History
    // pushState()
    // 一些代码
    onComplete && onComplete(route)
  }, onAbort)
}
```

很明显了，就是通过各自的`this.transtionTo`方法去往抽象的历史状态队列中添加新状态。

```js
// HashHistory
function pushHash (path) {
  window.location.hash = path
}

// HTML5History
pushHash(...params) {
windows.history.pushState(stateObject, title, URL)
```

好了，现在历史状态更新了，那就要更新视图了。

刚才我们只是调用了`this.transitionTo()`方法，那它执行的结果是啥呢。随我进入实例`history`的构造函数里，它是一个观察者模式：

```js
transitionTo (location: RawLocation, onComplete?: Function, onAbort?: Function) {
  const route = this.router.match(location, this.current)
  this.confirmTransition(route, () => {
    this.updateRoute(route)
    ...
  })
}

updateRoute (route: Route) {
  // 发布
  this.cb && this.cb(route)
  
}

// 订阅
listen (cb: Function) {
  this.cb = cb
}
```

可见，调用它其实是发布了一个`route`或者说`location`。那它是在哪里订阅的呢？答：在路由实例初始化时。在VueRouter构造函数里有个`init`方法：

```js
init (app: any /* Vue component instance */) {
    
  this.apps.push(app)

  // 订阅
  history.listen(route => {
    this.apps.forEach((app) => {
      // 给每个组件实例app设置新的_route属性
      app._route = route
    })
  })
}
```

我们都知道，Vue通过Object.defineProperties()重写属性的`setter`和`getter`并结合观察者模式实现了数据双向绑定。当数据设置新值时，发布消息，之前注册的事件回调函数里的render()就会把视图更新。

因此，`app._route`更新时，视图就切走了，好像来到了一个新的页面。

Vue真是把发布订阅模式发挥得淋漓尽致！
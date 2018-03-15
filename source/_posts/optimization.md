---
title: Scroll组件原理和优化——春招读书笔记（三）
date: 2018-03-11 09:31:43
categories: 前端
tags:
- scroll
- 懒加载
- 性能优化
cover: http://wx3.sinaimg.cn/mw690/a98da548gy1fp8vkntij8j20go06idg7.jpg
---

我们常常会有加载长列表的需求，而它有两点性能瓶颈：

* 里面包含大量图片，需要发送大量的HTTP请求和下载

* 需要暴露列表的实时位置，这就会导致scroll事件的触发频率很高


之前在做Vue的项目时，用过一款挺好用的scroll组件——[better-scroll](https://github.com/ustbhuangyi/better-scroll)。它在Vue下的性能很好，在不断触发滚动事件暴露当前位置时也能不错的体验。如果配合vue-lazyload还可以实现图片懒加载，提高性能。它本身也有一个scrollEnd事件，注册它可以实现按需加载。

那如何判断滚动底部了呢？

![原理图](http://wx2.sinaimg.cn/mw690/a98da548gy1fp8nhid3yhj20ji09eglr.jpg)

* `clientHeight`：浏览器可视区域高度
* `scrollTop`：Y方向上当前滚动距离
* `scrollHeight`：我的理解就是页面高度。

`clientHeight`和`scrollHeight`是不变的。初始时，`scrollTop=0`；滚动底部时，`clientHeight+scrollTop=scrollHeight`

有了后面这个条件，就可以判断是否到底部了。一般会预留一些距离，就是快到底部时就加载需要的数据。

那是局部滚动时如何判断到底部呢？

我的思路是可以尝试下`offset-`系列的属性。

* offsetTop：一般情况为文档坐标下的Y值，但如果祖先元素已定位，为相对祖先元素的Y值。

* offsetWidth：元素高度

或许，我们可以先将父元素相对定位，然后比较`offsetTop`是否等于`offsetHeight`，这样就可以判断是否到底部了。

Better-Scroll给`scroll`事件注册一个校验是否到底部的回调函数，当到达底部时，触发默认绑定的自定义事件`scrollEnd`：

```js
 BScroll.prototype._watchPullUp = function () {
    this.pullupWatching = true
    const {threshold = 0} = this.options.pullUpLoad

    this.on('scroll', checkToEnd)

    function checkToEnd(pos) {
      if (this.movingDirectionY === DIRECTION_UP && pos.y <= (this.maxScrollY + threshold)) {
        // reset pullupWatching status after scroll end.
        this.once('scrollEnd', () => {
          this.pullupWatching = false
        })
        this.trigger('pullingUp')
        this.off('scroll', checkToEnd)
      }
    }
  }
```

![局部滚动](http://wx3.sinaimg.cn/mw690/a98da548gy1fp2f8fgaaij20n20hkjrx.jpg)

解决了判断是否到底部，那图片懒加载又是如何实现的呢？

在JS中，有个代理模式。

```js
var myImg = (function() {
    var img = document.creatElemet('img')
    document.body.appendChild(img)

    return {
          setSrc: function(src) {
            img.src = src
          }
    }
})()

var proxyImg = (function() {
      var img = new Image()
      img.onload = function() {
        myImg.setSrc = (this.src)
      }

      return {
        setSrc: function(src) {
          myImg.setSrc('file://loading.png')
          img.src = src
        }
      }
  })()
```

上面这种模式，将图片的DOM相关的操作和懒加载功能分离，遵从了单一职责原则。预先加载本地图片，而本地文件是只需要加载一次的，这样利于了缓存，给用户一个良好的体验。等远程图片下载完成，也就是在代理的`img.onload`触发时，将原图片的src换成远程图片。

进一步优化，还可以在节点插入上做文章。

也就是将一系列节点统一插入DOM，减小DOM操作：

```js
var fragment = document.createDocumentFragment()

for (var i; i < 10; i++) {
  var img = document.creatElemet('img')
  fragment.appendChild(img)
}

document.appendChild(fragment)
```

better-scroll在Vue中有不错的表现，可我在做一个React项目时，却遇到了问题。

我需要暴露出组件的当前位置，以和左侧栏导航栏做一个响应。这个功能在Vue上很流畅，但在React中卡的不行。

我做了两步去优化它：

* 使用`immutable.js`优化`shouldComponentUpdate`；
* 函数节流

```js
import { is } from 'immutable'

class Wrapper extends React.Component {
  shouldComponentUpdate(nextProps, nextState) {
    const thisProps = this.props || {}, thisState = this.state || {};

    if (Object.keys(thisProps).length !== Object.keys(nextProps).length ||
      Object.keys(thisState).length !== Object.keys(nextState).length) {
        return true;
    }

    for (const key in nextProps) {
      if (!is(thisProps[key], nextProps[key])) {
        return true;
      }
    }

    for (const key in nextState) {
      if (thisState[key] !== nextState[key] || !is(thisState[key],nextState[key])) {
        return true;
      }
    }
    return false;
  }
  // some code
  render() {
    return {
      <Scroll />
    }
  }
}
```

使用后，果然没那么卡了。为什么呢？

这里就涉及到Vue和React的渲染机制。

Vue是跟踪变化节点的依赖，只更新相关联的那部分，这部分对外是看不到的，开发者不需要关注，也能实现高效重绘。这也是Vue的一个优点。

而React是更新变化节点的所有子节点，这样就带来一些额外的开销。只能通过`shouldComponentUpdate`来指示是否需要重绘。而判断一个数据是否真的变了，这部分工作就给了`immutable.js`。

我的代码中，在滚动时state属性变动是这样的：

* scrollY {Number} - scroll组件实时位置，实时变化
* currentIndex {Number} - 根据scrollY条件变化
* fixedTitle {String} - 根据currentIndex条件变化


之前，`scrollY`的更新会调用render()方法，整个子组件都更新了。而在使用了`immutable.js`后，`scroll`组件内部并不知道会更新，干掉了一大性能瓶颈。

其实，还可以更进一步，`scrollY`可以从`state`里提出，把它定义为组件的属性。为什么呢？

因为，它并不直接作用于UI，只有在一定条件下它才会间接改变跟UI关联的`state`属性。

到此为止，`scroll`组件已经算是比较好用了，但跟不暴露实时位置时的效果还是有明显的差距。

终于到了函数节流了。

像`input`、`resize`、`scroll`这样连续触发的事件，一个常用的优化方法就是函数节流。

我们可以这样定义一个节流函数：

```js
// util.js
export function debounce(func, delay) {
  let timer
  return function(...args) {
    if (timer) {
      return
    }
    timer = setTimeout(() => {
      func.apply(this, args)
      clearTimeout(timer)
      timer = null
    }, delay)
  }
}
```

它通过一个闭包，延长了局部变量`timer`是寿命，还保证在一个延迟时间内只有一次函数调用。

通过它，你就可以避免短时间内大量触发引发大量性能消耗的`scroll`事件了。

那能不能再进一步呢？

谷歌浏览器前两年发布了一个新功能：给`addEventListener`添加`{passive:true}`选项，将大大提升页面滚动的性能：

```js
// 通知浏览器当scroll事件执行时，忽略所有的阻止默认事件语句
addEventListener('scroll', {passive:true})

// vue.js中你可以这样写
<div v-on:scroll.passive="onScroll">...</div>
```

在React中，我暂时没有找到设置这个属性的方法。

不过，在我看Better-Scroll组件源码时，发现它原生绑定`scroll`事件时就已经设置了，不过它设置为了`false`：

```js
export function addEvent(el, type, fn, capture) {
  el.addEventListener(type, fn, {passive: false, capture: !!capture})
}
```

我尝试着修改源码，将它设置为`{passive: true}`。似乎确实可以感受到滑动的流畅提升。

为了测试兼容性，我决定使用`Vue`里的做法：

```js
var supportsPassive = false
try {
    const opts = {}
    Object.defineProperty(opts, 'passive', ({
      get () {
        /* istanbul ignore next */
        supportsPassive = true
      }
    } : Object))
    window.addEventListener('test-passive', null, opts)
  } catch (e) {}

// 注册事件
if (type === 'touchstart' || type === 'touchmove' || type === 'touchstart') {
    el.removeEventListener(type, fn, supportPassive ? { passive:true } : false)
  } 
```

上面代码，先检测浏览器是否支持Passive Event API。它是通过修改变量`supportsPassive`的`getter`取值器函数，当浏览器去调用它时，将会把`supportsPassive`置为真。注册事件时，就可以通过它来判断是否支持这个API了。
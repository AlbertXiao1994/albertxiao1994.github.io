---
title: Immutable总结
date: 2018-03-30 18:45:27
categories: 前端
tags:
- React
- immutable.js
- Redux
cover: http://wx2.sinaimg.cn/mw690/a98da548gy1fpv1k5velgj20sg0j0gmi.jpg
---

{% note info %}

在初学React时，就在项目里使用了`Immutable.js`。但是，只能说是浅浅地使用。最近，又看了几篇博客，发现我原来的理解有些是错的。

{% endnote %}


## `is()`比较发生了什么

下面是`is()`的源码：

```js
export function is(valueA, valueB) {
  // 直接进行全等比较
  if (valueA === valueB || (valueA !== valueA && valueB !== valueB)) {
    return true;
  }

  // 若valueA, valueB不全等，并且转成布尔值为真，直接返回false
  if (!valueA || !valueB) {
    return false;
  }

  // 若为函数，比较函数返回值
  if (
    typeof valueA.valueOf === 'function' &&
    typeof valueB.valueOf === 'function'
  ) {
    valueA = valueA.valueOf();
    valueB = valueB.valueOf();
    if (valueA === valueB || (valueA !== valueA && valueB !== valueB)) {
      return true;
    }
    if (!valueA || !valueB) {
      return false;
    }
  }
  
  // 最后判断是否为Value Object，即是否实现`equal()`和`hashCode()`方法
  return !!(
    isValueObject(valueA) &&
    isValueObject(valueB) &&
    valueA.equals(valueB)
  );
}
```

它的设计初衷是对数据进行**值比较**，适用于以下几类：

* 原生JS里的基本类型，如数字、字符串

* `Immutable`类型的数据

* 实现了`equal()`和`hashCode()`方法的自定义JS对象

对于原生JS引用类型数据，则还是进行地址比较。

## 尽量不要使用fromJS()和toJS()

原来，我都是像下面这样使用`immutable.js`的：

```js
// 错误示范，本身就有一定的性能开销
shouldComponentUpdate(nextProps, nextState) {
  return !is(fromJS(this.props), fromJS(nextProps)) || !is(fromJS(this.state),fromJS(nextState))
}
```

这样使用非常省事，直接将`props`和`state`进行深度的`immutable`转换。可是，使用`fromJS()`是件十分消耗性能的事。

有下面这样一个例子来说明`fromJS()`的性能消耗：

```js
var start = new Date().getTime();
var a;
for (var i = 0; i < 1000000; i++) {
  a = Immutable.Map({a:1, b:2, c:3});
}
console.log("Map:" new Date().getTime() - start); // Map: 651

for (var i = 0; i < 1000000; i++) {
  a = Immutable.fromJS({a:1, b:2, c:3});
}
console.log("fromJS:" new Date().getTime() - start); // fromJS: 2490
```

可见，`fromJS`比`Map`就多消耗4倍的时间，跟原生类型比就更不用说了。

## `shouldComponentUpdate`优化的正确使用姿势

我总结了下面两点：

* 如果`state`里的数据都是基本类型，放心大胆使用`pureComponent`

* 如果存在引用类型的`state`属性，转换成`Immutable`类型
   1. 单层数据，使用`Map`或者`List`转换

   2. 嵌套数据，使用`fromJS()`转换

而常见的`shouldComponentUpdate`编写套路如下：

```js
shouldComponentUpdate(nextProps, nextState) {
  const thisProps = this.props || {};
  const thisState = this.state || {};
  nextState = nextState || {};
  nextProps = nextProps || {};
  
  // 比较键值对长度
  if (Object.keys(thisProps).length !== Object.keys(nextProps).length || Object.keys(thisState).length !== Object.keys(nextState).length) {
    return true;
  }
  
  // 比较props的值变化
  for (const key in nextProps) {
    if (!is(thisProps[key], nextProps[key])) {
      return true;
    }
  }
  
  // 比较state的值变化
  for (const key in nextState) {
    if (!is(thisState[key], nextState[key])) {
      return true;
    }
  }

  // 其他情况下，调用render()方法
  return false;
}
```

## 在Redux中的应用

### 1. 使用`redux-immutable`

`redux-immutable`提供一个重写的`combineReducers`，允许使用`Immutable`类型的`state`。

```js
import {combineReducers} from 'redux-immutable';
import dish from './dish';
import menu from './menu';
import cart from './cart';

const rootReducer = combineReducers({
  dish,
  menu,
  cart,
});
```

### 2. 改造`initialState`

```js
const initialState = Immutable.Map({});
export default function menu(state = initialState, action) {
    switch (action.type) {
    case SET_ERROR:
        return state.set('isError', true);
    }
}
```

### 3. 改造mapStateToProps

```js
//connect
function mapStateToProps(state) {
  return {
      menuList: state.getIn(['dish', 'list']),  //使用get或者getIn来获取state中的变量
      CartList: state.getIn(['dish', 'cartList'])
  }
}
```

## 参考

1. [Immutable.js 以及在 react+redux 项目中的实践](https://juejin.im/post/5948985ea0bb9f006bed7472?utm_source=tuicool&utm_medium=referral#heading-9)

2. [Immutable 详解及 React 中实践](https://github.com/camsong/blog/issues/3)

3. [Immutable.js官方文档](http://facebook.github.io/immutable-js/docs/#/)

4. [Immutable.js源码](https://github.com/facebook/immutable-js)
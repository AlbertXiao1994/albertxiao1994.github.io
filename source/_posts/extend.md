---
title: 谈谈继承——春招读书笔记（二）
date: 2018-03-10 17:54:44
categories: 前端
tags:
- 继承
- ES6
cover: http://wx3.sinaimg.cn/mw690/a98da548gy1fp7wtx46hpj20dw07st98.jpg
---

## ES5下的继承

### 1、原型链式

```js
function superType () {
}

function subType () {
}

subType.protoType = new superType()
```

特点：子类型的原型为超类型的实例。

缺点：

* 当继承引用类型的值时，那对该引用类型的值的操作，将反映到所有实例上。

* 不能对超类型的构造函数传值。

重点说下第一点。

一开始，我没有完全懂第一点的含义。

《JS高程》上有个例子：

```js
function superType () {
  this.color=['red', 'blue', 'green']
}

function subType () {
}

subType.protoType = new superType()

// 子类型实例1
var instantce1 = new subType()
instantce1.color.push('black')

// 子类型实例2
var instantce2 = new subType()
console.log(instantce2.color) // ['red', 'blue', 'green', 'black']
```

子实例2受到了子实例1的影响。原因是color是个引用，定义在原型上，为所有实例共享。

看上去好像是懂了，其实呢？

不信，问个问题：基本类型的属性也被所有实例共享，那为什么只有引用类型是原型链式的缺点？

来看看下面这个例子：

```js
function A () {
  this.num = 1
}

function B () {
}

B.prototype = new A()

var b1 = new B()
b1.num = 2

var b2 = new B()
console.log(b2.num) // 1
```

哎呀，`b2.num`的值确实没有被影响！

原因在于，`b1.num`和`b2.num`根本不是一个东西。

```js
b1.num // 新定义在实例b1上，为实例属性
b2.num // 从原型那找到的属性
```

也就是说，对于基本类型的属性，你压根就没有办法改变它的值。其实，对于引用类型的属性，你只是也能通过引用类型自身的方法改变它的值。要是直接赋值的话，一样歇菜。

话说回来，直接赋值那还不如直接定义，没必要继承了。

那有什么办法既继承，又规避上面的缺点呢？借用构造函数。

### 借用构造函数

```js
function superType () {
}

function subType () {
  superType.call(this)
}
```

直接在子类型中调用超类型的构造函数，那每个子类型实例都拥有它自己的继承而来的属性了。而且，你还可以调用超类型构造函数时给它传值。

问题看似都解决了。可新的问题又来了：超类型的方法无法复用，或者说每次新建实例时都需要新建一次，这会带来额外的开销。

### 组合式

组合式继承结合了前两种的优点，是最常用的方法。

```js
function superType () {
}

function subType () {
  superType.call(this)
}

subType.protoType = new superType()
subType.protoType.constructor = superType
```

这种方法好在哪呢？

它的目的是：从通过原型链继承方法，通过借用构造函数得到实例自有的继承属性。

它的方法是：先通过原型链继承*原型方法和属性*,通过借用构造函数覆盖它原型里的属性。

因为实例里就有需要的属性，永远也不会跑去原型那找了。

这种方法也有问题：它调用了两次超类型构造函数，还产生了一些永远也用不上的原型属性。

### 原型式

```js
function object (o) {
  function f () {}
  f.prototype = o
  return new f()
}
```

这种方法我觉得并没多特别的。

它的用处就是可以得到有用对象o的一个副本。

你有没有发现它和原型链是很像，连名字都很接近。

当使用原型链法，如果子类型的构造函数是空的时，它们就是一样的。

区别也就出来了：原型式得到一个已有对象的副本，什么共享引用类型、不能传值这些问题它都有；而原型链式，可以在子类型的构造函数里定义一些自有属性方法。

### 寄生式

它和原型式很像，只是多做一点步骤，所谓的增强返回的实例。

```js
function createAnother (o) {
  var clone = object(o)
  clone.newMethod = function () {}
  return clone
}
```

### 寄生组合式

还有最后一种，它最强大，集各家所长。

```js
function superType () {
}

superType.someMethod = function () {}

function subType () {
  superType.call(this)
}

inherit (subType, SurperType)

function inherit (subType, superType) {
  var protytype = object(superType.protytype)
  subType.protoType = protytype
  subType.protoType.constructor = superType
}
```

它直接从超类型原型那继承方法，而组合式其实是在原型链上查找方法来继承。

## ES5和ES6继承的不同

ES6引入了类的概念，但其实它只是ES5的一个语法糖。

```js
// ES5
function A () {
  this.name = "Albert"
}
A.protytype.getName = function () {
  return this.name
}

// ES6
class A {
  constructor () {
    thsi.name = "Albert"
  }

  getName () {
    return this.name
  }
}

typeof A // 'function'
A === A.protytype.constructor // true

var a = new A()
```

类A是个函数，它指向构造函数。

在ES5中，构造函数负责返回实例。而ES6中，这部分功能由construtor方法完成。

ES6中继承像这样：

```js
class Child extends Parent {
  constructor () {
    super()
    this.age = "24"
  }
}
```

`super`用作函数时，指父类的`construtor`方法。`super`用作对象时，在普通函数中指向父类原型；在静态方法中，指向父类。

子类同时具有`__proto__`和`prototype`属性。`__proto__`属性指向父类，`prototype`属性指向父类原型的实例。

```js
class A {
}

class B extends A {
}

B.__proto__ === A // true
B.prototype.__proto__ === A.prototype // true
```
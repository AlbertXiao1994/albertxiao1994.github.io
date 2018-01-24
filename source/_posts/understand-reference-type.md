---
title: indexOf()引发的血案——引用类型初探
date: 2018-01-23 21:20:43
categories: 前端
tags:
- 对象
- 引用类型
cover: http://wx4.sinaimg.cn/mw690/a98da548gy1fnqv9ci5yej20pj0bj0tf.jpg
---
最近，又开始学JS了。JS大概永远也学不完吧！

初学时，选择的是“[犀牛书](https://book.douban.com/subject/10549733/)”，它被称为JS程序员心中的“圣经”。被称为“经”，我想是有原因的。这本书块头很大，语言有些晦涩，看得我晕头转向（上次这种感觉还是看[《数据结构与算法分析》](https://book.douban.com/subject/1139426/)时），但我竟然啃（fan）下（guo）来（yi）了（bian）。我想很大的原因可能是当初淘宝团队在翻译时采用了接近直译的方式。

后来，发现越来越多的人看的是“[红宝书](https://book.douban.com/subject/10546125/)”，那我也不能落下啊！看了几章，相见恨晚。它的语言很对中国人的味儿，就像一位网友说的，读它就像读一篇篇的博客。而它，又不失深度。

##  案发

当我看到第五章引用类型时，被眼前的一幕震惊了：
```  javascript
var person = { name:  "Nicholas"};
var people = [{ name: "Nicholas"};

var morePeople = [person];
alert(people.indexOf(person));           //-1
alert(morePeople.indexOf(person));       //0
``` 
为什么在`people`中会找不到`person`，而在`morePeople`中却可以？
![一脸懵逼](http://wx1.sinaimg.cn/mw690/a98da548gy1fnqwdx7oy7j209e064glk.jpg)
## 案情分析

### 1号嫌疑人：印错
我买的书虽不一定是正版，但错这么离谱好像不太可能。

无作案动机，排除！
![太天真了](http://wx1.sinaimg.cn/mw690/a98da548gy1fnqwiyvhxuj20bh092mxh.jpg)

### 2号嫌疑人：indexOf()查找时严格相等的条件
搜便案发现场，没发现“凶器”类型转换啊？

有不在场证明，排除！

僵掉了呀！
![天真，too](http://wx2.sinaimg.cn/mw690/a98da548gy1fnqwudwtvkj205k07tt8w.jpg)

### 3号嫌疑人：引用类型
人脏具获，束手就擒吧：
```  javascript
var person = { name:  "Nicholas"}; //person是对象{ name:  "Nicholas"}的引用A，是一个对象指针
var people = [{ name: "Nicholas"}; //people是一个包含对象{ name:  "Nicholas"}的另一个引用B的数组

var morePeople = [person];         //morePeople 是一个包含对象{ name:  "Nicholas"}的引用A的数组
alert(people.indexOf(person));     //-1，people中只有引用B，没有引用A
alert(morePeople.indexOf(person)); //0，people中有引用A
``` 
## 结案
解决每一个问题，都是对自己的查缺补漏。真好！

基础，基础，基础！
![真相大白](http://wx1.sinaimg.cn/mw690/a98da548gy1fnqx9a8yyvj209q07ydfv.jpg)
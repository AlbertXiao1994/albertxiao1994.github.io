---
title: 排序算法——春招读书笔记（八）
date: 2018-03-27 10:07:20
categories: 前端
tags:
- 排序
- 时间复杂度
- 空间复杂度
cover: http://wx2.sinaimg.cn/mw690/a98da548gy1fpr5kkvjjcj20go0b30v4.jpg
---

{% note info %}

数据结构和算法，是每个程序员的基本素养，前端工程师也不例外。之前也定下了重学数据结构与算法的计划，用大概两个月的时间把《剑指offer》过一遍。今天，先整理整理排序算法。

{% endnote %}

## 通用函数

开始整理前，我们先定义一个通用函数：

```js
function swap(arr, i, j) {
  var temp = arr[i];
  arr[i] = arr[j];
  arr[j] = temp;
}
```

它的功能就是互换数组中位置i、j处的值。

## 冒泡排序

基本思想：两层循环，每一轮循环从头开始两两比较，更大的往后冒泡；当一轮结束时，当前轮最大的数冒泡到数组最后。

复杂度：O(n²)

```js
function bubbleSort(arr) {
  for (var i = 0, len = arr.length; i < len; i++) {
    for (var j = 0; j < len -i -1; j++) {
      if (arr[j] > arr[j + 1]) {
        swap(arr, j, j + 1);
      }
    }
  }
  return arr;
}

var arr = [3, 2, 10, 5, 1, 8, 4, 6, 7, 9];
bubbleSort(arr); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

每一轮都有一个数排好序，所以j的上界为len-i-1,减少不必要的比较。

## 选择排序

基本思想：两层循环，每轮将头部元素作为最小值参照，遍历数组替换头部最小值。

复杂度：O(n²)

```js
function selectSort(arr) {
  for (var i = 0, len = arr.length; i < len; i++) {
    for (var j = i + 1; j < len; j++) {
      if (arr[j] < arr[i]) {
        swap(arr, i, j);
      }
    }
  }
  return arr;
}

var arr = [3, 2, 10, 5, 1, 8, 4, 6, 7, 9];
selectSort(arr); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

## 插入排序

基本思想：它就像打扑克时配牌一样，即将未排序的元素依次往已排序的数组里插空。

复杂度：O(n²)。

在小型数组情况下，插入排序比前两种要好。

```js
function insertSort(arr) {
  for (var i = 1, len = arr.length; i < len; i++) {
    for (var j = i - 1; j >= 0; j--) {
      if (arr[j] > arr[j + 1]) {
        swap(arr, j, j + 1)
      }
    }
  }
  return arr;
}

var arr = [3, 2, 10, 5, 1, 8, 4, 6, 7, 9];
insertSort(arr); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

## 希尔排序

基本思想：按一定间隔将数组分组，每组内进行插入排序；减小间隔，重复以上过程，直至间隔为1。

复杂度：O(nlogn)

```js
function shellSort(arr) {
  var len = arr.length;
  for (var gap = Math.floor(len / 2); gap >= 1; gap = Math.floor(gap / 2)) {
    for (var i = gap; i < len; i++) {
      for (var j = i - gap; j >= 0; j = j -gap) {
        if (arr[j] > arr[j + gap]) {
          swap(arr, j, j + gap);
        }
      }
    }
  }
  return arr;
}

var arr = [3, 2, 10, 5, 1, 8, 4, 6, 7, 9];
shellSort(arr); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

## 归并排序

基本思想：采用分治和递归的思想，将数组分成两部分，每部分递归排序;从已排好序的两部分数组中，按大小依次取出元素放入新数组。

复杂度：O(nlogn)

```js
function mergeSort(arr) {
  var len = arr.length;
  
  // 仅有一个元素
  if (len < 2) {
    return arr;
  }

  var middle = Math.floor(len / 2);
  var left = arr.slice(0, middle);
  var right = arr.slice(middle);

  return merge(mergeSort(left), mergeSort(right));
}

function merge(left, right) {
  var result = [];

  while (left.length > 0 && right.length > 0) {
    if (left[0] < right[0]) {
      result.push(left.shift())
    } else {
      result.push(right.shift())
    }
  }

  while(left.length) {
    result.push(left.shift())
  }

  while(right.length) {
    result.push(right.shift())
  }

  return result;
}
```

## 快速排序

这是一道送分题。快排，是面试时被问到最多的。一般，前端的面试算法部分问到快排就差不多到头了。

基本思想：也是分治思想，将数组分为左右两部分，每部分以头部元素作为参考，比它小的放左边，比它大的放右边，接着递归，直到子数组长度为1。

复杂度：O(nlogn)。

它最坏的情况是对顺序数组排序，为O(n²)；平均时间是O(nlogn)，比其他的O(nlogn)的算法好。

```js
function quickSort(arr, left, right) {
  // 左界限
  var left = typeof left === "number" ? left : 0;
  // 右界限
  var right = typeof right === "number" ? right : arr.length - 1;

  // 递归终止条件
  if (left < right) {
    // 中间元素的位置
    var centerIndex = getCenterIndex(arr, left, right);
    quickSort(arr, left, centerIndex - 1);
    quickSort(arr, centerIndex + 1, right);
  }

  return arr;
}

function getCenterIndex(arr, left, right) {
  // 游标，标记参考值的位置
  var cursor = left + 1;

  for (var i = left + 1; i <= right; i++) {
    if (arr[left] > arr[i]) {
      swap(arr, cursor++, i)
    }
  }

  // 将参考元素换至中间位置
  swap(arr, left, cursor -1);
  
  return cursor -1;
}

var arr = [3, 2, 10, 5, 1, 8, 4, 6, 7, 9];
quickSort(arr); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

## 堆排序

基本思想：将一个数组堆化，即保证节点处元素大于等于子节点；互换头尾元素，堆长度递减；重复以上过程。

```js
function heapSort(arr) {
  var heapSize = arr.length;
  buildHeap(arr);

  while (heapSize > 1) {
    heapSize--;
    swap(arr, 0, heapSize);
    heapify(arr, heapSize, 0);
  }
}

function buildHeap(arr) {
  var heapSize = arr.length;

  for (var i = Math.floor(heapSize / 2); i >= 0; i--) {
    heapify(arr, heapSize, i);
  }
}

function heapify(arr, heapSize, i) {
  var left = i * 2 + 1;
  var right = i * 2 + 2;
  var largest = i;

  if (left < heapSize && arr[left] > arr[largest]) {
    largest = left;
  }

  if (right < heapSize && arr[right] > arr[largest]) {
    largest = right;
  }

  if (largest !== i) {
    swap(arr, largest, i);
    heapify(arr, heapSize, largest)
  }
}

var arr = [3, 2, 10, 5, 1, 8, 4, 6, 7, 9];
heapSort(arr); // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```
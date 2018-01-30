---
title: 遇见webpack
date: 2018-01-30 21:19:13
categories: 前端
tags:
- webpack
- VSCode
cover: http://wx2.sinaimg.cn/mw690/a98da548ly1fnyzhui70lj20go09edgq.jpg
---
{% note info %}

Webpack很早就接触了，但以前一直都是跟着脚手架跑跑命令行。配置文件也不算陌生，但一直也没深究。毕竟webpack配置工程师可是稀缺人才啊！昨天在微博上看到有人把阮一峰的[webpack-demos](https://github.com/ruanyf/webpack-demos)教程
更新到了3.1，但只有英文版。我索性做个中文文档，趁此再系统学习学习。

{% endnote %}

这里收集了一些Webpack的简单demo。

我旨在通过简明的方式来写这些demo。跟着它们，你将轻松地学习这一强大的工具。

## 如何使用

首先，全局安装[Webpack](https://www.npmjs.com/package/webpack) and [webpack-dev-server](https://www.npmjs.com/package/webpack-dev-server)

```bash
$ npm i -g webpack webpack-dev-server
```

之后，复制这个库到本地。

```bash
$ git clone https://github.com/ruanyf/webpack-demos.git
```

接着，安装所有依赖。

```bash
$ cd webpack-demos
$ npm install
```

现在，按顺序在这些以demo开头的目录下运行源文件。像这样：

```bash
$ cd demo01
$ npm run dev
```

如果以上命令没有自动打开你的浏览器，恐怕你需要自行访问http://127.0.0.1:8080 。

## 前言：Webpack是什么

Webpack是一个为浏览器构建JavaScript模块脚本的前端工具。

它用起来和Browserify很像，但功能更强大。

```bash
$ browserify main.js > bundle.js
# 等同于
$ webpack main.js bundle.js
```

Webpack需要一个叫做`webpack.config.js`配置文件，而它其实就是一个CommonJS文件。

```javascript
// webpack.config.js
module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  }
};
```

在配置好`webpack.config.js`文件后，你能在没有任何参数的情况下启动webpack。

```bash
$ webpack
```

Some command-line options you should know.
下面这些命令行选项你需要知道：

- `webpack` – 开发环境下打包
- `webpack -p` – 生产环境下打包 (压缩)
- `webpack --watch` – 监听文件变化并自动打包
- `webpack -d` – 包含source maps（译注：source maps为源码转化后的位置信息文件）
- `webpack --colors` – 生成带有颜色的打包输出信息

你可以像下面这样在你的package.json文件中自定义`scripts`项。

```javascript
// package.json
{
  // ...
  "scripts": {
    "dev": "webpack-dev-server --devtool eval --progress --colors",
    "deploy": "NODE_ENV=production webpack -p"
  },
  // ...
}
```

## 目录

1. [入口文件](#Demo01-入口文件-源码)
1. [多个入口文件](#Demo02-多个入口文件-源码)
1. [Babel-loader](#Demo03-Babel-loader-源码)
1. [CSS-loader](#Demo04-CSS-loader-源码)
1. [Image loader](#demo05-Image-loader-源码)
1. [CSS模块](#Demo06-CSS模块-源码)
1. [UglifyJs插件](#demo07-UglifyJs插件-源码)
1. [HTML Webpack插件和Open Browser Webpack插件](#Demo08-HTML-Webpack插件和Open-Browser-Webpack插件-源码)
1. [环境标志](#Demo09-环境标志-源码)
1. [代码分割](#Demo10-代码分割-源码)
1. [使用bundle-loader进行代码分割](#Demo11-使用bundle-loader进行代码分割-源码)
1. [共同块](#Demo12-共同块-源码)
1. [依赖块](#Demo13-依赖块-源码)
1. [暴露全局变量](#Demo14-暴露全局变量-源码)
1. [React router](#Demo15-React-Router-源码)

## Demo01: 入口文件 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo01))

Webpack读取入口文件来生成`bundle.js`。

例如，`main.js`就是这样一个入口文件。

```javascript
// main.js
document.write('<h1>Hello World</h1>');
```
index.html

```html
<html>
  <body>
    <script type="text/javascript" src="bundle.js"></script>
  </body>
</html>
```

Webpack按照`webpack.config.js`里的配置来生成`bundle.js`。

```javascript
// webpack.config.js
module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  }
};
```

启动webpack server，访问http://127.0.0.1:8080 。

```bash
$ cd demo01
$ npm run dev
```

## Demo02: 多个入口文件 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo02))

有多个入口文件也是允许的。对于有多个不同入口文件的多页应用来说这会很有用。

```javascript
// main1.js
document.write('<h1>Hello World</h1>');

// main2.js
document.write('<h2>Hello Webpack</h2>');
```

index.html

```html
<html>
  <body>
    <script src="bundle1.js"></script>
    <script src="bundle2.js"></script>
  </body>
</html>
```

webpack.config.js

```javascript
module.exports = {
  entry: {
    bundle1: './main1.js',
    bundle2: './main2.js'
  },
  output: {
    filename: '[name].js'
  }
};
```

## Demo03: Babel-loader ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo03))

xxx-loader([more info](https://webpack.js.org/concepts/loaders/) 是在Webpack打包前转换项目里资源文件的预处理器。

例如，[Babel-loader](https://www.npmjs.com/package/babel-loader)能够将JSX/ES6文件转换成普通的JS文件，之后，Webpack再打包它们。Webpack的官方文档里列出了完整的[loaders](https://webpack.js.org/loaders/)。

`main.jsx`是一个JSX文件。

```javascript
// main.jsx
const React = require('react');
const ReactDOM = require('react-dom');

ReactDOM.render(
  <h1>Hello, world!</h1>,
  document.querySelector('#wrapper')
);
```

index.html

```html
<html>
  <body>
    <div id="wrapper"></div>
    <script src="bundle.js"></script>
  </body>
</html>
```

webpack.config.js

```javascript
module.exports = {
  entry: './main.jsx',
  output: {
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015', 'react']
          }
        }
      }
    ]
  }
};
```

以上代码在使用`babel-loader`时，需要Babel的预设插件[babel-preset-es2015](https://www.npmjs.com/package/babel-preset-es2015)和[babel-preset-react](https://www.npmjs.com/package/babel-preset-react)来转换ES6和React。

## Demo04: CSS-loader ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo04))

Webpack允许你在JS文件中包含CSS，它将通过[CSS-loader](https://github.com/webpack-contrib/css-loader)来预处理这些CSS。

main.js

```javascript
require('./app.css');
```

app.css

```css
body {
  background-color: blue;
}
```

index.html

```html
<html>
  <head>
    <script type="text/javascript" src="bundle.js"></script>
  </head>
  <body>
    <h1>Hello World</h1>
  </body>
</html>
```

webpack.config.js

```javascript
module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  },
  module: {
    rules:[
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      },
    ]
  }
};
```

注意，你需要两个loader来转换CSS文件。一个是[CSS-loader](https://www.npmjs.com/package/css-loader)来读CSS文件，另一个是[Style-loader](https://www.npmjs.com/package/style-loader)来将`<style>`标签插入HTML页面中。

之后，启动webpack server。

```bash
$ cd demo04
$ npm run dev
```

其实，Webpack将内联样式表插入了`index.html`。

```html
<head>
  <script type="text/javascript" src="bundle.js"></script>
  <style type="text/css">
    body {
      background-color: blue;
    }
  </style>
</head>
```

## Demo05: Image loader ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo05))

Webpack也能在JS文件包含图片。

main.js

```javascript
var img1 = document.createElement("img");
img1.src = require("./small.png");
document.body.appendChild(img1);

var img2 = document.createElement("img");
img2.src = require("./big.png");
document.body.appendChild(img2);
```

index.html

```html
<html>
  <body>
    <script type="text/javascript" src="bundle.js"></script>
  </body>
</html>
```

webpack.config.js

```javascript
module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  },
  module: {
    rules:[
      {
        test: /\.(png|jpg)$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 8192
            }
          }
        ]
      }
    ]
  }
};
```

[url-loader](https://www.npmjs.com/package/url-loader)将图片文件转换成`<img>`标签。如果图片尺寸小于8192字节，它会被转换成Data URL（译注：Data URL是将图片用base64编码后的字符串）；否则，它将转换成普通URL。

在启动server后，`small.png`和`big.png`分别将有以下URL：

```html
<img src="data:image/png;base64,iVBOR...uQmCC">
<img src="4853ca667a2b8b8844eb2693ac1b2578.png">
```

## Demo06: CSS模块 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo06))

带查询参数`modules`的css-loader将CSS文件变为一个[CSS模块](https://github.com/css-modules/css-modules)，模块里的CSS都是局部定义的。你可以使用`:global(selector)`([详情](https://css-modules.github.io/webpack-demo/))将CSS变为全局的。

index.html

```html
<html>
<body>
  <h1 class="h1">Hello World</h1>
  <h2 class="h2">Hello Webpack</h2>
  <div id="example"></div>
  <script src="./bundle.js"></script>
</body>
</html>
```

app.css

```css
/* local scope */
.h1 {
  color:red;
}

/* global scope */
:global(.h2) {
  color: blue;
}
```

main.jsx

```javascript
var React = require('react');
var ReactDOM = require('react-dom');
var style = require('./app.css');

ReactDOM.render(
  <div>
    <h1 className={style.h1}>Hello World</h1>
    <h2 className="h2">Hello Webpack</h2>
  </div>,
  document.getElementById('example')
);
```

webpack.config.js

```javascript
module.exports = {
  entry: './main.jsx',
  output: {
    filename: 'bundle.js'
  },
  module: {
    rules:[
      {
        test: /\.js[x]?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015', 'react']
          }
        }
      },
      {
        test: /\.css$/,
        use: [
          {
            loader: 'style-loader'
          },
          {
             loader: 'css-loader',
             options: {
               modules: true
             }
          }
        ]
      }
    ]
  }
};
```

启动webpack server。

```bash
$ cd demo06
$ npm run dev
```

访问http://127.0.0.1:8080 ，你将发现只有第二个`h1`是红色的，因为它的CSS是局部的；而两个`h2`都是蓝色的，因为它的CSS是全局的。

## Demo07: UglifyJs插件 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo07))

Webpack通过插件体系来扩展它的功能。例如，[UglifyJs插件](https://webpack.js.org/plugins/uglifyjs-webpack-plugin/)能够压缩输出(`bundle.js`)的JS代码。

main.js

```javascript
var longVariableName = 'Hello';
longVariableName += ' World';
document.write('<h1>' + longVariableName + '</h1>');
```

index.html

```html
<html>
<body>
  <script src="bundle.js"></script>
</body>
</html>
```

webpack.config.js

```javascript
var webpack = require('webpack');
var UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  },
  plugins: [
    new UglifyJsPlugin()
  ]
};
```

在启动server之后，`main.js`将会被压缩成下面这样。

```javascript
var o="Hello";o+=" World",document.write("<h1>"+o+"</h1>")
```

## Demo08: HTML Webpack插件和Open Browser Webpack插件 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo08))

这个demo像你演示如何载入第三方插件。

[html-webpack-plugin](https://github.com/ampedandwired/html-webpack-plugin)能够为你创建`index.html`，而[open-browser-webpack-plugin](https://github.com/baldore/open-browser-webpack-plugin)当Webpack载入时能够打开一个新的浏览器标签页。

main.js

```javascript
document.write('<h1>Hello World</h1>');
```

webpack.config.js

```javascript
var HtmlwebpackPlugin = require('html-webpack-plugin');
var OpenBrowserPlugin = require('open-browser-webpack-plugin');

module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  },
  plugins: [
    new HtmlwebpackPlugin({
      title: 'Webpack-demos',
      filename: 'index.html'
    }),
    new OpenBrowserPlugin({
      url: 'http://localhost:8080'
    })
  ]
};
```

启动server。

```bash
$ cd demo08
$ npm run dev
```

现在你不必再手写`index.html`了，也不必再自己打开浏览器了。Webpack将会为你做这些事。

## Demo09: 环境标志 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo09))

你可以通过环境标志让某些代码仅在开发环境下有效。

main.js

```javascript
document.write('<h1>Hello World</h1>');

if (__DEV__) {
  document.write(new Date());
}
```

index.html

```html
<html>
<body>
  <script src="bundle.js"></script>
</body>
</html>
```

webpack.config.js

```javascript
var webpack = require('webpack');

var devFlagPlugin = new webpack.DefinePlugin({
  __DEV__: JSON.stringify(JSON.parse(process.env.DEBUG || 'false'))
});

module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  },
  plugins: [devFlagPlugin]
};
```

现在把环境变量传递给webpack。打开`demo09/package.json`，你应该会发现`scripts`变成了这样：

```javascript
// package.json
{
  // ...
  "scripts": {
    "dev": "cross-env DEBUG=true webpack-dev-server --open",
  },
  // ...
}
```

启动server。

```javascript
$ cd demo09
$ npm run dev
```

## Demo10: 代码拆分 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo10))

对于大型web应用来说，将所有的代码写进一个文件效率会很低。Webpack允许你将大的JS文件拆分成若干个小的代码块（chunk)。尤其在一些代码块仅在某些情况下才使用时，这些代码块应该按需加载。

Webpack使用`require.ensure`去定义一个拆分点([官方文档](https://webpack.js.org/guides/code-splitting/))。

```javascript
// main.js
require.ensure(['./a'], function (require) {
  var content = require('./a');
  document.open();
  document.write('<h1>' + content + '</h1>');
  document.close();
});
```

`require.ensure`告诉Webpack`./a.js`应该从`bundle.js`中分离出来，并打包成一个单独的块文件。

```javascript
// a.js
module.exports = 'Hello World';
```

现在Webpack将会关心依赖、输出文件和运行时环境。而你不必往`index.html`和`webpack.config.js`里添加任何东西。

```html
<html>
  <body>
    <script src="bundle.js"></script>
  </body>
</html>
```

webpack.config.js

```javascript
module.exports = {
  entry: './main.js',
  output: {
    filename: 'bundle.js'
  }
};
```

启动server。

```bash
$ cd demo10
$ npm run dev
```

表面上，你不会感觉到任何变化。然而，Webpack实际上将`main.js`和`a.js`打包成了不同的块（`bundle.js`和`0.bundle.js`)，并且在需要时从`bundle.js`载入`0.bundle.js`。

## Demo11: 使用bundle-loader进行代码分割 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo11))

另一种代码分割的方式是使用[bundle-loader](https://www.npmjs.com/package/bundle-loader)。

```javascript
// main.js

// 现在导入请求a.js，将它打包进另一个文件
var load = require('bundle-loader!./a.js');

// 等待a.js载入并获得它导出的内容
// 你需要异步等待它
load(function(file) {
  document.open();
  document.write('<h1>' + file + '</h1>');
  document.close();
});
```

`require('bundle-loader!./a.js')`告诉Webpack从另一个块中载入`a.js`。

现在Webpack将会把`main.js`打包成`bundle.js`，把`a.js`打包成`0.bundle.js`。

## Demo12: 共同块 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo12))

当多个脚本有共同的代码块时，你可以用[CommonsChunkPlugin](https://webpack.js.org/plugins/commons-chunk-plugin/)将它们导入一个单独的文件，这有助于浏览器缓存以及节省带宽。

```javascript
// main1.jsx
var React = require('react');
var ReactDOM = require('react-dom');

ReactDOM.render(
  <h1>Hello World</h1>,
  document.getElementById('a')
);

// main2.jsx
var React = require('react');
var ReactDOM = require('react-dom');

ReactDOM.render(
  <h2>Hello Webpack</h2>,
  document.getElementById('b')
);
```

index.html

```html
<html>
  <body>
    <div id="a"></div>
    <div id="b"></div>
    <script src="commons.js"></script>
    <script src="bundle1.js"></script>
    <script src="bundle2.js"></script>
  </body>
</html>
```

以上的`commons.js`是`main1.jsx`和`main2.jsx`的共同代码块。正如所料，`commons.js`包含了`react`和`react-dom`。

webpack.config.js

```javascript
var webpack = require('webpack');

module.exports = {
  entry: {
    bundle1: './main1.jsx',
    bundle2: './main2.jsx'
  },
  output: {
    filename: '[name].js'
  },
  module: {
    rules:[
      {
        test: /\.js[x]?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015', 'react']
          }
        }
      },
    ]
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin({
      name: "commons",
      // （共同块的名称）

      filename: "commons.js",
      // （共同块的文件名）
    })
  ]
}
```

## Demo13: 依赖块 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo13))

通过CommonsChunkPlugin，你也能将依赖库从脚本中导入一个单独的文件。

main.js

```javascript
var $ = require('jquery');
$('h1').text('Hello World');
```

index.html

```html
<html>
  <body>
    <h1></h1>
    <script src="vendor.js"></script>
    <script src="bundle.js"></script>
  </body>
</html>
```

webpack.config.js

```javascript
var webpack = require('webpack');

module.exports = {
  entry: {
    app: './main.js',
    vendor: ['jquery'],
  },
  output: {
    filename: 'bundle.js'
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor',
      filename: 'vendor.js'
    })
  ]
};
```

上面的代码中，`entry.vendor: ['jquery']`告诉Webpack应该将`jquery`包含在共同的代码块`vendor.js`中。

如果你想一个模块变量全局生效，例如不通过`require("jquery")`就在每一个模块中使用`$`和`jQuery`。你应该使用`ProvidePlugin` ([官方文档](https://webpack.js.org/plugins/provide-plugin/))，它能不用特意引入而自动载入模块。

```javascript
// main.js
$('h1').text('Hello World');


// webpack.config.js
var webpack = require('webpack');

module.exports = {
  entry: {
    app: './main.js'
  },
  output: {
    filename: 'bundle.js'
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery'
    })
  ]
};
```

当然，在这个例子中，你应该自己全局导入`jquery.js`。

## Demo14: 暴露全局变量 ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo14))

If you want to use some global variables, and don't want to include them in the Webpack bundle, you can enable `externals` field in `webpack.config.js` ([official document](https://webpack.js.org/configuration/externals/)).


例如，我们有一个`data.js`。

```javascript
// data.js
var data = 'Hello World';
```

index.html

```html
<html>
  <body>
    <script src="data.js"></script>
    <script src="bundle.js"></script>
  </body>
</html>
```

注意，Webpack只会生成`bundle.js`，而不会生成`data.js`。

我们可以将`data`暴露为一个全局变量。

```javascript
// webpack.config.js
module.exports = {
  entry: './main.jsx',
  output: {
    filename: 'bundle.js'
  },
  module: {
    rules:[
      {
        test: /\.js[x]?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015', 'react']
          }
        }
      },
    ]
  },
  externals: {
    // 通过require('data')导入data.js即可全局生效
    'data': 'data'
  }
};
```

现在，你在脚本里像模块变量一样导入`data`，但实际上它是一个全局变量。

```javascript
// main.jsx
var data = require('data');
var React = require('react');
var ReactDOM = require('react-dom');

ReactDOM.render(
  <h1>{data}</h1>,
  document.body
);
```

你也能将`react`和`react-dom`放入`externals`里，这将极大地减小`bundle.js`的编译时间和大小。

## Demo15: React router ([源码](https://github.com/ruanyf/webpack-demos/tree/master/demo15))

这个demo使用webpack来构建[React-router](https://reacttraining.com/react-router/web/guides/philosophy)的官方例子。

想象一个有着仪表板、收信箱和日历的小应用。

```
+---------------------------------------------------------+
| +---------+ +-------+ +--------+                        |
| |Dashboard| | Inbox | |Calendar|      Logged in as Jane |
| +---------+ +-------+ +--------+                        |
+---------------------------------------------------------+
|                                                         |
|                        Dashboard                        |
|                                                         |
|                                                         |
|   +---------------------+    +----------------------+   |
|   |                     |    |                      |   |
|   | +              +    |    +--------->            |   |
|   | |              |    |    |                      |   |
|   | |   +          |    |    +------------->        |   |
|   | |   |    +     |    |    |                      |   |
|   | |   |    |     |    |    |                      |   |
|   +-+---+----+-----+----+    +----------------------+   |
|                                                         |
+---------------------------------------------------------+
```

webpack.config.js

```javascript
module.exports = {
  entry: './index.js',
  output: {
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015', 'react']
          }
        }
      },
    ]
  }
};
```

index.js

```javascript
import React from 'react';
import { render } from 'react-dom';
import { BrowserRouter, Switch, Route, Link } from 'react-router-dom';

import './app.css';

class App extends React.Component {
  render() {
    return (
      <div>
        <header>
          <ul>
            <li><Link to="/app">Dashboard</Link></li>
            <li><Link to="/inbox">Inbox</Link></li>
            <li><Link to="/calendar">Calendar</Link></li>
          </ul>
          Logged in as Jane
        </header>
        <main>
          <Switch>
            <Route exact path="/" component={Dashboard}/>
            <Route path="/app" component={Dashboard}/>
            <Route path="/inbox" component={Inbox}/>
            <Route path="/calendar" component={Calendar}/>
            <Route path="*" component={Dashboard}/>
          </Switch>
        </main>
      </div>
    );
  }
};

class Dashboard extends React.Component {
  render() {
    return (
      <div>
        <p>Dashboard</p>
      </div>
    );
  }
};

class Inbox extends React.Component {
  render() {
    return (
      <div>
        <p>Inbox</p>
      </div>
    );
  }
};

class Calendar extends React.Component {
  render() {
    return (
      <div>
        <p>Calendar</p>
      </div>
    );
  }
};

render((
  <BrowserRouter>
    <Route path="/" component={App} />
  </BrowserRouter>
), document.querySelector('#app'));
```

index.html

```html
<html>
  <body>
    <div id="app"></div>
    <script src="/bundle.js"></script>
  </body>
</htmL>
```

启动server。

```bash
$ cd demo15
$ npm run dev
```

## 有用的链接

- [Webpack docs](https://webpack.js.org/concepts/)
- [webpack-howto](https://github.com/petehunt/webpack-howto), by Pete Hunt
- [SurviveJS Webpack book](https://survivejs.com/webpack/introduction/), by Juho Vepsäläinen
- [Diving into Webpack](https://web-design-weekly.com/2014/09/24/diving-webpack/), by Web Design Weekly
- [Webpack and React is awesome](http://www.christianalfoni.com/articles/2014_12_13_Webpack-and-react-is-awesome), by Christian Alfoni
- [Browserify vs Webpack](https://medium.com/@housecor/browserify-vs-webpack-b3d7ca08a0a9), by Cory House

## 许可证

MIT
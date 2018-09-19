> Theme: Computer underlying knowledge 
> Source Code Read Plan:
> - [ ] GCD 底层libdispatch
> - [ ] TableView Reload 原理，博文总结
> - [x] Custom UIViewController Transitions (随便写几个demo实现玩)

# 2018/09/03

[可交互式的滑入滑出效果](https://github.com/colourful987/2018-Read-Record/tree/master/Content/iOS/TransitionWorld/TransitionWorld/Transition%20Demo/Demo3)

效果如下：

![](./resource/demo3.gif)

核心系统方法：

```oc
// UIPercentDrivenInteractiveTransition 三个核心方法
[self updateInteractiveTransition:progress]

[self cancelInteractiveTransition]

[self finishInteractiveTransition]
```

然后在代理方法中返回这个 InteractionController 对象即可

```
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.slideInteractionController.interactionInProgress) {
        return self.slideInteractionController;
    }
    
    return nil;
}
```

> 总结：转场动画为了可复用性，定义了太多的协议，因此一定要搞清楚各自的职责。
> 从层级最高的来讲是 `UIViewControllerTransitioningDelegate` ，也就是我们经常设置的`delegate`，它从大方向上指明了我们应该可选的不同职责的对象：

1. 转场显示的动画对象(`animationControllerForPresentedController`)；
2. 转场消失的动画对象(`animationControllerForDismissedController`)；
3. 可交互的动画显示对象(`interactionControllerForPresentation`)；
4. 可交互的动画消息对象(`interactionControllerForDismissal`)；
5. 呈现方式(`presentationControllerForPresentedViewController`);

> 如上所述每一个动画/可交互对象同样需要时遵循协议的，比如动画的需要`UIViewControllerAnimatedTransitioning`协议;可交互式对象为`UIViewControllerInteractiveTransitioning`协议；呈现的对象干脆就是一个封装好的基类`UIPresentationController`

码代码过程中，如果我们二次封装，我觉得动画对象应该持有一个可交互式的对象，但是要以依赖注入的方式！

遗留问题：
1. 当progress进度小于0.5放手时也执行了dismiss操作，这个是不合理的;
2. 实例化一个 InteractionController 的方式需要把手势加载到sourceViewController的view上，项目中过早的调用 viewController.view可能导致视图控制器LifeCycle生命周期错乱的可能性。



# 2018/09/05

[右上角圆形发散式转场，参照Raywenderlich](https://github.com/colourful987/2018-Read-Record/tree/master/Content/iOS/TransitionWorld/TransitionWorld/Transition%20Demo/Demo4)

效果如下：

![](./resource/demo4.gif)





# 2018/09/06
重要事情说三遍：
1. **只要设置**`destinationVC.transitioningDelegate = self`就可以了，如果没有实现自定义呈现类，**不要设置**`destinationVC.modalPresentationStyle = UIModalPresentationCustom`!!!
2. **只要设置**`destinationVC.transitioningDelegate = self`就可以了，如果没有实现自定义呈现类，**不要设置**`destinationVC.modalPresentationStyle = UIModalPresentationCustom`!!!
3. **只要设置**`destinationVC.transitioningDelegate = self`就可以了，如果没有实现自定义呈现类，**不要设置**`destinationVC.modalPresentationStyle = UIModalPresentationCustom`!!!

mmp的转成present的时候往 `transitionContext.containerView`(系统提供的`UITransitionView`) add子视图是没有问题的，但是dismiss的时候却“不正常”，动画正确地执行，然后黑屏！其实“不正常”是情理之中的事情，因为设置了 `destinationVC.modalPresentationStyle = UIModalPresentationCustom;`，系统会向delegate询问关于呈现（Presentation）由谁负责：

```oc
// 如下写法
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[DimmingPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

// 附上DimmingPresentationController的实现

@interface DimmingPresentationController()
@property(nonatomic, strong)CHGradientView *dimmingView;
@end

@implementation DimmingPresentationController

- (void)presentationTransitionWillBegin {
    self.dimmingView.frame = self.containerView.bounds;
    [self.containerView insertSubview:self.dimmingView atIndex:0];
    self.dimmingView.alpha = 0;
    
    id <UIViewControllerTransitionCoordinator> transitionCoordinator =  self.presentedViewController.transitionCoordinator;
    
    if (transitionCoordinator) {
        [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.dimmingView.alpha = 1;
        } completion:nil];
    }
}

- (void)dismissalTransitionWillBegin {
    id <UIViewControllerTransitionCoordinator> transitionCoordinator =  self.presentedViewController.transitionCoordinator;
    
    if (transitionCoordinator) {
        [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.dimmingView.alpha = 0;
        } completion:nil];
    }
}

// 如果是半屏的话 这个属性设置为NO 表明不移除当前视图
- (BOOL)shouldRemovePresentersView {
    return NO;
}

- (CHGradientView *)dimmingView {
    if (!_dimmingView) {
        _dimmingView = [[CHGradientView alloc] initWithFrame:CGRectZero];
    }
    return _dimmingView;
}
@end
```

说一个视图是 `presentedViewController` 还是 `presentingViewController` ，是有个相对关系的，一定要说 A 是 B 的 `presentedViewController/presentingViewController`。

一个视图控制器即可以是`presentedViewController` 也可以是 `presentingViewController`，比如 A present B, B present C，那么 B 就扮演了两个角色，B是A的 presentedViewController，又是C的presentingViewController；
A 则简单点，是B的presentingViewController；C则只有一种角色，是B的presentedViewController。



# 2018/09/07

[Book 模仿书本翻页动画，参照Raywenderlich](https://github.com/colourful987/2018-Read-Record/tree/master/Content/iOS/BookTutorial)

效果如下：

![](./resource/bookTutorial.gif)
    
之前作者的 demo 停留在 swift2.x版本，所以特地改写了下，然而没有用最新的swift语法，能跑就行。

整个例子重点是实现的思路，以及collectionView的使用技巧，真的很牛逼！

另外目前只是做了代码搬运工，表示毫无成就感，一没把collectionView运用的得心应手，二不了解这个翻页动画的实现，三... 趁着周末学习一波，起码要有收获，尽量不做代码搬运工，伪成就感还是不要有的好。



# 2018/09/08 - 2018/09/09
给Book animation tutorial工程增加了注释，从几何角度了解这个翻页动画的实现，难点还是`CATransform`的知识 目前搜了几篇文章，可以学习一波基础知识：

* [CGAffineTransform与CATransform3D](https://www.cnblogs.com/jingdizhiwa/p/5481072.html)
* [如何使用 CATransform3D 处理 3D 影像、制做互动立体旋转的效果 ?](http://www.myzaker.com/article/591d1d7a1bc8e04e43000002/)
* [iOS-从三维立方体到理解CATransform3D&CGAffineTransform&m34](https://www.jianshu.com/p/3dd14cfbdc53)

ps: 貌似大家都喜欢以三维矩形筛子来作为演示demo，撞车比较严重



# 2018/09/10

> 教师节快乐！撒花！

给Book animation tutorial 整个demo用swift4.2重写了，需要在Xcode10 iOS12.0下运行。其实这个教程刚出来时候就对着码了，当时说白了也是抄着玩（现在也差不多orz...)，感觉吃透这篇文章可以学习以下几块知识点：
1. collectionView 自定义布局如何实现书本展开、转盘等效果，这里涉及重写 collectionView 的 `layoutAttributesForElements` 等一系列方法，难度2/5星吧；
2. transform 三维上的仿射变换，这个涉及数学几何知识，难度3/5；
3. 转场动画，由于之前已经“瞎搞过一阵子”，所以感觉难度在1/5星；

# 2018/09/11
本周会研究下 tableview 的 reload 操作实现，可以参照的源码 [Chameleon](https://github.com/BigZaphod/Chameleon)，Chameleon is a port of Apple's UIKit (and some minimal related frameworks) to Mac OS X. 说白了就是从iOS移植到Mac端的代码，尽管最后一次提交代码还停留在4 years ago，但是参考价值很足。

其次还涉及到 Runloop，毕竟我们操作的东西都是由runloop对象管理的，大部分其实是procedure过程式，处理流程就摆在那里，源码我看的是 github 上的 apple repo：[swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation)。

实际开发中经常会用到 GCD 配合 reloadData  对 TableView  刷新，所以对 GCD 底层实现原理还需要了解，源码应该会看libdispatch。

最后还是站在前人肩膀上，看了下[iOS 事件处理机制与图像渲染过程](http://www.cnblogs.com/yulang314/p/5091894.html)，差不多算16年的博文了，具有参考价值，本文的reference还涉及了如下文章：

* runloop原理 (https://github.com/ming1016/study/wiki/CFRunLoop)
* 深入理解runloop (http://blog.ibireme.com/2015/05/18/runloop/)
* 线程安全类的设计 (http://objccn.io/issue-2-4/)
* iOS保持界面流畅的技巧和AsyncDisplay介绍 （http://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/）
* 离屏渲染 (http://foggry.com/blog/2015/05/06/chi-ping-xuan-ran-xue-xi-bi-ji/)
* ios核心动画高级技巧 (https://zsisme.gitbooks.io/ios-/content/index.html)



# 2018/09/11 
今天查了一个UIWebview加载网页资源慢的问题，涉及NSURLCache缓存策略，由于之前都不怎么涉及Web相关的业务，所以排查这个问题对于我这个小白来说有些许挑战，一开始比较心虚，像个无头苍蝇没有切入点，在经过一系列 Charles 抓包，调试 UIWebview 、NSURLCache 相关源码，渐渐找到一些眉目，不过根本原因还是未解决，现简单记录下采坑记录，引以为鉴：

1. 关于Charles如何抓包，网上搜关键字应该一堆博文，这里不再赘述，因为我这里一些资源和链接是https，因此我们需要安装Charles的PC充当中间人，和服务器进行TLS/SSL握手通讯，此处客户端需要安装一个证书，在手机端Safari输入`chls.pro/ssl` 地址安装即可；另外还需要在PC端Charles的 SSL Proxying菜单原乡中安装根证书，以及在SSL Proxy Settings 添加需要监视的域名，支持 *号通配符，端口一般都是`443:`。
2. 客户端在联调时候加载一个网页，相应的 Charles 中就能看到这个请求的 request和response信息，这里我关心资源（这里是img或gif资源）的 response header，因为里面有我想要的 `Cache-Control`、`Expires` 和 `Last-Modified` 等信息，这些表示对于缓存由什么作用呢？看名字其实一目了然，如果设置 `Cache-Control` 为 `no-cache` 显然对于这个服务器返回的资源不要做缓存处理，过期时间也是这个道理。
3. 另外还有一种缓存方式为服务器返回403，那么客户端就使用之前缓存过的页面和资源，这里不是很清楚。
4. UIWebview loadRequest时候，request 的 cache policy 默认是 `NSURLRequestUseProtocolCachePolicy`，即由服务端返回资源的 responseHeader 中带的信息决定，也就是上面说的`Cache-Control`、`Expires`等
5. html加载过程：客户端发请求->服务端返回html标记文本->html会有一些css，js，或者`<img src='./path/to/img'>` 标记符中的资源文件，这些都是异步加载的，如果有缓存的话，那么根据策略来使用缓存，同时还可能去请求，请求回来之后再刷新，但是有些是仅使用缓存或者始终以服务端数据为准，这个就有些坑爹了....

看了几个网页，发现有些资源的 `Cache-Control` 设置为了 `no-cache` ，那么自然每次进来都会重新请求资源数据喽；但是有些页面的广告图片明明设置了 `Cache-Control` 为 `max-xxxxx` 以及过期时间，我在调试时候发现，NSURLCache 的 `cachedResponseForRequest` 方法中，以资源request为key去取缓存，返回的依然是nil...这个就不理解了。



# 2018/09/12 

进一步了解 NSURLCache 缓存机制，但是仅限于皮毛，我使用 MacOS 自带的 Apache 服务器，用PHP写了一个page页面，显示一些 `<p></p>` 文本和一个 `<img>` 用于异步加载图片，而服务端获取图片的接口同样是 PHP 实现，可配置 response header 为 no-cache，同样 page页面也可以这么干，以下demo是我从网上找到的设置方式：

```php
sleep(5); // 模拟图片获取耗时操作 这样能明显感觉到是否图片被NSURLCache缓存


$fullpath = '/path/to/image' . basename($_GET['img']); 

if (!is_file($fullpath)) { 
    header("HTTP/1.0 404 Not Found"); 
    exit(); 
} 

// 获取图片信息 
$info = getImageSize($fullpath); 

// 如果不是图片
if (!$info) {                     
    header("HTTP/1.0 404 Not Found"); 
    exit(); 
} 
 
// 以下凡是header函数都是在输出头部信息。较多。 
header('Content-type: '. $info['mime']);          // e.g. image/png 
header('Content-Length: '. filesize($fullpath));  // 文件长度 
 
header('Pragma: ');  
 
// 手动设置过期时间，单位都是秒 
$validtime = 48* 60 * 60;    // 48小时 
 
// 缓存相对请求的时间， 
header('Cache-Control: ' . 'max-age='. $validtime); 
 
//也很重要的Expires头，功能类似于max-age 
//time()+$validtime: 设置期限，到期后才会向服务器提交请求 
//gmdate，生成Sun, 01 Mar 2009 04:05:49 +0000  的字符串，而且是GMT标准时区 
//preg_replace,  生成Sun, 01 Mar 2009 04:05:49 GMT， 注意：可能与服务器设置有关， 
//但我都用默认设置 
header('Expires:'. preg_replace('/.{5}$/', 'GMT', gmdate('r', time()+ $validtime))); 
 
//文件最后修改时间 
$lasttime = filemtime($fullpath); 
 
//最后修改时间，设置了，点击刷新时，浏览器再次请求图片才会发出'IF_MODIFIED_SINCE'头， 
//从而被php程序读取 
header('Last-Modified: ' . preg_replace('/.{5}$/', 'GMT', gmdate('r', $lasttime) )); 
 
//重要，如果请求中的时间和 文件生成时间戳相等，则文件未修改，客户端可用缓存 
if (strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) == $lasttime) { 
    header("HTTP/1.1 304 Not Modified"); //服务器发出文件不曾修改的指令 
    exit(); 
} 
 
//如果文件被修改了，只好重新发出数据 
echo file_get_contents($fullpath);
```

其实我们只需要简单设置 header 中的 `Cache-Control` 等属性即可使得image不缓存。

iOS Demo 非常简单，就是搞一个UIWebView加载我们本地服务器的page.php页面来验证：

```oc
NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://127.0.0.1/page.php"]];
[self.webview loadRequest:request];
```

为了验证昨天 NSURLCache 系统类的 `- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request` 和 `- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request` 何时被UIWebView调用（苹果自带使用 URL Loading System），我们需要替换掉系统默认的 NSURLCache，如何替换？很简单，首先 NSURLCache 类有一个 `sharedURLCache` 单例，替换它为我们自定义的 NSURLCache 实例即可，如下：

```
@implementation CustomURLCache

// override
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSCachedURLResponse *resp = [super cachedResponseForRequest:request];
    
    NSLog(@"🔴cachedResponseForRequest request : %@", request.URL.absoluteString);
    NSLog(@"🔴cachedResponseForRequest response header: %@", [(NSHTTPURLResponse *)resp.response allHeaderFields]);
    
    return resp;
}

// override
- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    
    NSLog(@"✅storeCachedResponse request : %@", request.URL.absoluteString);
    NSLog(@"✅storeCachedResponse response header: %@", [(NSHTTPURLResponse *)cachedResponse.response allHeaderFields]);
    
    [super storeCachedResponse:cachedResponse forRequest:request];
}

// private
- (void)clearCache {
    [self removeAllCachedResponses];
}
```
然后找一个合适的地方替换 `[NSURLCache sharedURLCache]` 即可：

```oc
self.cache = [[CustomURLCache alloc] initWithMemoryCapacity:1024*1024*10 diskCapacity:1024*1024*60 diskPath:nil];
[NSURLCache setSharedURLCache:self.cache];
```

设置完毕后，开始调试这个demo：第一次加载时候，先出现html中的文字，然后等约5秒后加载出image图片。
* `cachedResponseForRequest` 和 `storeCachedResponse` 都会被调用两次，第一次是刚进入页面加载html link之前，因为先要确定本地是否有缓存，注意到前一个方法return了 nil，所以会加载页面，服务器返回html文本后会调用后者方法，因为要把这个response存储到本地————不管response header有没有设置 Cache-Control 等属性；
* 第二次进入的时候，依然且一定先调用 `cachedResponseForRequest` 方法， request 为page地址，从日志还能看到从本地读出了Cache.....；但是从charles抓包可以看到发送了一个请求，我猜测尽管能从本地读出缓存，但是缓存response中的header信息标识这个是不使用缓存的，因此会发一个请求；
* 总结来说如果取出的response header标识使用了缓存，那么不会再发送请求，也不会有 `storeCachedResponse` 回调；但是如果发送了请求，数据回调后肯定会调用 `storeCachedResponse` 方法存储数据到本地

> 关于缓存的文件和response信息存储地址，使用模拟器的话，应该存储在类似：`~/Library/Developer/CoreSimulator/Devices/15843FEA-1A4A-4F4A-B3C8-014EEA3A11B9/data/Containers/Data/Application/05BCB4F0-4AD7-477C-9CC2-B49C133E8F5C` 有个 Cache.db 文件，如何查看这个db文件，我们可以使用例如 Daturn Free 和 Liya工具，也可以使用 CommandLine，输入 `sqlite3 Cache.db` 命令，然后键入一些数据库查询命令，如 `.tables` 、`select * from table_name`等


# 2018/09/14

今天继续排查问题过程中发现我们项目的工程存在调用的差异，疑点如下：
1. 第二次进入过“缓存” 的页面，部分请求并没有走 `cachedResponseForRequest`发方法————前面说了Apple使用的  URL Loading System，所有请求都会走这个方法；
2. 部分请求走了 `cachedResponseForRequest` 方法，本地并没有缓存，因此需要再次发送请求，但是数据回调后没有调用 `storeCachedResponse`，本地db也没有存储。



# 2018/09/16

学习了 raywenderlich 的 drawPad demo，只是入门的学习制作一款绘图软件，没有undo操作，性能上目前来看是ok的，实现非常有意思：
1. demo使用两个imageView:mainImageView和tempImageView。当然绘制行为都需要一个 context，因此我们需要使用 `UIGraphicsBeginImageContext` 方法创建一个 context，紧接着调用 `UIGraphicsGetCurrentContext`，绘制行为的发起、进行和结束依靠 touchesBegan touchesMove touchesEnded 三个方法（重写ViewController即可，事件响应链可以参照[iOS Touch Event from the inside out](https://www.jianshu.com/p/70ba981317b6)）
2. 接着把上一次 tempImageView 的内容写入 context 中，顺便把当前的点连线也绘制到其中，最后把context生成一张image，在赋值给 tempImageView.image————令人疑惑的是这部操作在 touchesMoved中，不耗性能？
3. 最后touchesEnded时候，同样是创建一个 context，把mainImageView和tempImageView两者内容绘制到context中，生成新的image，赋值给 mainImageView.image，最后清空`tempImageView.image = nil`

现在存在几点疑惑：
1. 如何解决 undo 撤销操作，作者说可以使用 [UndoManager Tutorial: How to Implement With Swift Value Types](https://www.raywenderlich.com/5229-undomanager-tutorial-how-to-implement-with-swift-value-types)，没有尝试
2. 前面说到了 touchemove 一直在进行image写入context，然后在生成新image赋值回去的操作，这样不损耗性能吗？
3. demo只支持了绘制，那么对于添加一些矩形，圆形等如何实现呢？对图片进行放缩，平移等又怎么玩呢？





# 2018/09/17

补下昨天学习的东西，InjectionIII 的原理初探，参考文章是老峰的 [Injection：iOS热重载背后的黑魔法](https://mp.weixin.qq.com/s?__biz=MjM5NTQ2NzE0NQ==&mid=2247483999&idx=1&sn=bc88d37b6f819bd6bd7d8b76e9787620&chksm=a6f958b9918ed1af9a084ce2c2732aaee715193e37fdb830dc31d8f0174c0314b22dc5c0dd1e&mpshare=1&scene=1&srcid=0612tT8PS1pePiL5EmqMr9HH#rd)，自己当然也下了源码学习了一波，简单总结下知识点：

1. FileWatcher 的实现，其实就是Coreserver提供的 FSEventStreamCreate 创建一个事件流，这个方法定义如下：
  ```
  FSEventStreamCreate(
  CFAllocatorRef __nullable  allocator,
  FSEventStreamCallback      callback,
  FSEventStreamContext * __nullable context,
  CFArrayRef                 pathsToWatch,
  FSEventStreamEventId       sinceWhen,
  CFTimeInterval             latency,
  FSEventStreamCreateFlags   flags)  
  ```
  注意其中 `callback` 和 `pathsToWatch`，命名就已经很直白地告诉我们是要监控的文件夹目录和回调函数，文件改动采用枚举定义，有如下几种：`kFSEventStreamEventFlagItemRenamed` 、`kFSEventStreamEventFlagItemModified`、`kFSEventStreamEventFlagItemRemoved`，`kFSEventStreamEventFlagItemCreated`等几种；

2. Socket 通讯，首先Mac App InjectionIII 开启一个端口，然后程序app 在appdelegate中用mainbundle load的动态库也开启了一个端口，两者进行通讯，主要是发送一些信息告知对方处理进度；
3. 观察到文件改动，需要把改动的文件进行 rebuild 操作，这里使用了 Process 执行 shell 脚本命令字符串的方式，编译成dylib后通知应用App完成，客户端使用 dlopen 打开动态库，进行方法交换，然后刷新整个页面

目前遗留问题：
1. 首先由于沙盒安全问题，实际上我在码demo时候根本无法把脚本内容写入到一个.sh文件中。。。
2. 具体一些动态库的生成，比如app中加载 bundle 方式加载动态库我也比较懵逼，虽然网上我是看到有此类做法说明，但是如何制作这样一个 bundle的动态库呢？bundle不是一个资源包吗。。。还是说可以包含可执行文件的资源包

若有知道的朋友，可以提pr给我，感激不尽



# 2018/09/18

[TextKit 入门文章——raywenderlich](https://www.raywenderlich.com/5960-text-kit-tutorial-getting-started)

![](https://koenig-media.raywenderlich.com/uploads/2013/09/TextRenderingArchitecture-iOS7.png)

知识点：
1. 文字排版
2. attributeString，可以用正则匹配文案中的一些带标识符的特殊内容，已另外一种形式表现出来，比如bold加粗（`*content*`），italic斜体(`~content~`)

明天看教程下半部分，感觉可以撸一个markdown在线编辑器



# 2018/09/19

推荐两篇文章[C-Reduce Friday QA系列](https://www.mikeash.com/pyblog/friday-qa-2018-06-29-debugging-with-c-reduce.html)和[Design Patterns in Swift #3: Facade and Adapter](https://www.appcoda.com/design-pattern-structural/)

> 另外 UIWebview NSURLCache 测试验证 iOS12.0 缓存由问题，起码之前提到的两个方法中 `storeCachedResponse` 不会进入，查看本地 Cache.db 数据库也没有存储，应该是apple的sdk bug，难道是因为wkwebview，所以摒弃UIWebview了？

另外 WKWebview 今天帮忙改bug，其中就是前端使用 window.open 方式调用，需要wkwebview的configuration中的preference需要设置下`preferences.javaScriptCanOpenWindowsAutomatically = YES` 完整代码如下：

```
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
config.processPool = processPool;
WKPreferences *preferences = [WKPreferences new];
preferences.javaScriptCanOpenWindowsAutomatically = YES;// 设置了才会进 createWebViewWithConfiguration 代理方法
config.preferences = preferences;
self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
self.webView.backgroundColor = [UIColor clearColor];
self.webView.contentMode = UIViewContentModeRedraw;
self.webView.opaque = YES;
[self.view addSubview:self.webView];
[_webView setUserInteractionEnabled:YES];
_webView.navigationDelegate = self;
_webView.UIDelegate = self;

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    NSLog(@"createWebViewWithConfiguration  request     %@",navigationAction.request);
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
```
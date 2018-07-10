> Theme: JS Native Communication
> Source Code Read Plan:
> - [ ] JavaScriptCore 实现原理，热更新如何做到？
> - [x] WebViewJavascriptBridge 实现写博文；
> - [ ] WKWebview 之后是趋势，简单研究下使用
> - [ ] [JLRoute](https://github.com/joeldev/JLRoutes)
> - [ ] Method Forward
> - [ ] GCD 底层libdispatch
> - [ ] Aspect 温顾
> - [ ] YYModel 温顾
> - [ ] SwiftJson
> - [ ] SDWebImage

> Reference Book List:
- [ ] 《Git教程（廖雪峰）》

# 2018/07/01
【温习】KIZBehavior 设计思路：严格意义上来说，这并非是一个第三方库，而是提供解决问题的思路（设计模式），日常编码中我们会遇到产品提出的各种需求，比如这个textfield输入框限制10个字符、navigationBar的透明度随底部的 scrollview 滚动而变化、背景ImageView随 scrollview 滚动差速平移，这些和业务无关，所以我们通常会将其封装成一个对象，称之为 behavior，behavior 会和多个对象挂钩，同时也会“监听”某些Events， Behavior 属性声明所有关联的对象，内部实现来根据 Events 处理事务。

例如：
```
@interface MyBehavior : KIZBehavior
@property(nonatomic, weak)id object1;
@property(nonatomic, weak)id object2;
@property(nonatomic, weak)id object3;
//..声明所有关联对象，这里应该用 weak?
@end
```

`KIZMultipleProxyBehavior` 起到了Proxy中转消息派发的作用：

```

- (BOOL)respondsToSelector:(SEL)aSelector{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    for (id target in self.weakRefTargets) {
        if ([target respondsToSelector:aSelector]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (!sig) {
        for (id target in self.weakRefTargets) {
            if ((sig = [target methodSignatureForSelector:aSelector])) {
                break;
            }
        }
    }
    
    return sig;
}

//转发方法调用给所有delegate
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    for (id target in self.weakRefTargets) {
        if ([target respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:target];
        }
    }
}
```

Multi delegate message dispatch 设计要点在于message可能各式各样，某个消息可能只能让 delegates 中的一个或多个对象响应。

`KIZBehavior` 中的 owner，可设可不设，只是有时候为了取到对象而已，需要强转。

# 2018/07/03

iOS 客户端使用 Objective-c 语言，而 Web 端用到了 html 标记语言和 javascript 脚本语言，前者和页面样式相关，后者则是给页面添加交互行为，现在的问题是两者之间如何交互，如下图所示：

![native-js-reletation.png](./resource/native-js-reletation.png)

oc代码和js代码通常如下定义：

```
// oc 代码
@interface OBJCObject:NSObject
- (void)print;
@end

@implementation OBJCObject
- (void)print {
  NSLog(@"objc print object");
}
@end

// script 代码
<script type="text/javascript">
function display_alert()
  {
  alert("I am an alert box!!")
  }
</script>
```

* 网页中如何点击一个按钮调用 OBJCObject 的 print 方法；
* oc 如何调用 js 代码中的 `display_alert` 方法；

### oc 调用 js 代码
oc 并非直接调用 js 代码，而是调用 UIWebview 和 WKWebview 类开放的接口：

```
// UIWebview
- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

// WKWebview
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;
```

可以看到 oc 调用 js 代码非常简单，只需要将js命令转成字符串作为参数传给 evaluate 函数即可，所不同的是 WKWebview 还提供 js 执行完毕后的回调 block。

> 相对来说， oc 调用 js 的方式简单易懂，实现原理可能是动态往网页源码中注入 js 代码，构建调用已有的 js API接口。

### js 调用 oc 代码

js 同样并不能够直接调用 oc 代码，同时也没有开放类似 evaluateOC 这样的接口给 js 调用，这意味着 js 无法单向调用 oc 了吗？

实际上 webview 的 delegate 方法中有：

```
// UIWebview
- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener

// WKWebview
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
```

即网页端每发起一次请求，webview 都会拦截这个请求，由客户端决定是否真的发起一次请求，还是客户端拦截并做一些处理。

而 js 调用 oc 代码就需要在这里做文章了。不过 js 调用 oc 代码并非是一个 http 请求！所以我们需要将其封装成一个请求（比如我们约定是 `https://__js_call_oc__`），然后带上js调用oc的方法名称以及参数，这样就会触发 `decidePolicyForNavigationAction` 代理方法，然后客户端在此处拦截请求，判断这个请求是否为 `https://__js_call_oc__`，如果**是**则表示这次请求是 js 想要调用 oc 接口。 

```
- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if (webView != _webView) { return; }
    
    NSURL *url = [request URL];
    
    if ([_base isWebViewJavascriptBridgeURL:url]) {
        if ([_base isQueueMessageURL:url]) {
            // 1. 判断是否为 js 调用 oc 接口的消息
            NSString *messageQueueString = [self _evaluateJavascript:[_base webViewJavascriptFetchQueyCommand]];
            [_base flushMessageQueue:messageQueueString];
        } else {
            [_base logUnkownMessage:url];
        }
        [listener ignore];
    } 
}
```

代码注释 1 判断是否为 js 调用 oc 接口的消息，其实这里只能接收到请求链接，但是无法得知接口名称，maybe 可以 `https://__js_call_oc__?api=methodName`，我觉得简单的应该是可以适用的，但是如果webview积累了多条消息，这样就不合适了，所以客户端只需要 `[_base webViewJavascriptFetchQueyCommand]` 用 oc 调用 js 那一套(evaluate)来获取当前页面中缓存的所有调用消息，然后 `flushMessageQueue` 让客户端执行原生代码。

注意我们传递过来也不过是 methodName ，如何调用指定实例的指定方法呢？首先这么想就不符合设计原则，js怎么能随便调用任意实例的任意方法呢？起码要有限制啊，比如类自己开放几个接口供js调用，这样就要用到注册(register)了：

```
- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    _base.messageHandlers[handlerName] = [handler copy];
}
```

内部实现也很简单，字典作为存储容器，key=方法名称，value=block，其中方法名称是客户端和js端约定好的，我们在 `- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener` 拦截请求，如果是我们协议的请求，再通过oc调用js接口获取 `messageQueueString` ，此时获取到js想要调用oc的接口名称，我们从字典中拿到block，然后 `block()` 执行客户端代码。

因此，客户端必定有 `@property (strong, nonatomic) NSMutableDictionary* messageHandlers;` 字典类型变量来存储 block。

如果只是js->oc接口就此结束，那么上述实现方式就ok了，但是有些场景是 js 调用 oc ，oc 执行完毕，回调 js 告诉执行结果。

此处回调 js 告诉执行结果设计思路很简单，首先js一方先暂存callback，key 用一个 unique id，`[_base webViewJavascriptFetchQueyCommand]` 中我们即获取到方法名称，又获取到参数，此处传过来这个unique id

```
NSString* responseId = message[@"responseId"];
if (responseId) {
    WVJBResponseCallback responseCallback = _responseCallbacks[responseId];
    responseCallback(message[@"responseData"]);
    [self.responseCallbacks removeObjectForKey:responseId];
} else {
    WVJBResponseCallback responseCallback = NULL;
    NSString* callbackId = message[@"callbackId"];
    if (callbackId) {
        responseCallback = ^(id responseData) {
            if (responseData == nil) {
                responseData = [NSNull null];
            }
            
            WVJBMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
            // 1
            [self _queueMessage:msg];
        };
    } else {
        responseCallback = ^(id ignoreResponseData) {
            // Do nothing
        };
    }
    
    WVJBHandler handler = self.messageHandlers[message[@"handlerName"]];
    
    if (!handler) {
        NSLog(@"WVJBNoHandlerException, No handler for message from JS: %@", message);
        continue;
    }
    
    handler(message[@"data"], responseCallback);
}

// 而一般我们注册是如下：
[_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"testObjcCallback called: %@", data);
    // 注意这一行
    responseCallback(@"Response from testObjcCallback");
}];
```

注意responseCallback我们构造的代码块中 `[self _queueMessage:msg]` 就是oc 告诉 js 这个unique id。

2018/07/04 新增oc->js图：

![](./resource/oc->js.png)

知识点主要两点：
* 客户端和js都有 messageHandlers 和 responseCallbacks 字典，以 iOS 客户端为例，前者是oc端开放给js的接口，需要业务方往 UIWebView和 WKWebview 中注册，调用 registerHandler 方法；后者存储客户端调用js方法后的回调block，调用 callHandler 方法，ps：换句话说就是oc告诉js执行一个js方法，js执行完了，通知oc结果，oc对结果再做一些处理。
* 客户端调用js基于 webview 的 `stringByEvaluatingJavaScriptFromString` 方法；而 js 调用 oc 方法，是将任何页面的 action 都构造成一个 https:// 请求（构造一个iframe http element，设置它的src即可），oc客户端拦截解析分发处理接口。

# 2018/07/07
推荐 Mr_Wei 的 iOS 土味讲义：

* [iOS土味儿讲义（一）--一个Button引发的血案](https://juejin.im/post/5a951a1c6fb9a0633f0e471e)
* [iOS土味儿讲义（二）--弹窗的前世今生](https://juejin.im/post/5ab360d66fb9a028d14101e7)

展示了很多 runtime 的应用场景，当然并非真正应用到实际需求中，但是我觉得这种提供了很好的思路。“弹窗”一文解决方式个人顾虑影响范围，推荐自己单独搞一个 UIWindow 司职显示弹窗，同样是队列管理弹窗 present 顺序，设定不同弹窗的 level 等等特性

# 2018/07/09
[Video Streaming Tutorial for iOS: Getting Started](https://www.raywenderlich.com/188867/video-streaming-tutorial-for-ios-getting-started)

语音视频播放的基础入门文章，值得推荐，初始项目已经搭建完毕，只需要跟着文章填充关键代码即可，每一步都会介绍基础知识，最后完成基于 AVFoundation 的视频播放Demo。

![](https://koenig-media.raywenderlich.com/uploads/2018/04/Screen-Shot-2018-04-03-at-12.06.53-AM-650x256.png)

主要文章介绍两种：一、使用系统封装好的 AVPlayerViewController，我们只需要依赖注入一个 player 就可以播放视频了；二，自定义播放控件。

1. UI 方面，必定要有显示层，就是 AVPlayerLayer，当然我们一开始想到的可能是 UIView，实际UIView只是 Layer的代理，真正负责渲染的是 Layer，这里 AVPlayerLayer 会负责把一帧一帧的内容显示出来。我们如果要自定义一个播放器视图View，只需要明确自身持有的 layer 的 Class，如下：
  ```objc
  class VideoPlayerView: UIView {
    // 重写了基类的 layerClass 这样实例化一个 UIView 的同时实例化一个 layerClass 的图层
    override class var layerClass: AnyClass {
      return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
      return layer as! AVPlayerLayer
    }
  }
  ```

2. 接着从实际考虑，AVPlayerLayer 图层显示内容来源播放器，因此必定要关联一个 player 为其源源不断的输出一帧帧的画面，所以图层会绑定一个 player 播放器实例：
  ```objc
  var player: AVPlayer? {
    get {
      return playerLayer.player
    }
  
    set {
      playerLayer.player = newValue
    }
  }
  ```

3. 那播放器从何而来，播放必定要有资源吧，本地的视频？或者远端的视频？ 因此从设计角度来说，player 播放的单个内容我们封装成一个 AVPlayerItem，上面说的，然后对资源再细分一层 `AVAsset` 抽象不可变类，接触多的是 `AVURLAsset` 子类：

  ```objc
  let asset = AVURLAsset(url: video.url)
  let item = AVPlayerItem(asset: asset)
  
  // 这里展示把播放item “换碟” 给队列 player 中
  player.insert(item, after: player.items().last)
  ```

4. 至于播放器的控制，其实就是 play 和 pause 两个方法，其他属性包括音量(volume)，播放速度(rate)等等

> 总结步骤：先要有 `AVAsset` 资源(e.g.传一个url链接进去) --->  然后以此基础实例化一个 `AVPlayerItem` ----> 然后依赖注入到一个播放器实例 player 中，就好比放碟到 DVD 中 ---> 而 player 和硬件的屏幕是绑定的，player 输出一帧又一帧的画面传递给屏幕显示，这里屏幕就是我们的 AVPlayerLayer


# 2018/07/10

[Operation and OperationQueue Tutorial in Swift](https://www.raywenderlich.com/190008/operation-and-operationqueue-tutorial-in-swift)

GCD VS. Operation 

* GCD ，Grand Center Of Dispatch，轻量级支持多线程任务执行的方式之一，我们仅需要传入一个代码块 block，明确表示在哪个队列中(主队列【串行】、四个全局调度队列【并发】、自定义队列【串行or并发】)执行，你不需要自己创建子线程，不需要手动去触发这个代码块。GCD 会非常智能地从不同队列中取出任务然后调用，至于某些队列中的任务，GCD 需要创建新的线程，或者直接在已有的线程中执行，视情况而定，再说说GCD的缺点，依赖关系不好控制，cancel和suspend block又会增加额外工作；
* Operation 是基于 GCD 上构建的，但是相对于GCD 稍微设置工作量多点，但是我们可以轻松在Operation间设定依赖关系，以及执行取消或挂起操作。

本文也算是入门好文，简单说下 Operation 的使用当做记忆：

```
 // 首先构建操作队列
 lazy var downloadQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "Download queue"
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
```
队列中的操作无非就是add和remove，队列元素是 Operation，这是个抽象类，我们自定义的话就需要继承它：
```
class ImageDownloader: Operation {
  //1
  let photoRecord: PhotoRecord
  
  //2
  init(_ photoRecord: PhotoRecord) {
    self.photoRecord = photoRecord
  }
  
  //3
  override func main() {
    //4
    if isCancelled {
      return
    }

    //5
    guard let imageData = try? Data(contentsOf: photoRecord.url) else { return }
    
    //6
    if isCancelled {
      return
    }
    
    //7
    if !imageData.isEmpty {
      photoRecord.image = UIImage(data:imageData)
      photoRecord.state = .downloaded
    } else {
      photoRecord.state = .failed
      photoRecord.image = UIImage(named: "Failed")
    }
  }
}
```

OperationQueue 队列中添加 Operation

```
// 貌似会执行
pendingOperations.filtrationQueue.addOperation(filterer)
```

挂起：

```
pendingOperations.downloadQueue.isSuspended = false
```

添加依赖：

```
// MyDownloadOperation is a subclass of Operation
let downloadOperation = MyDownloadOperation()
// MyFilterOperation  is a subclass of Operation
let filterOperation = MyFilterOperation()

filterOperation.addDependency(downloadOperation)

```
为 Operation 添加 completionBlock:

```
downloader.completionBlock = {
    if downloader.isCancelled{return}
    
    DispatchQueue.main.async {
        self.pendingOperations.downloadsInProcess.removeValue(forKey: indexPath)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
```

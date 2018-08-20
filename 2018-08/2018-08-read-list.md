> Theme: Custom UIViewController Transitions && Computer underlying knowledge
> Source Code Read Plan:
>
> - [ ] GCD 底层libdispatch
> - [x] Aspect 温顾
> - [ ] `objc_msgSend` 汇编实现
>
> - [ ] WKWebview 之后是趋势，简单研究下使用
> - [ ] [JLRoute](https://github.com/joeldev/JLRoutes)
> - [ ] YYModel 温顾
> - [ ] SwiftJson
> - [ ] SDWebImage

# 2018/08/01

[Friday Q&A 2017-06-30: Dissecting objc_msgSend on ARM64](https://www.mikeash.com/pyblog/friday-qa-2017-06-30-dissecting-objc_msgsend-on-arm64.html)    

`objc_msgSend` 的汇编实现，但是ARM64的实现和 X86-64 还是略有不同。

# 2018/08/02

Aspect 温习第二天，再次熟悉关于核心的实现逻辑，类似于KVO作法，`objc_allocateClassPair` 以原有类对象创建一个新的subclass，然后再将新创建类对象的 `-(Class)class`实现替换掉，让人觉得“Class”还是原来的“Class”。

> 不过有个问题，替换新创建类对象的元类对象的 `+ (Class)class` 实现我可以理解，但是为啥返回的是 `statedClass`，这不是一个类对象吗？

接着方法方法交换掉 `selector` 的实现，加个前缀如 `_aspect_selectorName`，原来的 `selector` 实现IMP 指向 `_objc_msgForward_xxx` 方法，而原来的实现就绑定到了`_aspect_selectorName` 上面。

然后，新创建类对象的 `objc_msg_forward` 也是被方法交换成了一个静态方法，这个方法是我们来控制流程的。也是核心所在。

```objc
static void __ASPECTS_ARE_BEING_CALLED__(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {
    NSCParameterAssert(self);
    NSCParameterAssert(invocation);
    SEL originalSelector = invocation.selector;
	SEL aliasSelector = aspect_aliasForSelector(invocation.selector);
    invocation.selector = aliasSelector;
    AspectsContainer *objectContainer = objc_getAssociatedObject(self, aliasSelector);
    AspectsContainer *classContainer = aspect_getContainerForClass(object_getClass(self), aliasSelector);
    AspectInfo *info = [[AspectInfo alloc] initWithInstance:self invocation:invocation];
    NSArray *aspectsToRemove = nil;

    // Before hooks.
    aspect_invoke(classContainer.beforeAspects, info);
    aspect_invoke(objectContainer.beforeAspects, info);

    // Instead hooks.
    BOOL respondsToAlias = YES;
    if (objectContainer.insteadAspects.count || classContainer.insteadAspects.count) {
        aspect_invoke(classContainer.insteadAspects, info);
        aspect_invoke(objectContainer.insteadAspects, info);
    }else {
        Class klass = object_getClass(invocation.target);
        do {
            if ((respondsToAlias = [klass instancesRespondToSelector:aliasSelector])) {
                [invocation invoke];
                break;
            }
        }while (!respondsToAlias && (klass = class_getSuperclass(klass)));
    }

    // After hooks.
    aspect_invoke(classContainer.afterAspects, info);
    aspect_invoke(objectContainer.afterAspects, info);

    // If no hooks are installed, call original implementation (usually to throw an exception)
    if (!respondsToAlias) {
        invocation.selector = originalSelector;
        SEL originalForwardInvocationSEL = NSSelectorFromString(AspectsForwardInvocationSelectorName);
        if ([self respondsToSelector:originalForwardInvocationSEL]) {
            ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(self, originalForwardInvocationSEL, invocation);
        }else {
            [self doesNotRecognizeSelector:invocation.selector];
        }
    }

    // Remove any hooks that are queued for deregistration.
    [aspectsToRemove makeObjectsPerformSelector:@selector(remove)];
}
```

核心实现，逻辑比较简单、易懂。我记得这里有个小问题。



# 2018/08/04

[等额本金和等额本息视频讲解——李永乐](http://t.cn/ReevtJx?m=4268972146534009&u=3325704142)

首先是等额本金和等额本息的基本算法，其次是对于小额贷款公司的一些陷阱进行了讲解。

# 2018/08/05

* [为什么 objc_msgSend 必须用汇编实现](http://arigrant.com/blog/2014/2/12/why-objcmsgsend-must-be-written-in-assembly) 一文是简单的入门讲解；
* [Friday Q&A 2012-11-16: Let's Build objc_msgSend](https://www.mikeash.com/pyblog/friday-qa-2012-11-16-lets-build-objc_msgsend.html) 是12年mike Ash的简单入门实现，代码可以跑起来；
* [Friday Q&A 2017-06-30: Dissecting objc_msgSend on ARM64](https://www.mikeash.com/pyblog/friday-qa-2017-06-30-dissecting-objc_msgsend-on-arm64.html) mike Ash 在17年中旬时候详细的关于在arm上的 `objc_msgSend` 实现，非常值得学习

# 2018/08/06
[Document-Based Apps Tutorial: Getting Started](https://www.raywenderlich.com/188572/document-based-apps-tutorial-getting-started)

基于系统自带的 UIDocumentBrowser 开发一个文档可视化App，学习了一半，明天继续下半节。



# 2018/08/07
[Document-Based Apps Tutorial: Getting Started](https://www.raywenderlich.com/188572/document-based-apps-tutorial-getting-started)

下半节内容学习，实现了 `UIDocumentBrowserViewControllerDelegate` 的协议来自定义一些操作行为：
* `func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler : @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void)` 文件的创建，移动等操作
* `func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) ` 选中某个文档；
* `func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) ` 导入某个文件
* `func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) ` 导入失败

这里使用了策略模式，封装了一个对象遵循`UIDocumentBrowserViewControllerDelegate` 协议，然后实现了这四个方法，但是为了灵活性，这里的呈现方式是外部客赔的闭包。

文中选中一个文件呈现，使用了封装的 `MarkupViewController` 视图控制器。

另外是关于应用外部打开文件的方式：
![](https://koenig-media.raywenderlich.com/uploads/2018/04/url-open-flow.png)

其实主要还是 `AppDelegate` 的代理方法 `private func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:])`，这里我们会获取到window的rootViewController（这里是指定的一个视图控制器，能处理文件打开等事件）。



# 2018/08/10

[Design Patterns by Tutorials: MVVM](https://www.raywenderlich.com/34-design-patterns-by-tutorials-mvvm)

简单介绍MMVM介绍，以及推荐书。

MVVM 依赖双向绑定，因此在oc上基本都是“不伦不类”的“MVVM”，而引入RAC学习成本或许比较高（还未看过RAC源码）。

viewmodel 就是将 model 数据经过处理后转成 View 展示的信息，这里有个问题，是view绑定一个ViewModel，还是ViewModel开放一个接口 `configuration(customView:CustomView)`，外部传入自定义视图内部配置？

两者区别在于谁依赖谁，比较之下，我认为还是得分场景，貌似两者都是有存在的意义。

比如我们经常在UITableViewCell 中会开放一个 `configuration:(Model *)model` 接口用于配置UI，方法内部取数据再赋值给控件，这个视图不再“纯粹”，想要复用意味着你必须要将数据转成model再传入————当然你可以开另外一个接口，只不过会显得很乱；如果按照网上说的viewModel就是处理业务的，那么这里的model显然不是viewmodel，因为一个视图和业务viewModel绑定肯定无法复用了。

所以第二个方案，View就是一个纯粹的View，ViewModel就是处理业务的地方，持有model，然后内部处理得到和业务相关的数据，接着ViewModel开放一个接口 `configuration:(MyView *)myView`，内部可以使用诸如 `myView.label.text = @"处理完的数据"` 形式和上面一样，就看谁关联谁的问题了。

这个 MVVM 还是继续学习，感觉理解还不够到位，但是我坚信无论是 MVC 还是 MVVM，MVP都是为了解决问题而诞生的，所以存在即合理，关键是何种场景何种业务下能够发挥优势的问题。

# 2018/08/12
[How to Create Your Own Slide-Out Navigation Panel in Swift](https://www.raywenderlich.com/299-how-to-create-your-own-slide-out-navigation-panel-in-swift)

如何做一个抽屉视图控制器的入门文章，处理的比较简单，就是搞一个容器视图控制器，然后内部持有一个mainController(文中是CenterViewController)，leftPanelViewController和rightPanelViewController。

动画就是简单的控制center控制器View的frame，然后左右中控制器都是addChildViewController到当前视图控制器中，但是所不同的是，左右视图只有当出现的时候才会add到当前视图中，隐藏时会remove掉。



# 2018/08/13 (Custom UIViewController Transitions Subject Begin)
[Custom UIViewController Transitions: Getting Started](https://www.raywenderlich.com/322-custom-uiviewcontroller-transitions-getting-started)

raywenderlich 入门佳作提供了一个翻页 flip 转场动画，我从初学者的角度去理解转场动画的设计思路如下：

1. 转场动画发生在两个视图控制器的**View**之间，即一个视图控制器的View慢慢“退出”当前手机屏幕至不见，方式可以是淡出（Alpha从1->0），亦或者是整个视图平移出可视区域等等；而另外一个控制器的View以一定时间“进入”到当前可视区域中，方式也是多种多样，全凭想象；
2. 不同视图的转场动画都不尽相同，因此倘若我们写死在某个视图控制器中，那么违背了重用原则，另一方面，转场动画并没有涉及到业务方面的，它是通用的，即一个转场动画可以适用于不同的控制器，综上所述，我们可以将如何协调两个视图的显示这部分逻辑delegate出去，为了重用我们通常会将某个转场代码封装成一个对象；
3. 但是这个对象在完成转场动画中，肯定需要知道fromview和toview是哪个，最终的frame大小是多少等等信息，这些统称为 `transitionContext` 上下文，转场动画开始之前，底层会预先将所有信息以key-value方式写入到context中，紧接着在具体的转场方法中通过预先定义的key取到值来操作，通常用到的不外乎fromView toView FinalFrame等等

![](https://koenig-media.raywenderlich.com/uploads/2015/07/parts.001.jpg)

# 2018/08/14
[iOS Animation Tutorial: Custom View Controller Presentation Transitions](https://www.raywenderlich.com/359-ios-animation-tutorial-custom-view-controller-presentation-transitions)

多年前Raywenderlich animation一书中的例子，主界面是一个卡片式的浏览，选中某个卡牌进行放大至全屏Pop的转场动画。
昨日和今日的转场实现都是必须遵循 `UIViewControllerTransitioningDelegate`，协议内容如下： 

* `func animationController(forPresented presented:presenting:source:) -> UIViewControllerAnimatedTransitioning?`
* `func animationController(forDismissed dismissed:) -> UIViewControllerAnimatedTransitioning?`

本文的亮点将动画封装成了遵循 `UIViewControllerAnimatedTransitioning` 的**对象**，这个对象加入了 `presenting` 标识使得既可作为显示转场，又可用于消失转场动画。

对于 `Device Orientation Transition` 相关的还不是很了解，明天学习下如何仿照一个 Ping App作品中的某个动画，另外可以看到上面的动画都是在两个容器View的层面进行transform，而并没有涉及内部元素的动画，我们有时候可以看到某些转场动画中，视图中的子视图也有参与进来。

# 2018/08/15
[How To Make A UIViewController Transition Animation Like in the Ping App](https://www.raywenderlich.com/261-how-to-make-a-uiviewcontroller-transition-animation-like-in-the-ping-app)

今日模仿Ping App中转场动画，效果如下：

![](https://koenig-media.raywenderlich.com/uploads/2014/12/ping.gif)

首先不再是present动画了，而是navigation的动画，但是最终提供动画的对象要求遵循 `UIViewControllerAnimatedTransitioning` 协议。如何替换掉Navigation自带的转场，那么还得说到 UINavigationDelegate.

```oc
func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return CircularTransition()
}
```

注意到该代理方法其实返回一个转场动画的对象，这里我们封装成了 `CircularTransition` 类。

本文和上面两篇文章不同之处有三点：一、`CircularTransition` 类操作的不是一个具体的视图类，而是面向接口编程，即我们认为要动画的对象必须能够提供三个控件，为此我们声明了一个协议：

```oc
protocol CircleTransitionable {
    var triggerButton : UIButton { get }
    var contentTextView:UITextView {get}
    var mainView:UIView {get}
}
```

之后在实现 `UIViewControllerAnimatedTransitioning` 的 `animateTransition` 方法中我们获取到 fromVC 和 toVC都认为是遵循 `CircleTransitionable` 的对象，方便我们操作 triggerButton 或 contentView。

二、正如之前说的我们大部分时间都是在操作整个视图 fromVC和toVC的视图，做一些平移、旋转和变换，而本文使用了上述的接口，能够获取到具体的子视图，然后在动画方法中操作；
三、使用 maskLayer + CABasicAnimation + path 做一些炫酷的动画。

明日计划写一些简单的转场动画



# 2018/08/20
继续动画相关的学习，不仅限于转场，可是是UIView，Layer层面的动画。

[EasyAnimation](https://github.com/icanzilb/EasyAnimation)

**CollectionView + Layout** 实现书翻页的动画呈现，但是代码没有适配最新的swift4.0

[How to Create an iOS Book Open Animation: Part 1](https://www.raywenderlich.com/1719-how-to-create-an-ios-book-open-animation-part-1)

[How to Create an iOS Book Open Animation: Part 2](https://www.raywenderlich.com/1719-how-to-create-an-ios-book-open-animation-part-2)


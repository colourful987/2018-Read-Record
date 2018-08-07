> Theme: Computer underlying knowledge
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
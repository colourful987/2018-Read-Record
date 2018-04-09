> Theme: Charts For Stock 
> Source Code Read Plan: Charts      
> Reference Book List: 《Just For Fun》

# 2018/04/01
这两天简单读了下 [《Just For Fun》](https://book.douban.com/subject/1451172/) ，起初我以为 Linus Torvalds 的自传无非包含：
1. Linus Torvalds 家庭环境，如何造就了这位天才；
2. Linux 系统是如何诞生的；
3. Linus Torvalds 对 Linus 的开源态度，曾经是否考虑过商业化追求利益，事实证明在理查德.斯托曼(RMS)的先驱下(就是发布GPL开源协议牛人)，Linus 也是始终坚定不移的站在了开源阵营；当然关于财富，想必很多人和我一样非常好奇，因此网上简单搜了下：年薪1000万刀，身价15亿美元（这只是网上流传，无法考证），我觉得对于 Linus 做出的共享，这些财富又算得了什么呢？想想没有 Linux 系统，之后的服务端系统，Android，Git 等等将不复存在————当然不否认会出现其他替代品，正如Git就是因为BitKeeper不再为Linux提供版本管理服务，Linus和其他几个朋友花几星期时间写出来的，ORZ... 时代不会因为 Linus 而停止，但他的贡献值得肯定和赞美，鬼知道替代品是不是以收费，闭源形式出现呢？
4. Linus 性格腼腆，这是很多文章和杂志都有提及，这很符合大部分程序员的特性，hhh，不过话说回来，Linus 说自己第一次演讲并不顺利，之后几次也是如此，但随着不断邀约演讲，他慢慢克服了上述的紧张心理，原因是他觉得自己尼玛对Linux系统那么熟了，怕什么。讲些当初在设计Linux系统时碰到的问题和解决思路不就可以组成一个完整的演讲了嘛，此处再次膜拜！真是一个耿直的大神；
5. 最后自然是流传的 Linus 和 乔布斯 对话了，其实也没什么，正是因为 Linus 对 MacOS 的闭源做法嗤之以鼻————Mach内核开源又如何，又不是把整个操作系统开源！ 反正最后不了了之。

而真正读完整本传记的时候，我发现得到的东西太让我惊讶了， Linus 竟然有大半是在讲述技术方面，设计 Linux 时候遇到的问题，解决问题，后续考虑等等，虽说只是简单阐述，但也足够让我这种小白了解到linux系统发展史————如何从一个极其简单的系统一步步发展到几千万行的代码量，我爱死这种叙述方式了，Linus 果然与众不同！

自传之外还提及了一些Linus出生地芬兰的趣事，比如桑拿😂，赫尔辛基冬天贼冷。

> 摘自Linus关于三件对生活有意义的事：1.生存 2.社会秩序 3.娱乐。生活中所有的事就是要你达到第三个阶段。一旦达到了第三个阶段，这辈子你就算成功了。但是你得先超越前两个阶段。

Swift不知不觉已经更新到4.1版本了，我已经很少关注了，知识小集出了 [Swift 4.1 新特性概览](https://mp.weixin.qq.com/s/2PNE2yPIiyn4y-cqHZgWiQ)，现在简单过一下。

# 2018/04/07
THObserversAndBinders 源码初窥，其实就是为每个属性观察事件实例化一个中间件处理，中间件处理KVO的回调，而每个中间件必须要被持有。[总结链接传送门](https://github.com/colourful987/2018-Read-Record/blob/master/Content/iOS/THObserversAndBinders/如何实现一个优雅的KVO和KVB中间件.md)

# 2018/04/08
THObserversAndBinders 按照源码Coding，过程中想到几个问题：
1. 对于`NSMutableArray、NSMutableSet`类型的属性，如何才能触发通知？调用`removeAtIndex:`或是 `addObject` 可以吗？
2. 关于`addObserver: forKeyPath: options: context:` 接口中的 options 有什么用？通常我们都是不假思索的填充 `NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld`（0x01 | 0x02 = 0x03），直接设置option=0又会怎么样呢？
3. 通知回调接口中的 change 字典，我们可以使用 `NSKeyValueChangeKey` 类型的键去取值，分别是`NSKeyValueChangeKindKey`、`NSKeyValueChangeNewKey`、`NSKeyValueChangeOldKey`、`NSKeyValueChangeIndexesKey`和`NSKeyValueChangeNotificationIsPriorKey`，什么情况下我们可以通过这些key取到值，什么时候取不到(即为null)

带着这些问题我测试了下：
1. 关于集合，调用`removeAtIndex`这些方法并不会触发通知回调，参照接口注释，如下即可触发:

```
[[_observedObject mutableArrayValueForKey:@"arrayPropertyName"] addObjectsFromArray:@[@3,@4]];
```
回调方法中，`change[NSKeyValueChangeKindKey]` 的值为 2 表示插入操作，而不再是 1 Setting操作。

2. options 相当于告诉观察者当发生改变时，你把我指定的变化值放到 change 字典中传过来。倘若你设置 options = 0，当发生变动时会触发回调方法，但是 change 字典中并没有存相应的值，唯一存的key就是 `NSKeyValueChangeKindKey` 告知你变动的类型，一般都是Setting。
3. 只要触发回调，change 字典必定有 `NSKeyValueChangeKindKey` 键以及对应的值，至于触发类型是`NSKeyValueChangeSetting`、`NSKeyValueChangeInsertion`或是其他，就需要用 `mutableArrayValueForKey` 这种方式取到值，然后在进行`add` `remove` 操作。

# 2018/04/09
实现了 KVO 的 Binder，但是弊端很明显，依赖只能是1对1，而不是多对1，毕竟有些属性值是依赖多个其他值的。

* [x] 🏆[THObserversAndBinders](https://github.com/th-in-gs/THObserversAndBinders)源码阅读和总结

[如何实现一个优雅的KVO和KVB中间件](https://github.com/colourful987/2018-Read-Record/blob/master/Content/iOS/THObserversAndBinders/如何实现一个优雅的KVO和KVB中间件.md)
> Theme: 计算机底层知识
> Source Code Read Plan: Aspect
> Reference Book List: 《Code》《程序员的自我修养》

# 2018/02/01 dyld & runtime base knowledge
[Friday Q&A 2012-11-09: dyld: Dynamic Linking On OS X](https://www.mikeash.com/pyblog/friday-qa-2012-11-09-dyld-dynamic-linking-on-os-x.html)
[dyld 源代码gitHub链接](https://github.com/opensource-apple/dyld)
需要有汇编基础，底层知识，否则阅读起来有点吃力，推荐《程序员的自我修养》这本书。

总结：
[runtime - self super的理解](quiver-note-url/8D998466-EC2F-41AE-B9E1-B3623872E46E)
[runtime - class & instance object & class object & meta class object](quiver-note-url/51FDBE0D-D81B-4A01-9716-E092299018FC)

# 2018/02/02
昨天的汇编把我虐的不轻，所以今天特地搜了几篇文章补补基础知识，顺便学习了一些计算机基础知识：CPU架构、指令集以及过往发展历史，这是个文集，感觉写得全面易懂：
[1.深入iOS系统底层之汇编语言](https://www.jianshu.com/p/ff8ed52bdd67)
[2.深入iOS系统底层之指令集介绍](https://www.jianshu.com/p/54884ce976ca)
[3.深入iOS系统底层之XCODE对汇编的支持介绍](https://www.jianshu.com/p/365ed6c385e5)

接下来可能会先重拾 《Code》 这本书，然后是《程序员自我修养》和源代码阅读（Runtime、GCD、RunLoop、Block）“并行”学习。 

# 2018/02/03 ~ 02/04
温顾了《Code 编码隐匿在计算机软硬件背后的语言》一书，本文主要以继电器实物来讲解一些电路，逻辑门电路：与门，或门，与非门，或非门，异或门等，关于触发器:D触发器，边沿触发器；然后组合可以得到半加器，加法器等。其中触发器的理解稍微难一些。

关于17章中开始部分和硬件电路配合解释如何执行一段加法程序，即依次从存储器（RAM阵列——由很多个保存状态的触发器组成）中读入数据，传递给加法器硬件的IN端，然后输出，当然这里的前提是CLK的信号要能足够让指令执行完（这里有待理解）；后面引入了instruction指令，此时搞了两个RAM，一个存指令(可以理解为我们写入的代码)，一个作为数据存储——可写可读，使用寻址方式。 此时指令按周期输出，这里其实涉及到控制单元，这里的电路实现没有说清楚。

18章简单回溯了计算机发展史，继电器->真空管->晶体管->IC（Integrate Circuit 可以理解为芯片电路，在此前都是晶体管插拔）

19章主要是介绍微处理器，然后引入了汇编基础介绍，没涉及任何物理电路讲解，比较枯燥

# 2018/02/05 
[iOS 保持界面流畅的技巧](https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)

总结：

![CRT 电子枪屏幕渲染顺序](https://blog.ibireme.com/wp-content/uploads/2015/11/ios_screen_scan.png)

显示屏本质为二极管等物理原件色彩填充，输入源输入第一行数据->屏幕渲染一行（从左到右）后 set siganl（HSync???）-> 输入源输入第二行 -> 屏幕渲染第二行->...反复执行这一行为至到底部最后一行->整屏(一帧)渲染完毕，显示器set signal(VSync) 即表示回到左上角起始位置，输入源更换下一帧数据继续。

![总线电路](https://blog.ibireme.com/wp-content/uploads/2015/11/ios_screen_display.png)

至始至终都是视频控制器作为发起方给显示器注入每一行数据，当然显示器也会给回调信号表明当前状态。

CPU负责视图创建，约束计算等，此时不产生任何视图渲染行为，把数据给GPU进行枯燥乏味的变换转成每一帧数据，然后放到帧缓存区，供视频控制器读取数据传递给显示器。

### 帧缓存区 视频控制器 显示器 三者协作

前提是已经有一帧数据在缓存区，视频控制器读取第一行数据传递给显示器，显示器渲染后返回HSync信号，视频控制器读取第二行数据给显示器....直到读取最后一行数据给显示器，显示器回传VSync信号，视频控制器把指针指向缓存器左上角起始位置。这样一帧应该耗时1/60 秒。

现在问题在于视频控制器要读下一帧了，但缓存器还是保留旧数据，是否等待GPU把下一帧数据写入到缓存区，然后视频控制器在开始读呢？

可以，但是效率太低，其次中间GPU写入的过程中视频控制器和显示屏始终处于“闲置”状态————当然显示屏还呈现上一帧的画面。

有人说既然视频控制器已经读完了缓存区第一帧，第二帧，只有当读到帧尾部时候再返回顶部重新读，那这时候GPU写第一帧，第二帧也是OK的（当然GPU写的必须等于视频控制器读入传递给显示器的速率 快或慢都会导致不同步）。

双缓存区

```
------------------           ------------------ 
|    cache 1     |           |     cache 2    |
|    Frame 1     |           |     Frame 2    |
------------------           ------------------ 
/|\
 |
 |
 视频控制器指向第一个缓存
```

GPU写入第二帧的时候，会把视频控制器的指针指向第二个缓存区？？？？？

如果GPU马上计算完第二帧数据写入到缓存区，此时视频控制器读了一半，而内容却被替换掉了，下半段开始读新的一帧数据，而上半部分显示的是旧的。

> 这里不太理解ibireme说的“GPU 将新的一帧内容提交到帧缓冲区并把两个缓冲区进行交换后”。

我认为写入第二个缓存区后，马上会替换掉第一个缓存区的数据，这样理解才合理。

所以GPU为了解决这个问题，有一个垂直同步机制（VSync）,只有当上一帧数据完全被视频控制器传输给显示器呈现了，返回了VSync信号，才会把下一帧数据导入。

当开启垂直同步后，GPU 会等待显示器的 VSync 信号发出后，**才进行新的一帧渲染和缓冲区更新**。

这里有两个分支理解：

1. CPU和GPU计算特别快会怎么样？ A: CPU可能每0.01秒就能计算一帧的数据，即帧数为100。假如画面是显示一个物体的运动轨迹，一秒平移100米，0.01秒平移1米，那么产生的100张图片里面的物体距离间隔为1米。但是显示屏的刷新频率是固定的，60帧一秒（0.016秒一帧），所以视频控制器只会从100张图片中显示连续的60张图片，当然中间会略过几张，但对于人眼来说，60张图片1秒内连续播放，你是感觉不到任何不连贯性；
2. 如果在一个 VSync 时间内，CPU 或者 GPU 没有完成内容提交，则那一帧就会被丢弃，等待下一次机会再显示，而这时显示屏会保留之前的内容不变。这就是界面卡顿的原因。

### Aspect 初探
Aspect 可以对 intance object， class object 都允许**多次(重复)**，hook的时机可以是before或after甚至 instand (swizzle)。

1. 每一条Track信息封装成 `AspectIdentifier`，针对某个 selector 的所有aspect方法都整合到 `AspectsContainer`，这里需要用到runtime基础知识： `objc_getAssociatedObject` 和 `objc_setAssociatedObject`;
2. 核心一：运行时动态生成一个基于当前类的子类，然后方法交换 forwardInvocation 和自己实现的一个总入口，ps: 所有的object都会走到这个自定义 forwardInvocation 全局函数中处理；
3. 核心二：subclass 的 `selectorA` 方法IMP会被替换成汇编的`_objc_msgForward`，相当于给 `[object selectorA]` 会立马触发一次消息方法；另一边我们会添加一个 `aliasSelectorA` 方法，实现为originalIMP。 紧接着说消息转发会调用 `forwardInvocation`，但是实现已经被我们自定义方法替换掉了，所以最后都会走到 `__ASPECTS_ARE_BEING_CALLED__` 方法，方法第一个参数self，第二个参数selector，这样我们去到self绑定的 `AspectsContainer` ，取到每一条aspect切面方法调用，而originalIMP 则只需要 [self aliasSelectorA] 即可


# 2018/02/06
内容和本期主题无关，关于金融股票中的分时K线图，搜了几个源码：
1. BBStockChartView-master
2. CCLKLineChartView
3. chartee-master
4. FL_StockChart-master
5. HYStockChart
6. PHStockChart-master
7. RRStock
8. StockChart-master
9. YY_stock

看了各个项目的运行效果，更多的让人觉得只是个demo。

# 2018/02/08
[iOS架构之View层的架构方案](https://mp.weixin.qq.com/s/t_IBkCClPBZFBPmtZT0WsQ)
简单介绍了 MVC，MVVM，MVP，VIPER（View、Interactor、Presenter、Entity、Router），并未给实质性的帮助，不过喜欢作者的一句话：
> 好的架构需要1.解决现有问题；2.应对未来变化。

###Title
链接：
总结：


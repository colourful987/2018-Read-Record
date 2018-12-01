# 2018年学习历程记录

# Learning Recording Timeline

- [ ] [2018 十一月学习记录](./2018-12/2018-12-read-list.md)

> Theme: RunLoop主题、年度整理
> Source Code Read Plan:
- [ ] MachPort的设计思路以及写Example；
- [ ] Main RunLoop 默认添加了哪些 Mode，各适用于哪些场景；
- [ ] GCD Dispatch 的MachPort是怎么玩的；
- [ ] RunLoop 的休眠，休眠时候真的什么都不做吗？那视图渲染呢？
- [ ] Window 的 UI 渲染更新机制，是放在RunLoop哪个阶段做的；
- [ ] 昨日的 CFRunLoopDoBlocks 执行的是？
- [ ] RunLoop 的使用场景有哪些，具体实现又是怎么样的？
- [ ] GCD 为什么会有个 gcdDispatchPort?
- [ ] Observer 休眠前、休眠后等事件可以玩一些什么花样呢？

- [x] [2018 十一月学习记录](./2018-11/2018-11-read-list.md)

> Theme: 编译器/解释器
> Source Code Read Plan:
* [x] 实现一个计算器解释器；
* [x] 实现pascal解释器 ；
* [ ] 指标平台公示解释器；
* [x] AST source to source 解释成诸如C语言的其他形式，或者是自定义一门标记语言解释成OC的button或是html的元素；
* [x] 编译器的话，可能就是要基于 source to source 到汇编或者C代码，再用对应的编译器编译成可执行文件。

> 十一月份的完成度较高，专注度也不错，另外每日会读一些杂书，比如关于物理、天文、逻辑等方面知识，对拓展思维很有帮助，毕竟每日满脑的编程是很无趣且限制思维的。

- [x] [2018 十月学习记录](./2018-10/2018-10-read-list.md)

> Theme:  待定
> Source Code Read Plan:  `objc_msgSend` 收尾，另外实现以下知乎和App Store中的几个转场动画。
>
> Core: 温顾了编译器/解释器相关知识，对于一个非科班出生的半吊子程序员，感觉收获还是蛮大，但是心中自知浮于表层，收效甚微。现在想来帮主之前分享读书经验时曾道：一鼓作气，再而衰，三而竭，读书亦是如此，虽知枯燥乏味，但仍久坐书桌前。11月尝试下，不说钻研，但求专心。



- [x] [2018 九月学习记录](./2018-09/2018-09-read-list.md)

> Theme: Computer underlying knowledge && Custom UIViewController Transitions （收尾）
> Source Code Read Plan:学习了 `objc_msgSend` 汇编实现，实现了一些Custom UIViewController Transition。
> Reference Book List: 
>
> Summary：本月学习到的收获主要是转场动画，以及最近几天的 asm 学习，收获颇丰，对理解堆栈，内存对齐，指令调用等等都算是近了一步。说实在的，汇编入门难，毕竟偏底层，暂时没有实际应用场景过，基本都停留在分析已有的源码上。



- [x] [2018 八月学习记录 ](./2018-08/2018-08-read-list.md)

> Theme:  Custom UIViewController Transitions
> [TransitionWorld](https://github.com/colourful987/2018-Read-Record/tree/master/Content/iOS/TransitionWorld/)写了一些转场动画。转场其实考验的是交互设计，代码上尽管实现起来也稍有难度，但是如果分解成各个子动画，还是都能写出来，感觉转场动画在复用上实在...比较困难...很难统一



- [x] [2018 七月学习记录](./2018-07/2018-07-read-list.md)

> Theme: JS Native Communication
> 总结: 阅读了 WebViewJavascriptBridge ，JSPatch部分源码，然后又稀里糊涂开始补 raywenderlich 网站上的 tutorial，看了 AVPlayer 的两篇文章，以及 NSOperation 使用等；如何封装一个 framework 入门文章非常推荐，不仅学习如何构建一个framework，又能学习cocoapods制作pod的一个过程。
>
> 不好的点：感觉学的东西依旧很杂，没有章法，实际记住的东西也非常有限，感觉始终在门口溜达转圈，并非是瓶颈，而是一种迷茫，希望八月能够走出来。



- [x] [2018 六月学习记录](./2018-06/2018-06-read-list.md)

> Theme: 待定 
> Source Code Read Plan:
> Reference Book List:  



* [x] [2018 五月学习记录](./2018-05/2018-05-read-list.md)

> 完成了如下内容：
>
> - [x] [AppLord]()
>
> - [x] 《THE INNOVATORS》本月看了三分之二
> - [x] 《Curious git》




* [x] [2018 四月学习记录](./2018-04/2018-04-read-list.md)

> Theme: Charts For Stock 
> Source Code Read Plan: Charts      
> Reference Book List: 《Just For Fun》

* [【推荐👍👍👍】Swift 实现一个 pascal interpreter](https://github.com/colourful987/2018-Read-Record/tree/master/Content/iOS/Pascal%20Interperter/Swift%20Version)  感谢 Ruslan Spivak 的 Python 教程，从实现一个简单计算器慢慢过渡到实现一个pascal解释器，理解 Lexer、Token、AST Parser、Interpreter 的概念




* [x] [2018 三月学习记录 ](./2018-03/2018-03-read-list.md)


> Theme: Low-programming（Compiler & Interpreter）    
> Source Code Read Plan:  Charts     
> Reference Book List: objc App Architecture    
> 总结：本月2/3时间都是学习如何实现一个简单的解释器，基于 BNF 巴克斯-诺儿范式来写解释器，Tokenizer -> Lexical Analyzer -> Syntax Analyzer -> Interpreter。总的来看，本月完成度一般，最终没有实现自己的一门语言，这个会补上。



* [x] [2018 二月学习记录 ](./2018-02/2018-02-read-list.md)


> Theme: 计算机底层知识    
> Source Code Read Plan: Aspect      
> Reference Book List: 《Code》《程序员的自我修养》    
> 总结：本月略感成就的是写了关于如何用 C语言实现面向对象编程，[文章传送门](./2018-02/resource/C_IMP_Runtime.md)。




* [x] [2018 一月学习记录 ](./2018-01/2018-01-read-list.md)


> 总结：杂记



# 感想

前言：一月中旬萌生了记录日常学习经历的想法，那时候看到各位大佬都在总结 2017 年的收获以及展望2018。而自己回顾过去，学了很多，也忘了很多，感觉进步着实不大，拿不出任何值得称道的作品。为此，我再三思索之后，决定按月指定大计划，每月指定一个主题，或是一些目标：要看的书或文章，完成一个小作品等，规划好大方向后开始一步步实施，最终达成每月成就。目前来看，事实证明这种方式是非常适合我，不必受外界过多“打扰”，分散注意力，而是在月初制定的大方向中学习和探索，要知道新技术不断冒泡，而我的精力是有限的，不可能一会学习 AI，一会又是区块链，这么说并非意味着我闭门造车，而是暂时将其加入关注列表中，可能会为其制定一个Theme，抽空了解一番。

当然目前也遇到了一些问题，比如制定的计划和实际完成度稍有偏颇，效率感觉不算很高，工作时间之外挤时间学习真得很不容易，坚持更不容易。

不过遇到问题就要解决问题，计划可以实时校准修正；效率不高对于我来说是因为喜欢分屏Coding，目前可能会摒弃这一做法，我的注意力总是不自觉地会被吸引过去；周六周末少睡会懒觉出去泡泡图书馆，找个安静的咖啡馆Coding，既可以增加可利用时间，又能够养成好的生物钟。—— pmst  2018.04.01 

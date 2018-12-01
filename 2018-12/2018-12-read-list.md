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
> reference：

* [Interprocess communication on iOS with Berkeley sockets](http://ddeville.me/2015/02/interprocess-communication-on-ios-with-berkeley-sockets) 
* [mach_port_t for inter-process communication](http://fdiv.net/2011/01/14/machportt-inter-process-communication) 
* [Mach Messaging and Mach Interprocess Communication](https://docs.huihoo.com/darwin/kernel-programming-guide/boundaries/chapter_14_section_4.html) 
* [Abusing Mach on Mac OS X - Uninformed pdf](https://www.google.co.jp/url?sa=t&rct=j&q=&esrc=s&source=web&cd=8&cad=rja&uact=8&ved=2ahUKEwjD-qGbr_zeAhWBi7wKHYRYDk8QFjAHegQIAxAC&url=http%3A%2F%2Fwww.uninformed.org%2F%3Fv%3D4%26a%3D3%26t%3Dpdf&usg=AOvVaw3sraSLdwRTvPca4iHV5NDL)

# 2018/12/01

开箱
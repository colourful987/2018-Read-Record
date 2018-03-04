> Theme: App Architecture & Low-programming    
> Source Code Read Plan: Still Aspect      
> Reference Book List: objc App Architecture

# 2018/03/01 - 2018/03/02

[推荐：C语言实现 OC 运行时一步步推倒过程](https://github.com/colourful987/2018-Read-Record/blob/master/2018-02/resource/C_IMP_Runtime.md)


# 2018/03/03
[函数调用栈帧过程带图详解](http://blog.csdn.net/IT_10/article/details/52986350)

主要学习了 C 语言函数 stack frame 的知识以及一些简单的汇编指令：`mov 目的操作数 源操作数` 即源操作赋值给目的操作数；`lea edi,[ebp-44h]  mov acx,11h  mov eax,0CCCCCCCCh` edi存储起始地址，acx记录填充次数，eax存储要填充的占位数据；ebp 和 esp 是调用函数过程中比较重要的两个寄存器，其中ebp最为重要，取变量地址都是通过ebp+offset来取值。
> 这里有个坑没有填：文中说到的函数帧是先push 传参，然后push ebp，接着是call 返回地址，最后是函数的临时变量；而之前看到的是push ebp，push 返回地址，最后才是传参和临时变量。另外对于 `int x = 10;` 编译器会编译成如下命令`mov dword ptr [ebp-4],0Ah`，其实就是把 0Ah 这个值写入 `ebp-4` 地址上，至于 `dword ptr` 修饰`[ebp-4]` 是个四字节地址；而访问变量 x 的操作，其实也是对内存的操作。

Note: 编译之后压根不存在我们定义的数据结构！

其他关于函数调用栈的参考文章:    

[通过swap代码分析C语言指针在汇编级别的实现](http://www.cnblogs.com/inevermore/p/4393124.html)

[函数调用过程（ebp，esp） ](http://blog.163.com/yichangjun1989@126/blog/static/131972028201442221956603/)

[C 语言指针与汇编地址（一）](http://blog.csdn.net/lanchunhui/article/details/51366513)

# 2018/03/04
[objc App Architecture Introduction](https://www.objc.io/books/app-architecture/)     
设计一款应用时候可以从以下五点入手：
1. Construction: 谁创建View和Model，以及两者之间的关联；
2. Update the model: 哪些 View Action 处理需要修改model，比如界面上的按钮点击等；
3. Changing the view: model data 的改动又该如何反应到视图上；
4. View-state
5. Testing

主流应用架构模式：
* MVC
* OO-MVC，弱Model版本的 MVC，是 Online-Only Model-View-Controller的缩写，比如网页开发中，弱化了Model层，数据源来自服务端，然后呈现到View上
* MVVM，需要双向绑定
* The Elm Architecture
* Model-View-Controller+ViewState
* ModelAdapter-ViewBinder

后三者应该是借鉴其他编程语言开发中的模式，改写应用到iOS，这个应该比较有意思，待学习。





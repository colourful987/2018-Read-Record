> Theme: App Architecture & Low-programming（Compiler & Interpreter）    
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


# 2018/03/05 ~ 2018/03/08
这几天在改[iOS and macOS Performance Tuning](https://www.amazon.com/iOS-macOS-Performance-Tuning-Objective-C/dp/0321842847) 译书的修改意见，简单说下其中提到的pipeline流水线技术，主要参考了wiki的解释：
> 指令流水线是为了让计算机和其他数字电子设备能够加速指令的通过速度（单位时间内被运行的指令数量，吞吐量？）而设计的技术。

参考工业流水线做法，一个完整的产品需要经过工艺1（工人A负责），工艺2（工人B负责），以此类推...
这样的好处在于工人不需要“全能”，节省教学成本，他只需要懂自己步骤的工艺就可以重复劳动了。

其实CPU同样如此，内部有很多电子元器件组成，触发器，逻辑门等，其中每个电子器件各自独立，功能也是同流水线的工人一样很专一。

当代CPU都是利用时钟频率驱动的，而CPU是由内部的逻辑门与触发器组成。当受到时钟频率触发时，触发器得到新的数值，并且逻辑门需要一段时间来解析出新的数值，而当受到下一个时钟频率触发时触发器又得到新的数值，以此类推。而借由逻辑门分散成很多小区块，再让触发器链接这些小区块组，使逻辑门输出正确数值的时间延迟得以减少，这样一来就可以减少指令运行所需要的周期。（摘自wiki，若对计算机组成有兴趣，可以阅读 Code 一书）

以 RISC 流水线来说，被分为5个步骤，每个步骤之间用触发器链接，意思就是前一个步骤的输出作为下一个步骤的输出，而触发器的两端就是输入和输出，可以进行数据保持（在一段时间内）
1. 读取指令
2. 指令解码与读取寄存器
3. 运行
4. 内存访问
5. 写回寄存器

一条指令实际是由我们定义的一系列步骤，而不是一条指令对应一个物理层面的电路模块（有待确认）。

摘自wiki的一个示例：
![Pipeline,_4_stage.png](quiver-image-url/BCD07DE7C6E403B80F7056CC9F5B463D.png)
上图展示了4层流水线的示意图：
1. 读取指令（Fetch）
2. 指令解码（Decode）
3. 运行指令（Execute）
4. 写回运行结果（Write-back）

> 疑惑：每个步骤实际对应一个复杂的功能电路，那它们是如何保证每个步骤都是在一个时钟周期完成呢？还是说并非每个步骤时间相同————但是这样的话上图x轴又不对了。

图中不同颜色的方块分别对应一条指令，而中间的 pipeline 流水线纵向分为四个步骤（不要误解成指令）：Fetch、Decode、Execute和 Write-back。X轴方向是时间，注意到第一步Fetch横向去看，每次都是读入一条指令，第一个时钟读入了绿色指令，第二个时钟读入紫色，接着是蓝色和红色指令，它就像一个工人每个时钟读一条指令，下个时钟到来时候把读入的指令传给下一个步骤Decode，接着继续读指令；第二个步骤同样如此，只负责Decode一条指令，然后传给下一个步骤。

现在罗列下绿，紫，蓝，红四条指令执行开始到完成，开始和结束分别对应的时钟周期坐标（注意x轴方向）：
* 绿色指令：时钟周期1开始读入---> 时钟周期5结束，经历了Fetch,Decode，Excute,Write-back
* 紫色指令：时钟周期2开始读入---> 时钟周期6结束，同上
* 蓝色指令：时钟周期3开始读入---> 时钟周期7结束，同上
* 宏色指令：时钟周期4开始读入---> 时钟周期8结束，同上

如果是非流水线的话，应该是只有当一条指令执行完四个步骤的时候，才开始下一条指令执行四个步骤，也就是说执行两条指令要花费8个时钟周期，每条指令花费4个周期；而应用流水线技术，我们执行了4条指令，每条指令花费2个周期。但是随着指令源源不断地输入执行，最终相当于一个时钟周期执行一条指令。

> 我的理解：假设执行的指令无穷尽，那么随着时间推移，流水线中的每个步骤都处于忙碌状态，不可能有怠工的情况（理想情况下），从宏观去看这条流水线的工作情况，A在Fetch 指令4，B在Decode 指令 3，C在Excute指令2，D在Write-back指令1，其实我们认为A，B，C，D同时在对“同一个指令”操作，感觉就像一个时钟执行了一条指令。

当然非流水线的执行方式设计简单，成本低，而且指令和指令互不影响，出错概率低吧。

另外在修改译书时发现`阿姆达尔（Amdahl）定律`蛮有意思，关于内核数量和程序中并发代码比值对执行时间的影响。

# 2018/03/09（编译器和解释器专题）
Ruslan 写的[Let’s Build A Simple Interpreter](https://ruslanspivak.com/lsbasi-part1/) 专题总共有14节。
进度：read chapter 1，过于基础，暂时没有什么感悟和理解，只当打卡。

另外看评论Jack Crenshaw留言说文章貌似有“抄袭”嫌疑，没有细看，给出Jack Crenshaw 关于编译器和解释器的文章，有完整的pdf下载
[Let's Build a Compiler](https://compilers.iecc.com/crenshaw/)

# 2018/03/10
[Let’s Build A Simple Interpreter part2](https://ruslanspivak.com/lsbasi-part2/)    
* 借助 Scanner（扫描器）从 Source Code->Token的过程：Token 囊括了程序代码中所有的字符，比如整数，`+,-,*,/,= ...`，使用Token数据结构表示。在读入字符串parse后分别存储到一个个Token中，这一步称之为Lexical Analyzer(词法分析)；
* Lexeme 可以是一个或多个字符串（Note:比如"+","-"，也可以是整数“123”），毕竟我们输入的代码本质还是一长串字符串，由我们“分析”输入的“词”，然后将其Map到对应的Token结构中；
* 本节中，词法分析之后紧跟就是Interpreting(就是应用+和-)，但是目前逻辑代码是硬编码的，也就是if-else分支处理，目前仅仅只是做了空白字符串判断，一些特殊的还未判断。

# 2018/03/11
[Let’s Build A Simple Interpreter part3](https://ruslanspivak.com/lsbasi-part3/)   

本节学习稍微复杂的计算器表达式，例如 “1+2-100+123”这种表达式，顺便用oc写了个demo。

[OC-Lexical_Analyzer_UI](./resource/Lexical_Analyzer_UI)

[OC-Lexical_Analyzer_Terminal](./resource/Lexical_Analyzer_Terminal)

oc 终端接受字符串输入有两种方式：
```oc
// c语言方式
char *cstring = malloc(sizeof(char) * 100);
scanf("%s", cstring);
NSString *string = [NSString stringWithUTF8String:cstring];

// oc 层面
// 当然还可以继续调用 `[NSString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]` 将接收的字符串去除空格和换行等
NSData *data = [[NSFileHandle fileHandleWithStandardInput] availableData];
NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
```

此次在学习过程中遇到了个小坑，对于带空格的输入,`scanf`接收总是出问题，最后查了[c++官方文档说明](http://www.cplusplus.com/reference/cstdio/scanf/)：

> Any number of non-whitespace characters, stopping at the first whitespace character found. A terminating null character is automatically added at the end of the stored sequence.

即对于输入format为`%s`时，接收字符串直到遇到第一个为空格的字符算作结束，然后接收到的字符串后面拼接`null(\0)`。

解决方法可以使用`gets()`函数，另外如何读取带空格的字符串，有一种比较有意思的格式：
```
scanf(” %[^\n]s”,a);
```
出自[How to use scanf to read Strings with Spaces](https://gpraveenkumar.wordpress.com/2009/06/10/how-to-use-scanf-to-read-string-with-space/)

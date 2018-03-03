> Theme: 暂定    
> Source Code Read Plan: Aspect      
> Reference Book List: 暂定

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


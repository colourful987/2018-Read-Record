> Theme: 暂定
> Source Code Read Plan:
>
> - [ ] GCD 底层libdispatch
> - [ ] TableView Reload 原理，博文总结
>
> - [x] `objc_msgSend` 汇编实现收尾
> - [x] Custom UIViewController Transitions (实现App Store和知乎的转场效果)



# 2018/10/01 - 2018/10/03
Transition Animation 学习模仿App Store Today 中的点击转场动画，使用iPhone录屏来看实现，感觉是使用了约束实现的。

目前做的效果还不理想，之后修改觉得ok了放出来，现在连demo都称不上，一直在纠结的点是一开始就把toView的视图放上去，让toView内容做动画呢，还是fromView snapshot后搞个虚假视图做动画。

# 2018/10/04
实现了App Store的简单效果，但是存在如下问题：
1. App Store 的present和dismiss都是有弹簧效果，本demo只是简单移动到指定位置；
2. present后多了transition View转场过渡视图
3. dismiss 效果一般
4. 未实现手势dismiss

简单总结：
实现过程花了小半天，还是遇到了一些坑，苹果的动画实现从细节上来说真的很赞，比如缺少了弹簧效果就没了“灵动”；转场动画现在从基础掌握上可以打3/5，具体的动画还得交互给实现细节，否则光靠自己的话需要录屏然后一帧一帧看。



# 2018/10/07
[nshipster 新出的 mac OS Dynamic Desktop](https://nshipster.com/macos-dynamic-desktop/)，作者 Mattt 10月1号刚出的文章。



互联网侦查微信公众号的文章明日看一遍，主要是对算法应用突然有点小兴趣。[link](https://mp.weixin.qq.com/s?__biz=MzIzMTE1ODkyNQ==&mid=2649410317&idx=1&sn=6a142afbee6e8ead78dbe145e4f56b8a&chksm=f0b60eefc7c187f9f1aa7008b5fc24a48700af5fec2a37a2ba98b14838b4ce58f260fc937053&scene=38#wechat_redirect)



# 2018/10/08
两年前记录的宏定义的三个使用方式：

```c
/**
  引自 Pointers on C 一书
  1. 在调用宏时，首先对参数进行检查，查看是否包含任何由 `#define` 定义的符号，如果是，这些符号首先被替换掉
  2. 替换文本随后被插入到程序中原来文本的位置，对于宏，参数名被它们的值所替换。
  3. 最后，再次对结果文本进行扫描，看看它是否包含了任何由#define 定义的符号，如果是，就重复上述处理步骤。
  宏参数和#define 定义可以包含其他#define 定义的符号，但是，宏不可以出现递归！
  当预处理器搜索#define定义的符号时，字符串常量的内容不被检查，如果想把宏参数插入到字符串常量中，有以下几种方式：
*/


// 技巧1：这种技巧只有当字符串常量作为宏参数给出时才能使用 这里多个字符串放在一起时会自动编程一个！
#define PRINT(FORMAT,VALUE)     \
        printf("The value is " FORMAT "\n",VALUE) 
// 这里 FORMAT 实际是一个字符串常量 例如 %d
PRINT("%d",x + 3);


// 技巧2：利用预处理器把一个宏参数转换成一个字符串，#argument 这种结构被预处理器解释为“argument”。你可以这么用：
#define PRINT(FORMAT,VALUE)     \
  printf("The value of" #VALUE  \
  " is " FORMAT "\n" ,VALUE)  \
// 这里 VALUE 不是字符串常量 而是“x+3”表达式 所以利用#符号解释为字符串


// 技巧3： ##非常有意思，负责把位于它两边的符号连接成一个符号。
#define ADD_TO_SUM( sum_number, value ) \
    sum ## sum_number += value
ADD_TO_SUM(5,25) // 这里不是 5+25 ! 而是把25加到 sum_5 这个变量中。
```
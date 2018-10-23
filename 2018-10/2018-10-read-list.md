> Theme: 暂定
> Source Code Read Plan:
> - [ ] GCD 底层libdispatch
> - [ ] 解释器拾遗
> - [x] `objc_msgSend` 汇编实现收尾
> - [x] Custom UIViewController Transitions (实现App Store和知乎的转场效果)
> - [x] 四大排序算法(选择，冒泡，归并，快速)学习理解


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
  递归宏比如 `#define x  x`
  
  当预处理器搜索#define定义的符号时，字符串常量的内容(比如“Hello World”字符串)不被检查，如果想把宏参数插入到字符串常量中，有以下几种方式：
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

宏定义的应用场景，如下用于交换某个数据的高位和低位bit:
```c
#define	BSWAP_8(x)	((x) & 0xff)
#define	BSWAP_16(x)	((BSWAP_8(x) << 8) | BSWAP_8((x) >> 8))
#define	BSWAP_32(x)	((BSWAP_16(x) << 16) | BSWAP_16((x) >> 16))
#define	BSWAP_64(x)	((BSWAP_32(x) << 32) | BSWAP_32((x) >> 32))
```

另外交换两个数的值，我们之前使用定义一个方法，传入两个数的指针，然后搞个中间变量，但是如果用宏定义配合异或操作：

```c
#define swap(a, b) \
(((a) ^= (b)), ((b) ^= (a)), ((a) ^= (b)))
```

采用下面的方法，对于给定两个整数a,b，下面的异或运算可以实现a,b的交换，而无需借助第3个临时变量：

```
a = a ^ b;
b = a ^ b;
a = a ^ b;
```

这个交换两个变量而无需借助第3个临时变量过程，其实现主要是基于异或运算的如下性质：

1.任意一个变量X与其自身进行异或运算，结果为0，即X^X=0

2.任意一个变量X与0进行异或运算，结果不变，即X^0=X

3.异或运算具有可结合性，即a^b^c=（a^b）^c=a^（b^c）

4.异或运算具有可交换性，即a^b=b^a

可以使用上面的结核性+交换性不难推出 `b = a ^ b = (a ^ b) ^ b = a ^  (b ^ b) = a ^ 0 = a;`，然后 `a = (a ^ b) ^ a = b`

# 2018/10/09
[【面试现场】如何判断一个数是否在40亿个整数中？](https://mp.weixin.qq.com/s/M-9OXISosrqRI08QIDJiPA)

文章思路参考了bitMap做法，：内存申请 2^32 个bit位建立一张表，每个位代表一个数，1表示数存在，0表示数不存在；如此一来，本来内存中存储一个int整数就要占32位————4个字节，比如整数0要占32位，0xFFFFFFFF 亦是如此，那么40亿个整数就要160亿字节，大约16,000,000,000/1000/1000/1000 = 16G。而现在一个位就代表一个数，相当于节省了32倍（之前32位代表一个数），但是此处我们必须先整理存储40亿个数，一一映射到内存中各个位。此时占512MB。 查找操作简单且耗时，试想我们查找7788这个数，我们只需要知道内存中存储这些位的起始地址，加上偏移量7788就能查找这个位的值，0 or 1。耗时操作主要是在将40亿个数归档到500MB内存中。

进一步：40亿个数必定存在连续的数，那么对于 1、2、3、4、7、8、20、21、22、23...... 我们可以把 1、2、3、4 整理成(1，4) ，表示从1开始有总计连续4个数，而7、8整理成(7，2)

错误思路：我初看此题立马想到的是二叉树....以为这样能节省空间以及便于查询，int32足以表示40亿个数了，那么我把整数分为4个字节，分别作为二叉树的节点值（key），但是草稿纸上一画发现就不对，之后想到的方式bitMap，至于上面进一步的没有考虑到，这就是差距呀。

[【面试现场】如何实现可以获取最小值的栈？](https://mp.weixin.qq.com/s/SFbGNAEGnqZMib9VMC26Ew)

首先题目并非指遍历栈中数据查找最大最小值，而是栈在push一个数的时候进行最大最小值统计赋值；但是pop操作的时候有个问题，如果pop的是最小数，那么现在哪个是最小数呢？难道要重新遍历一遍栈的数据吗？同理pop一个最大数，那么现在哪个是最大数？

如果使用辅助栈分别存储最大最小值的方式，复杂度为O(1)，空间为O(n)，毕竟每push一个数，此时的栈会生成一个最大最小值，需要同时push到对应的辅助栈中————即使最大最小值没变！如下：

```
mins: 5 5 5 5
data: 5 6 7 8
```
作者提供了使用辅助栈求最小值的代码：

```
public class MinStack {

    private List<Integer> data = new ArrayList<Integer>();
    private List<Integer> mins = new ArrayList<Integer>();

    public void push(int num) {
        data.add(num);
        if(mins.size() == 0) {
            // 初始化mins
            mins.add(num);
        } else {
            // 辅助栈mins每次push当时最小值
            int min = getMin();
            if (num >= min) {
                mins.add(min);
            } else {
                mins.add(num);
            }
        }
    }

    public int pop() {
        // 栈空，异常，返回-1
        if(data.size() == 0) {
            return -1;
        }
        // pop时两栈同步pop
        mins.remove(mins.size() - 1);
        return data.remove(data.size() - 1);
    }

    public int getMin() {
        // 栈空，异常，返回-1
        if(mins.size() == 0) {
            return -1;
        }
        // 返回mins栈顶元素
        return mins.get(mins.size() - 1);
    }

}
```

进一步解决辅助栈会随着主栈的增长而增长的问题，我们可以添加逻辑处理如果push进来的值比已有的min大，那么就不对辅助栈进行push操作，反之如果push进来的新值比已有的最小值还小，那么就要更新辅助栈，push这个新值到辅助栈中；Pop的时候比较下最小值是不是当前辅助栈栈顶值就可以，如果一致就两个栈同时pop，否则按兵不动。

但是！这里存在一个问题，如果一次性push 2个最小值，那么辅助栈只会有一个最小值，但是pop的时候就出差错了————pop第一个最小值时就把辅助栈的最小值搞掉了，实际栈的最小值还是保持不变的。

解决方案是辅助栈不要存最小值了，而是存最小值的在真实栈中的索引index即可，然后pop的时候比较索引值就不会出错了。

[【面试现场】为什么要分稳定排序和非稳定排序？](https://mp.weixin.qq.com/s/GiNFE1dwmVtA99qxccK3aQ)

知识点：首先排序有冒泡排序，快速排序，归并排序，选择排序，定义待温顾（见下）；而稳定排序和非稳定排序还真是第一次听说，但是不难理解，就是稳定排序下，两个相同的值在排序后顺序和之前未排序前的顺序保持一致！

使用场景：feed流中新闻排序，两个排序关键字的时候，稳定排序可以让第一个关键字排序的结果服务于第二个关键字排序中数值相等的那些数。


# 2018/10/10 - 2018/10/14 四大排序算法

1. 冒泡排序：核心是每循环一次都会把一个最大数”冒泡“到最上面，因为有n个数，所以这样的操作需要进行n次，而一次冒泡操作参与整数的个数在递减，因为每次送上去的数总是现有中最大的，下一次就不需要参与到冒泡中了。

```
for(int i = 0 ;i < count -1 ;i++) {
  // 一次冒泡操作 送一个数到最上面
  for(int j = 0; j < count -1-j;j++){
    int a = arr[j];
    int b = arr[j+1];
    
    if(a > b) {
      a ^= b;
      b ^= a;
      a ^= b ;
      arr[j] = b;
      arr[j+1] = a;
    }
  }
}
```
2. 快速排序：基本思想是通过一趟排序将要排序的数据分割成独立的两部分，其中一部分的所有数据都比另外一部分的所有数据都要小，然后再按此方法对这两部分数据分别进行快速排序，整个排序过程可以递归进行，以此达到整个数据变成有序序列。至于这个基准数，基本90%的文章都只说以第一个数为基准，但是都没提及如果用其他数做基准怎么样————比如取个mid值。

```C
void sort(int *a, int left, int right)
{
    if(left >= right)/*如果左边索引大于或者等于右边的索引就代表已经整理完成一个组了*/
    {
        return ;
    }
    int i = left;
    int j = right;
    int key = a[left];
     
    while(i < j)                               /*控制在当组内寻找一遍*/
    {
        while(i < j && key <= a[j])
        /*而寻找结束的条件就是，1，找到一个小于或者大于key的数（大于或小于取决于你想升
        序还是降序）2，没有符合条件1的，并且i与j的大小没有反转*/ 
        {
            j--;/*向前寻找*/
        }
         
        a[i] = a[j];
        /*找到一个这样的数后就把它赋给前面的被拿走的i的值（如果第一次循环且key是
        a[left]，那么就是给key）*/
         
        while(i < j && key >= a[i])
        /*这是i在当组内向前寻找，同上，不过注意与key的大小关系停止循环和上面相反，
        因为排序思想是把数往两边扔，所以左右两边的数大小与key的关系相反*/
        {
            i++;
        }
         
        a[j] = a[i];
    }
     
    a[i] = key;/*当在当组内找完一遍以后就把中间数key回归*/
    sort(a, left, i - 1);/*最后用同样的方式对分出来的左边的小组进行同上的做法*/
    sort(a, i + 1, right);/*用同样的方式对分出来的右边的小组进行同上的做法*/
                       /*当然最后可能会出现很多分左右，直到每一组的i = j 为止*/
}
```

i和j就像两根栅栏一样，一开始在数组的两侧“待命”，现在从数组中随便设定一个基准值Key。

> 一次快速排序的目的只有一个，以key值为分界线，把小于key的值都移动到它的左边，把大于key的值移动到它的右边。

某些人肯定会这么思考：按照上述目的，我们可以从第0个数开始遍历，如果比key小，那么我们让其保持不动，移动到下一个数继续比较，一旦找到一个比key大的值，我们把这个数移动到数组的尾部，这里有个问题，“移动到数组的尾部？”，那么这个数原先在数组的位置就会为空，而数组的容量一开始就确定了，难道我们要重新申请内存？ 

上述两个问题其实我们很容易想到解决方案：
1. **将找到的比key大的数和数组最后一个数交换位置**，这是成功的一步
2. 回过头来看i，它就像一个栅栏，遍历时发现当前数组位置的值比key小，栅栏直接移动到下一个位置，而栅栏i保证了左边的值都是比key小，且栅栏只能像右边移动，不能回退！
3. 好了，继续移动左侧的i，查找下一个比i大的值，一旦找到，我们就将其放到倒数第二个位置————倒数第一个位置之前已经被替换了，此处又要搞一个新的栅栏，既充当指针的作用，又能保证栅栏右侧的数都是比key大，这个栅栏姑且就是j吧；一旦替换一个数，j就要**往前移一格(j--)**；
4. 以此类推，我们一次次把左侧的比key大的值移动到数组的右边，慢慢的i不断++，而j--，总有一天i和j会碰在一起，那一刻就表明我们一轮操作结束了！

> 现在问题来了，上述存在一个严重的问题！左侧遍历查找比key大的数，通过替换操作移动到数组尾部这一步毫无疑问没有问题，问题就出在替换的数移动到前面存在不确定性，万一这个替换过来的数比key大呢？？？讲道理这个数应该还要放到数组右边的，所以我们替换操作后不要急着将栅栏i往右边移动(i++)，这里需要判断替换过来的数是否比key大，如果是则和j指向位置所在的数替换且j--，然后重复判断，直到替换过来得数小于key，我们才将栅栏往右移动(i++).

当然上面是一种思路，快排中则是另外一种方式，我不知道上述方式是否存在问题，比如复杂度？

与上述单向操作不同，快排采用“两头操作”方式，i和j依旧作为栅栏指向数组的头(idx=0)和尾(idx=n-1)，首先我们从数组尾部开始进行查找小数操作，找到后和i指向位置的数做替换(a[i]=a[j])，如果没找到，j就一直递减(j--)，而i始终原地待命，甚至替换操作后也不进行i++操作，note:i和j此时指向各自替换的位置，为什么不进行j++，因为从头部替换过来的数我们可不确定比key大还是小，所以先保留着；

这里需要脑补下i和j两个栅栏将数组分成了3个部分，左边、中间和右边，i左边和j右边部分我们认为是处理完的数据（左侧的数都是比key小，右侧的书都是比key大），而中间还没有进行遍历比较操作；

回归正题，前面说两头操作，而我们此处先从尾部开始扫起，那么紧接着就是从头部开始玩了，我们会将i指向的数值(由于没有进行i++操作，此时i指向的数就是从尾部替换回来的值)和key比较，只有保证大于才会将其和j指向位置的数替换，小于则i++向右平移。

有人会说，我前一秒刚才尾部找了一个小数替换到i指向的位置，一下秒你居然将这个数和key比较，貌似没啥意义，因为这个数肯定是比key要小啊，而我们要的是将比key大的数往后移，代码：
```
// 如果我们按照之前说的，替换后进行i++操作，代码就是如下
a[i] = a[j]; // 这里一定能保证key>a[i]
i++
while(i < j && key >= a[i])
{
    i++;
}
```
这段代码在 `key>a[i]` 其实就可以简化成：

```
a[i] = a[j]; // 这里一定能保证key>a[i]
while(i < j && key >= a[i])
{
    i++;
}
```
左边经过严谨的操作，会送一个肯定比key大的数替换掉j指向的不确定大小的数；而右边又开始查找一个一定比key小的数再一次替换掉i指向的那个不确定大小的数，反反复复，最后相会于中间，保证了 key 在中间，左边的数都比它小，右边的数都比它大，但并不意味着左右两边的数按照从小到大排序好了。


我们要做的是把左边看做一个新数组，右边也是一个新数组，应用上面的这套逻辑，也就是递归操作：

```
sort(a, left, i - 1);
sort(a, i + 1, right);
```

上述是我的总结，有点杂乱，如果让我画画的可能会表达清楚，纯文字真的。。。

3. 归并排序：这篇文章短而形象，可以参考值它：[图解排序算法(四)之归并排序](https://www.cnblogs.com/chengxiao/p/6194356.html)，不由感慨，对于这种相对简单的算法，用图解是最恰当的！
4. 选择排序：简单选择排序是最简单直观的一种算法，基本思想为每一趟从待排序的数据元素中选择最小（或最大）的一个元素作为首元素，直到所有元素排完为止，简单选择排序是不稳定排序。



# 2018/10/14（解释器拾遗）
> Goal: 实现一个股票公式解释器

[Let’s Build A Simple Interpreter. Part 1-5 温顾，计算器篇](https://ruslanspivak.com/lsbasi-part4/)

知识点在于 factor term expr 的引入，以及 context-free grammer 和 BNF(Backus-Naur Form) 概念，写解释器之前我们通常要绘制grammer语法表，比如：

![](https://ruslanspivak.com/lsbasi-part4/lsbasi_part4_bnf2.png)

明确terminal以及no-terminal符号，像 Integer ,Plus（+）就是个 terminal，因为不能再展开了，解释到此结束了。

![](https://ruslanspivak.com/lsbasi-part4/lsbasi_part4_bnf4.png)

上文中是最“粗糙”的 Interpreter 解释器，输入是一串字符串(e.g. "12+33/3-11")，然后解释器会对这串字符串进行“解释”出factor，term，expr等token（这个其实就是词法分析器 lexer），特别强调的一点是，上面的解释器并非先提取出所有的 token ，再应用规则进行加减乘除；而是我认为是递归方式查找 expr,term等no-terminal符号，因为这些都是非终结的，所以一直可以展开表达式，直至遇到一个terminal符号，例如 integer 或者操作运算符(+ - * /) 等运算符，就好比二叉树 at the bottom。

当且仅有表达式为 left operate right，三者都是terminal符号时才能应用，比如 5 + 4，如果left是一个no-terminal，比如(5+3)这种，那么我们会先计算这个expr，得到一个 terminal ，也就是一个结果值，才会继续应用这个规则。

> Our goal is get the terminal symbol！



# 2018/10/15(解释器—— Lexer AST Grammer 知识温顾)

![](https://ruslanspivak.com/lsbasi-part5/lsbasi_part5_syntaxdiagram.png)

由于当前解释器只是个粗糙实现，其中解释器并没有先生成AST，再进行Interpret，因此如上图所示，每找到一个term对象，就要专注于对其的解释，这就是所谓的no-terminal非终结符号，紧接着解释一个 term 表达式，也就是`factor ((MUL|DIV)factor)*`，然而接触到第一个factor，我们发现它也是一个no-terminal符号，因此还需要进一步深入，直至将其解释成一个terminal符号，也就是整数；接着是 `* /` ，直接略过，寻找下一个factor并将其一步步解释成terminal符号，然后应用 `* /` 运算符号；这是一个term已经解释完毕，那么 `+ -` 符号优先级低，所以放在最上层，解释下一个term，依葫芦画瓢，算出这个表达式 term的值。

> Note: 我的理解是，按照这里的grammer，我们总是遇到一个no-terminal符号必须解释成terminal符号才肯罢休！

引入 `()` 括号表达式的话，我们发现由于括号的优先级高，所以应该归纳到 factor 中，用一个 `|` 或符号。

![](https://ruslanspivak.com/lsbasi-part6/lsbasi_part6_factor_diagram.png)

例如像 `2 * (7 + 3)` 表达式，Grammer图显示如下：

![](https://ruslanspivak.com/lsbasi-part6/lsbasi_part6_decomposition.png)

目前代码感觉就是interpret和parser代码一团写死在了一起，而且interpret一旦recognized识别出某种结构的表达式或符号，就会立马解析出结构——————这也是我一直强调的，这种术语叫做 **syntax-directed interpreters**。

接下来的目的是lexer生成中间语言(intermediate representation，缩写IR)，然后解释器拿到这个IR进行解释，而 AST 和 Parse Tree 的区别有如下几点：

1. AST使用 operators/operations 作为root节点和中间节点，而操作数作为节点的children（能叫leaf 叶不？）；
2. AST 实际上不能体现一些 grammar 语法规则，见下左图；
3. AST 之所以叫做抽象语法树，因为它无法呈现一些详细的语法规则，比如没有rule node，没有 parentheses 括号等等；
4. 相对于 parse tree，AST密集程度更高？但是我认为刚好相反。。。。

> 抽象语法树用于某门编程语言的呈现抽象语法结构。

![](https://ruslanspivak.com/lsbasi-part7/lsbasi_part7_ast_02.png)

to be continue...



# 2018/10/16(解释器 —— AST)

[Let’s Build A Simple Interpreter. Part 8 - 10](https://ruslanspivak.com/lsbasi-part11/) 这几节引入了 AST 对Pascal基础语法的定义，如果想实现一门属于自己的语言，第一步不可能马上生成AST抽象语法树，我们得规定有哪些Token，保留关键字，Grammar等等，比如Var关键字，"x,y" 等变量Id，由这个Token我们衍生出赋值语句（var declare statement），其中有保留关键字，比如类型 Integer(整数)；至于其他的当然有赋值语句 `x = y+3*a/2`，这些赋值语句组成了代码片段，进一步就是程序了。

> 上述难度较大，需要一定计算机基础。另外通过目前的学习，基本上对Token，Lexer，Parser，AST有了初步理解，其实对于Parser持有一个Lexer用于生成AST，然后遍历这个抽象语法树，配合Symbol Table来解释这个抽象语法树，得到我们想要的结果，比如每个变量最后的结果值。不过呢，到目前为止，我们的解释器 Interpreter 就是为了得到一个或多个结果值！但是有意思的想法不仅限于此，我们可以将其解释并生成另外一门语言————即中间语言Intermediate Representation，缩写 IR。

to be continue...

# 2018/10/17 (解释器 —— Symbol Table)

[Let’s Build A Simple Interpreter. Part 11](https://ruslanspivak.com/lsbasi-part11/)

引入了 Symbol Table 概念，与 Runtime Global_Memory不同，前者是在static analysis阶段生成的符号表，而后者是运行时存储中间变量的，比如我们的堆和栈。

明日开始编码...



# 2018/10/22(解释器 —— Semantic analysis 静态分析)

没持续更新原因：1.手头任务较多，瞎忙 ；2，有点迷茫，没调整好

引入了Semantic analysis概念，其实相当于是一个简化版的Interpreter(或者称之为 Node vistor)，两者之间共同点是对 Syntax analysis 生成的 AST 抽象语法树进行分析，前者是语义分析，比如在赋值语句中可以检查某个变量是否被预先声明过，或者objective-c中，dealloc方法中有没有对NSNotification进行移除观察者self，亦或是block中引用了self，注意这些都是关于语义的，即程序语言是否合法；而解释器更进了一步，是真正在执行（解释）语句了，当然它比语义分析器更全面，毕竟在解释过程中如果出现非预期情况，解释器也是会报错的。

下图足够解释我们的SIP简单的一个流程，进一步理解解释器各个流程部分的职责：

![](https://ruslanspivak.com/lsbasi-part13/lsbasi_part13_img03.png)



# 2018/10/23(解释器 —— source To source )

今天突然想到了 AST 下一步的用途，从一个初学者来看，有如下几个方面：
1. 第一时间且常规思路无非就是直接解释器 evaluate 出结果值;
2. AST 可以作为静态语法分析的source源，即昨日学习的 semantic analysis，llvm 似乎是可以自己写代码实现检测昨日说的几个检查项（最简单的就是检查定义的命令名称是否符合我们的规则），也就是我们经常在 CI 中想要集成的功能；
3. AST 既然描述一门语言的抽象语法树，那么我们也可以把这个抽象语法树当做“中间语言（IR Intermediate representation）”，然后把这门中间语言解释成生成另外语言的对应的语句即可（这里不由让我想起了 llvm ），好处是什么？？很直观的举个例子就是实现跨平台，思路很简单，写代码用我们“创造”的新语言，不管任何平台都可以用我们的解释器生成一个 IR，然后我们拿到IR后为每一个平台适配对应的Target Code————比如汇编，然后汇编进一步生成可执行文件；
4. 如果第三点不好理解的话，我还有一个现实例子也是之后想要实现的，同样是自定义一门UI控件标准语言，然后解析生成AST --> 解释成中间语言 IR --> 最后这里我们可以利用IR生成 html语言的button样式代码，或者objective-c的button代码，或者是android端的button代码，不管怎么样，这里需要三端都要实现对 IR 解释成各自平台的步骤。
5. 还有一个场景就是股票中的指标平台，用户可能编写公式，需要客户端解释然后在曲线上绘制出图形。

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



# 2018/10/10

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
      a ^= a ;
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
3. 归并排序：
4. 选择排序：
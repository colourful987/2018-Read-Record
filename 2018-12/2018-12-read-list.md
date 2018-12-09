> Theme: RunLoop主题、年度整理
> Source Code Read Plan:
- [x] MachPort的设计思路以及写Example；
- [x] Main RunLoop 默认添加了哪些 Mode，各适用于哪些场景；
- [x] GCD Dispatch 的MachPort是怎么玩的；
- [x] RunLoop 的休眠，休眠时候真的什么都不做吗？那视图渲染呢？
- [x] 屏幕的 UI 渲染更新机制，是放在RunLoop哪个阶段做的；
- [x] 昨日的 CFRunLoopDoBlocks 执行的是？
- [ ] RunLoop 的使用场景有哪些，具体实现又是怎么样的？
- [x] GCD 为什么会有个 gcdDispatchPort?
- [ ] Observer 休眠前、休眠后等事件可以玩一些什么花样呢？
> reference：

* [Interprocess communication on iOS with Berkeley sockets](http://ddeville.me/2015/02/interprocess-communication-on-ios-with-berkeley-sockets) 
* [mach_port_t for inter-process communication](http://fdiv.net/2011/01/14/machportt-inter-process-communication) 
* [Mach Messaging and Mach Interprocess Communication](https://docs.huihoo.com/darwin/kernel-programming-guide/boundaries/chapter_14_section_4.html) 
* [Abusing Mach on Mac OS X - Uninformed pdf](https://www.google.co.jp/url?sa=t&rct=j&q=&esrc=s&source=web&cd=8&cad=rja&uact=8&ved=2ahUKEwjD-qGbr_zeAhWBi7wKHYRYDk8QFjAHegQIAxAC&url=http%3A%2F%2Fwww.uninformed.org%2F%3Fv%3D4%26a%3D3%26t%3Dpdf&usg=AOvVaw3sraSLdwRTvPca4iHV5NDL)
* [ipc-hello.c Example](http://walfield.org/pub/people/neal/papers/hurd-misc/ipc-hello.c)
* [iOS 模块详解Runloop](https://juejin.im/entry/599c13bc6fb9a0248926a77d)
* [Stackoverflow Question: NSRunLoop : Is it really idle between kCFRunLoopBeforeWaiting & kCFRunLoopAfterWaiting?](https://stackoverflow.com/questions/35872203/nsrunloop-is-it-really-idle-between-kcfrunloopbeforewaiting-kcfrunloopafterw)
* Yuri Romanchenko 的回答有点厉害：[Does UIApplication sendEvent: execute in a NSRunLoop?](https://stackoverflow.com/questions/22116698/does-uiapplication-sendevent-execute-in-a-nsrunloop/22121981#22121981)


# 2018/12/01
开箱

# 2018/12/02

- [x] MachPort的设计思路以及写Example

更正下上一个提交，首先mach port的资料真的很匮乏，即使到如今还是搜不到健全的资料，甚至连个完整能运行的Demo都没有（可能是我搜到的博文认为这都是基础，因此只贴了一些数据结构的解释），下面的代码运行ok的，我用pthread创建线程用于监听消息，在主线程里发送给指定的port一个`0x12345678`的数据。注意点罗列下：

1. `struct message` header的设置相当重要，比如size大小；其次body并非是数据源，而是一个描述数据源(类型`mach_msg_type_descriptor_t`)的个数，而type中的pad1才是真正要传的data，pad2为data占的字节数；
2. header中的`msgh_remote_port` 和 `msgh_local_port`分别是什么，如何赋值的说明，这得根据发送和接收两种场景而定。首先一个connection连接必定有两端，所以要分配两个port，这里是port和receive，receive属于main thread中Task，而port属于fork出来子线程Task的；可以看到我们想要在main thread中send一个消息给子线程，那么`msgh_remote_port` 目的端就是 port，`msgh_local_port` 源端口就是 receive，当然在send时候我认为不设也没关系的；再来看子线程接收的header，它只负责监听接收，那么只需要设置`msgh_local_port` 就可以，也就是 port，如果说服务端接收消息后还要发送，那么就要设置header中的`msgh_remote_port` 为目的端口 receive。感觉说的还是有点绕，用图可能会清晰点。总结来说，如果是send行为，那么header必定是要设置`msgh_remote_port`，如果是接收，那么设置`msgh_local_port`就行了，至于port就是一开始分配好的；
3. 关于port的 allocate，其实还没搞懂，官方文档总是说属于一个Task，关联很多thread，比较绕；
4. 刚才demo没跑起来，其实就是因为header中的size没有设置对，其实想想也对，因为接收端需要明确需要receive多少个字节后才能解析成对的数据结构；
5. pthread的使用，这个网上资料很多

<details close>
  <summary>点击展开 Hello World Demo 片段</summary>

```c
#include "string.h"
#include "assert.h"
#include <pthread.h>
#import <stdio.h>
#import <stdlib.h>
#import <mach/mach.h>
#import <atm/atm_types.h>
#import <sys/mman.h>

struct message {
    mach_msg_header_t header;
    mach_msg_body_t body;
    mach_msg_type_descriptor_t type;
//    mach_msg_trailer_t trailer;
};

/// 创建一个虚假的server
static void *server(void *arg)    {
    mach_port_t port = *(mach_port_t *)arg;
    
    struct message message;
    message.header.msgh_local_port = port; // 服务端监听的port
    message.header.msgh_size = 48;
    
    while (1) {
        /* Receive a message */
        mach_msg_return_t err = mach_msg_receive(&message.header);
        
        if (err) {
            NSLog(@"mach_msg error");
        } else {
            unsigned int mag_data = message.type.pad1;
            NSLog(@"receive: 0x%x",mag_data);
        }
        
    }
    
}

pthread_t ntid;

void create_pthread_act_as_server(mach_port_t *port){
    int err;
    err = pthread_create(&ntid, NULL, server, port);
    if (err != 0) {
        NSLog(@"error happended");
        return;
    }
    
}

int main(int argc, const char * argv[]) {
    mach_port_t port;
    mach_port_t receive;
    int err;
    
    err = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &port);
    if (err) {
        NSLog(@"error allocate port");
        exit(0);
    }
    
    err = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &receive);
    if (err) {
        NSLog(@"error allocate port");
        exit(0);
    }
    
    // create a new thread to wait fo message
    create_pthread_act_as_server(&port);
    sleep(2);
    
    unsigned int msg_data = 0x12345678;
    while (1) {
        struct message msg;
        char *data = (char *)malloc(256);
        printf("Enter your name:");
        fgets(data, 256, stdin);
        if (feof(stdin)) {
            break;
        }
        msg.header.msgh_remote_port = port; // request port
        msg.header.msgh_local_port = receive; // reply port
        msg.header.msgh_bits = MACH_MSGH_BITS (MACH_MSG_TYPE_MAKE_SEND,
                                              MACH_MSG_TYPE_MAKE_SEND_ONCE);
        msg.header.msgh_size = sizeof(msg);
        
        msg.body.msgh_descriptor_count = 1;
        msg.type.pad1 = msg_data;
        msg.type.pad2 = sizeof(msg_data);
        
        mach_msg_return_t err = mach_msg_send(&msg.header);
        if (err != MACH_MSG_SUCCESS) {
            NSLog(@"could not send uint:0x%x\n",err);
        }
    }
    
    return 0;
}
```
</details>

> `mach_port_t` 的本质就是 `typedef unsigned int` ！！！

# 2018/12/03

- [ ] RunLoop 中有哪些 GCD Dispatch port，它们分别起到了哪些作用？

源码参考分别是[swift-corelibs-libdispatch](https://github.com/apple/swift-corelibs-libdispatch)和[swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation)。前者是GCD的源码，后者CoreFoundation源码，包含了RunLoop、CFMessagePort和CFSocket源码。

## `__CFPort dispatchPort` 分析(main queue)

<details open>
  <summary>__CFRunLoopRun刚进来有一段`#if __HAS_DISPATCH__`的代码</summary>

```c
#if __HAS_DISPATCH__
    __CFPort dispatchPort = CFPORT_NULL;
    Boolean libdispatchQSafe = pthread_main_np() && ((HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && NULL == previousMode) || (!HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && 0 == _CFGetTSD(__CFTSDKeyIsInGCDMainQ)));
    if (libdispatchQSafe && (CFRunLoopGetMain() == rl) && CFSetContainsValue(rl->_commonModes, rlm->_name)) dispatchPort = _dispatch_get_main_queue_port_4CF();
#endif
```

</details>

判断条件我目前不是很关心，对dispatchPort如何被初始化出来的方法感兴趣，首先它是个宏定义，在RunLoop源码中是没有的，而是在 dispatch 源码中：

<details>
  <summary>`_dispatch_get_main_queue_port_4CF 实现`</summary>

```c
dispatch_runloop_handle_t
_dispatch_get_main_queue_handle_4CF(void)
{
	dispatch_queue_t dq = &_dispatch_main_q;
	dispatch_once_f(&_dispatch_main_q_handle_pred, dq,
			_dispatch_runloop_queue_handle_init);
	return _dispatch_runloop_queue_get_handle(dq);
}
```

</details>

`_dispatch_main_q` 类型为 `dispatch_queue_s` 的结构体，它的标签值为 `com.apple.main-thread`，而`dispatch_once_f` 字面理解就是只执行一次，所以这些都不是重点，重点是**port**是如何被allocate出来，发现 `_dispatch_runloop_queue_handle_init` 才是核心方法：

<details>
  <summary>`_dispatch_runloop_queue_handle_init`源码实现如下：</summary>

```c
static void
_dispatch_runloop_queue_handle_init(void *ctxt)
{
	dispatch_queue_t dq = (dispatch_queue_t)ctxt;
	
	/// 1. 这里typedef了一下，类型就是mach_port_t，本质就是unsigned int
	dispatch_runloop_handle_t handle;

	_dispatch_fork_becomes_unsafe();

#if TARGET_OS_MAC
	mach_port_t mp;
	
	/// 2. 同样也是typedef别名，本质是int类型
	kern_return_t kr;
	
	/// 3. 这里和上面学习的port基础Hello demo 一模一样 不赘述
	kr = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &mp);
	
	/// 4. 因为allocation也可能失败，所以要校验错误码
	DISPATCH_VERIFY_MIG(kr);
	(void)dispatch_assume_zero(kr);
	
	/// 5. 这个方法mach.h看到过，估计就是插入权限吧 暂时忽略
	kr = mach_port_insert_right(mach_task_self(), mp, mp,
			MACH_MSG_TYPE_MAKE_SEND);
	DISPATCH_VERIFY_MIG(kr);
	(void)dispatch_assume_zero(kr);
	
	/// 6. dispatch_queue_s 主队列区分处理，看样子是额外加了一个限制属性
	if (dq != &_dispatch_main_q) {
		struct mach_port_limits limits = {
			.mpl_qlimit = 1,
		};
		kr = mach_port_set_attributes(mach_task_self(), mp,
				MACH_PORT_LIMITS_INFO, (mach_port_info_t)&limits,
				sizeof(limits));
		DISPATCH_VERIFY_MIG(kr);
		(void)dispatch_assume_zero(kr);
	}
	/// 7. 最终得到的port赋值给handle
	handle = mp;
#elif defined(__linux__)
  /// 省略linux实现
#else
#error "runloop support not implemented on this platform"
#endif
  /// 8. 这个很容易猜测就是给 dq 队列中的某个属性绑定对应的port
  ///    dq->do_ctxt = (void *)(uintptr_t)handle;
	_dispatch_runloop_queue_set_handle(dq, handle);

	_dispatch_program_is_probably_callback_driven = true;
}

/// 最后插一行前面的代码 不看也知道是从dq 队列中拿到port喽
_dispatch_runloop_queue_get_handle(dq);
```

</details>

> 小节下：上面几行代码本质就是allocate一个port出现，绑定到对应的queue，这里是main queue，稍微特殊点。温顾下分配一个port的核心方法：`mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &port);`

## `modeQueuePort` 分析

<details open>
  <summary>源码如下，仅10行不到：</summary>

```c
#if USE_DISPATCH_SOURCE_FOR_TIMERS
    mach_port_name_t modeQueuePort = MACH_PORT_NULL;
    if (rlm->_queue) {
        modeQueuePort = _dispatch_runloop_root_queue_get_port_4CF(rlm->_queue);
        if (!modeQueuePort) {
            CRASH("Unable to get port for run loop mode queue (%d)", -1);
        }
    }
#endif
```

</details>

简单看下源码，瞬间几个疑惑点出来：
1. 这里源码宏定义标识 `#if USE_DISPATCH_SOURCE_FOR_TIMERS #endif` ，Timers定时器相关？
2. `mach_port_name_t modeQueuePort` 显然也是个port，但是类型怎么不一样了，讲道理应该是`__CFPort`啊？
3. `_dispatch_runloop_root_queue_get_port_4CF` 估计也是在gcd源码中

第二点其实都是别名，最后本质还是`typedef unsigned int`；

<details open>
  <summary>`_dispatch_runloop_root_queue_get_port_4CF` 源码：</summary>

```c
#if TARGET_OS_MAC
dispatch_runloop_handle_t
_dispatch_runloop_root_queue_get_port_4CF(dispatch_queue_t dq)
{
	if (slowpath(dq->do_vtable != DISPATCH_VTABLE(queue_runloop))) {
		DISPATCH_CLIENT_CRASH(dq->do_vtable, "Not a runloop queue");
	}
	return _dispatch_runloop_queue_get_handle(dq);
}
#endif
```

</details>

前面说到每一个 dq 队列都绑定一个 port，那么这个函数无非就是从传入的 dq 中取出 port 而已，而队列就是从 runloop mode 中以 `rlm->_queue` 取出。

那么我现在需要思考的是 runloop mode 中的 queue 是什么？当前运行时模式下当且仅有一个队列，这个可以从RunLoopMode的数据结构看出，以及源码显示倘若取不到modeQueuePort就要崩溃，简介说明rlm->queue不能为nil。遗留问题如下：

- [ ] 每个 RunLoop Mode 为什么要有一个 queue，作用是什么？
- [ ] 这个 queue 是怎么赋值上去的，比如前面怀疑是Timer，难道是专门处理定时器的事务的队列吗？

后面的源码貌似在设置一个超时定时器，咱不讨论。

下面进入到 do{}while(0 ==retVal) 超长处理，明天接着搞里面的port知识点。列下章节知识点：

1. 可爱的 mach port 相关声明，比如 `mach_msg_header_t` 和 `msg_buffer` 一个3字节缓存数组，【2651-2664】
2. 紧接着一个 `__CFRunLoopServiceMachPort` 拉开了序幕，【2685-2700】
3. 再次进入下一层“梦境”(do{}while(1))，里面的 `__CFRunLoopServiceMachPort`和`_dispatch_runloop_root_queue_perform_4CF` 着实看着有趣、亲切；【2727-2740】
4. 孤苦伶仃的 `__CFPortSetRemove(dispatchPort, waitSet);`【2770-2770】
5. 接近尾声，为啥会有一堆port的判断，livePort、waitPort都是什么东西？

上述这些明天学习。

# 2018/12/04

今日学习和解决疑惑点：

1. 可爱的 mach port 相关声明，比如 `mach_msg_header_t` 和 `msg_buffer` 一个3字节缓存数组，【2651-2664】
2. 紧接着一个 `__CFRunLoopServiceMachPort` 拉开了序幕，【2685-2700】
3. 再次进入下一层“梦境”(do{}while(1))，里面的 `__CFRunLoopServiceMachPort`和`_dispatch_runloop_root_queue_perform_4CF` 着实看着有趣、亲切；【2727-2740】
4. 孤苦伶仃的 `__CFPortSetRemove(dispatchPort, waitSet);`【2770-2770】
5. 接近尾声，为啥会有一堆port的判断，livePort、waitPort都是什么东西？

## 第1点 ： mach port 相关声明
<details open>
  <summary>源码如下：</summary>

```c
#if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
        voucher_mach_msg_state_t voucherState = VOUCHER_MACH_MSG_STATE_UNCHANGED;
        voucher_t voucherCopy = NULL;
#endif
        uint8_t msg_buffer[3 * 1024];
#if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
        mach_msg_header_t *msg = NULL;
        mach_port_t livePort = MACH_PORT_NULL;
#endif
```

</details>

上面仅仅是声明变量，具体实例化和配置应该在后面

## 第2点：`__CFRunLoopServiceMachPort(dispatchPort...)` 前瞻（后面还要分析）

<details open>
  <summary>保留MacOS平台源码：</summary>

```c
if (MACH_PORT_NULL != dispatchPort && !didDispatchPortLastTime) {
  msg = (mach_msg_header_t *)msg_buffer;
  if (__CFRunLoopServiceMachPort(dispatchPort, &msg, sizeof(msg_buffer), &livePort, 0, &voucherState, NULL)) {
      goto handle_msg;
  }
}
```

</details>

`dispatchPort`是通过 `_dispatch_get_main_queue_port_4CF()` 方法获得，即从mainQueue队列中取到绑定的port，这部分代码可以回顾之间的笔记。

> port都是通过 `mach_port_allocate` 实例化出来的，至于所以的 mainQueue 主队列，不过就是 `_dispatch_main_q` 全局变量，一个结构体，初始化源码貌似上面没贴，这里补上：


<details>
  <summary>全局变量`_dispatch_main_q`定义如下：</summary>

```c
struct dispatch_queue_s _dispatch_main_q = {
	DISPATCH_GLOBAL_OBJECT_HEADER(queue_main),
#if !DISPATCH_USE_RESOLVERS
	.do_targetq = &_dispatch_root_queues[
			DISPATCH_ROOT_QUEUE_IDX_DEFAULT_QOS_OVERCOMMIT],
#endif
	.dq_state = DISPATCH_QUEUE_STATE_INIT_VALUE(1) |
			DISPATCH_QUEUE_ROLE_BASE_ANON,
	.dq_label = "com.apple.main-thread",
	.dq_atomic_flags = DQF_THREAD_BOUND | DQF_CANNOT_TRYSYNC | DQF_WIDTH(1),
	.dq_serialnum = 1,
};
```

</details>

上面源码先判断port不为空，且上一次没有 `dispatchPortLastTime` 过才满足条件，值得注意的是一开始`dispatchPortLastTime` 初始值为 true，所以第一次是直接越过这个if-else语句，紧跟这个条件语句竟然是`dispatchPortLastTime=false`。

那么疑惑点又要+1了，为啥第一次要绕过呢？另外livePort初始值也为NULL，看来后面又会设置，毕竟这一步绕过了。

尽管我很想看 `__CFRunLoopServiceMachPort` 的实现，但是此时显然时机不佳，暂时按下不表。

## 第2.1点：`__CFPortSetInsert` 的小插曲
这部分源码上面我发现还有个落网之鱼：

```
///【2716-2718】
#if __HAS_DISPATCH__
  __CFPortSetInsert(dispatchPort, waitSet);
#endif
```
首先 `__CFPortSet waitSet = rlm->_portSet;` 从当前模式中取到port端口，dispatchPort我发现根据条件一定是main Queue 的port。

另外RunLoopMode结构体包含了一个属性 `dispatch_queue_t queue`，而它又绑定了我们的 mach Port；但是`__CFPortSet _portSet;`这个port又是什么鬼？？？？

找了下`mach_port_insert_member`的声明[接口说明](http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_port_insert_member.html)，对于三个参数解释如下：

```
task
[in task send right] The task holding the port set and receive right.
member
[in scalar] The task's name for the receive right.
set
[in scalar] The task's name for the port set.
```
这尼玛是什么鬼东西，其实都没搞懂receive right和 port set的定义和作用...姑且理解为将member port的receive right赋予给一个port set。

我在uninformed找到了对port set的定义：
> A port set is (unsurprisingly) a collection of Mach ports. Each of the ports in a port set use the same queue of messages.

一开始我也这么理解，但是我看到 `__CFPortSet` 并非是个集合或者数组啊，只是一个普普通通的 `unsigned int`，难道？maybe这个int值标识作为key，取到的value就是一个集合？？ 这样貌似说的通了。

另外这段代码源码也给了注释：
> Must push the local-to-this-activation ports in on every loop iteration, as this mode could be run re-entrantly and we don't want these ports to get serviced.

结合上面的理解，我认为变相的就是把dispatchPort**整合/加入**到waitSet中，这样所有的ports都共用一个消息队列来派发拉(见上面对portSet的定义)。

## 第三点：`__CFRunLoopServiceMachPort` 的学习
<details>
  <summary>按惯例贴源码，然后再细看分析</summary>

```c
do {
    msg = (mach_msg_header_t *)msg_buffer;
    
    __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY, &voucherState, &voucherCopy);
    
    if (modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort) {
        // Drain the internal queue. If one of the callout blocks sets the timerFired flag, break out and service the timer.
        while (_dispatch_runloop_root_queue_perform_4CF(rlm->_queue));
        if (rlm->_timerFired) {
            // Leave livePort as the queue port, and service timers below
            rlm->_timerFired = false;
            break;
        } else {
            if (msg && msg != (mach_msg_header_t *)msg_buffer) free(msg);
        }
    } else {
        // Go ahead and leave the inner loop.
        break;
    }
} while (1);
```

</details>

核心方法应该还是 `__CFRunLoopServiceMachPort`，此时的 waitSet 我们刚“改装”过，&msg其实就是个局部变量，指向分配了3字节的数组`msg_buffer`，看似应该是用来接收数据；&livePort其实就是传个指针进去，为的是函数内部赋值这个live活着的port。 至于 &voucherState 还不知道.

<details>
  <summary>`__CFRunLoopServiceMachPort` 实现代码有点多</summary>

```c
static Boolean __CFRunLoopServiceMachPort(mach_port_name_t port, mach_msg_header_t **buffer, size_t buffer_size, mach_port_t *livePort, mach_msg_timeout_t timeout, voucher_mach_msg_state_t *voucherState, voucher_t *voucherCopy) {
    Boolean originalBuffer = true;
    kern_return_t ret = KERN_SUCCESS;
    for (;;) {		/* In that sleep of death what nightmares may come ... */
        mach_msg_header_t *msg = (mach_msg_header_t *)*buffer;
        msg->msgh_bits = 0;
        msg->msgh_local_port = port;
        msg->msgh_remote_port = MACH_PORT_NULL;
        msg->msgh_size = buffer_size;
        msg->msgh_id = 0;
        if (TIMEOUT_INFINITY == timeout) { CFRUNLOOP_SLEEP(); } else { CFRUNLOOP_POLL(); }
        ret = mach_msg(msg, MACH_RCV_MSG|(voucherState ? MACH_RCV_VOUCHER : 0)|MACH_RCV_LARGE|((TIMEOUT_INFINITY != timeout) ? MACH_RCV_TIMEOUT : 0)|MACH_RCV_TRAILER_TYPE(MACH_MSG_TRAILER_FORMAT_0)|MACH_RCV_TRAILER_ELEMENTS(MACH_RCV_TRAILER_AV), 0, msg->msgh_size, port, timeout, MACH_PORT_NULL);

        // Take care of all voucher-related work right after mach_msg.
        // If we don't release the previous voucher we're going to leak it.
        voucher_mach_msg_revert(*voucherState);
        
        // Someone will be responsible for calling voucher_mach_msg_revert. This call makes the received voucher the current one.
        *voucherState = voucher_mach_msg_adopt(msg);
        
        if (voucherCopy) {
            *voucherCopy = NULL;
        }

        CFRUNLOOP_WAKEUP(ret);
        if (MACH_MSG_SUCCESS == ret) {
            *livePort = msg ? msg->msgh_local_port : MACH_PORT_NULL;
            return true;
        }
        if (MACH_RCV_TIMED_OUT == ret) {
            if (!originalBuffer) free(msg);
            *buffer = NULL;
            *livePort = MACH_PORT_NULL;
            return false;
        }
        if (MACH_RCV_TOO_LARGE != ret) break;
        buffer_size = round_msg(msg->msgh_size + MAX_TRAILER_SIZE);
        if (originalBuffer) *buffer = NULL;
        originalBuffer = false;
        *buffer = realloc(*buffer, buffer_size);
    }
    HALT;
    return false;
}
```

</details>

其实虽然复杂，但是仔细看发送就是hello.c中的server函数。说了设置local就是为了receive，设置了remote就是为了send。
有看到说 `CFRUNLOOP_SLEEP 和 CFRUNLOOP_POLL`并非是`do{}while(0)`宏定义实现，而真正实现应该是在 `CFRunLoopProbes.h` 中，注意看宏定义中的 `#if CF_RUN_LOOP_PROBES #else #endif`。

虽然很遗憾，还得继续。

`ret = mach_msg` 这边我看是单纯为接收存在。`thread voucher state` 难道是指线程凭证状态吗，用状态来管理线程？这个暂时先不了解了，反正我看 `voucher_mach_msg_revert` 和 `voucher_mach_msg_adopt` ，如果让我理解就是一个全局变量，就是存储当前线程的信息，比如这里的msg。

后面可以看到livePort的赋值，和我们预料的差不多，此时livePort有了，`msg_buffer`也有数据了，voucherState也取到了值（函数返回值定义如下：The previous thread voucher state or `VOUCHER_MACH_MSG_STATE_UNCHANGED` if no state change occurred.）。

最后就是 `goto handle_msg`。

> 小节：这里留下一堆疑惑点，还是不知道休眠怎么实现的，还是苹果爸爸太封闭，`CFRUNLOOP_SLEEP` 和`CFRUNLOOP_POLL` 以及`CFRUNLOOP_WAKEUP` 宏定义都没告诉我们。假如timeout=0，猜测是不进入休眠，而是直接监听port消息。

## 第3.1点：`_dispatch_runloop_root_queue_perform_4CF(rlm->_queue)`
差点就略过这里了，简单贴下源码吧，这端代码执行的前提是 `modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort`，相当于是为 `modeQueuePort` 服务，而modeQueuePort 之前说了就是从rlm的queue队列中取出port，结合今天学习到的port Set，相当于消息队列都会和一个端口绑定，port可能会接受很多message，将这些消息都push到队列中一个个处理确实比较合理，这些都是我的猜测。

```c
bool
_dispatch_runloop_root_queue_perform_4CF(dispatch_queue_t dq)
{
	if (slowpath(dq->do_vtable != DISPATCH_VTABLE(queue_runloop))) {
		DISPATCH_CLIENT_CRASH(dq->do_vtable, "Not a runloop queue");
	}
	dispatch_retain(dq);
	bool r = _dispatch_runloop_queue_drain_one(dq);
	dispatch_release(dq);
	return r;
}
```
`_dispatch_runloop_queue_drain_one` 的实现有点长，打算在之后学习GCD的时候学习。大概猜测下，首先 `dispatch_queue_t` 队列是绑定了一个端口的，然后可以从线程中取到voucher，然后给port派发消息？？？？

看下源码注释：

```c
// Drain the internal queue. If one of the callout blocks sets the timerFired flag, break out and service the timer.
```
另外 `rlm->_timerFired` 注释也写到 `set to true by the source when a timer has fired`，感觉就是定时器。

不过`_dispatch_runloop_root_queue_perform_4CF` 完整流程感觉还是无法自圆其说，说明我理解有误。

## 第4点：__CFPortSetRemove(dispatchPort, waitSet);

不难理解了，就是从waitSet中剥离出dispatchPort。

## 第5点： 一系列的场景判断
其中 `modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort` 我发现这里比较有意思，刚才对这个就不理解，`_dispatch_runloop_root_queue_perform_4CF` 到底干了正事没，现在看发现这里在执行Timer的Block。

```c
if (!__CFRunLoopDoTimers(rl, rlm, mach_absolute_time())) {
    // 由于我们提前开火了，所以需要为下一次重新组装一个定时器 
    __CFArmNextTimerInMode(rlm, rl);
}
```
`rlm->_timerPort` 是什么鬼不知道。。。

`livePort == dispatchPort` 的场景就需要 `__CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg)`来干活了。反正又扯上了 GCD 的 `_dispatch_main_queue_callback_4CF` 方法。

我突然想到所谓的drain queue，其实就是把队列中的任务(Block) 一个个做完吧。。。。

其他情况就是 `CFRUNLOOP_WAKEUP_FOR_SOURCE` ：
```c
CFRUNLOOP_WAKEUP_FOR_SOURCE();
// Despite the name, this works for windows handles as well
CFRunLoopSourceRef rls = __CFRunLoopModeFindSourceForMachPort(rl, rlm, livePort);
if (rls) {
  mach_msg_header_t *reply = NULL;
  sourceHandledThisLoop = __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply) || sourceHandledThisLoop;
  if (NULL != reply) {
      (void)mach_msg(reply, MACH_SEND_MSG, reply->msgh_size, 0, MACH_PORT_NULL, 0, MACH_PORT_NULL);
      CFAllocatorDeallocate(kCFAllocatorSystemDefault, reply);
  }
}
```
可以看到是do Source1事件，也就是用户自定义事件，比如TouchEvent。

注意 `mach_msg` 就是作为source1 block之后，如果reply，那么需要向port返回值。

> 今天差不多到这里可以了，明天会对port相关的收个尾，发现知识点实在太多，已经尽量做到不拓展了，一有发散的想法，马上会告诉自己，哪个才是重点，当下目的是为了解决什么？那个知识点对全局理解有影响吗，是否真的必不可少，基本这样问完，我就取舍一二，效率还算可以。

# 2018/12/05
* [ ] 今日目标：学习 `CFRunLoopDoBlocks` 实现和用途。

源码很简单：
```c
__CFRunLoopDoBlocks(rl, rlm);
```

直接在实现源码上做了注释，主要是链表的遍历，执行。列表Item就是封装了block的结构体，难点应该是那个模式条件判断，需要理下commonModes，commonModeItems是什么，以及当前RunLoop有哪些模式，比如`kCFRunLoopDefaultMode`,`UITrackingRunLoopMode`等，这些其实都可以打上“common”标签，`kCFRunLoopCommonModes`，并非是一个新模式，应该算是多所有打了common标签的模式集合统称。

<details>
  <summary>点击展开源码TL;DR</summary>

```c

static Boolean __CFRunLoopDoBlocks(CFRunLoopRef rl, CFRunLoopModeRef rlm) { // Call with rl and rlm locked
    if (!rl->_blocks_head) return false;
    if (!rlm || !rlm->_name) return false;
    Boolean did = false;
    struct _block_item *head = rl->_blocks_head;
    struct _block_item *tail = rl->_blocks_tail;
    rl->_blocks_head = NULL;
    rl->_blocks_tail = NULL;
    // commonMode
    CFSetRef commonModes = rl->_commonModes;
    // rlm其实就是当前的模式 从rl->_currentMode 也是可以的
    CFStringRef curMode = rlm->_name;
    __CFRunLoopModeUnlock(rlm);
    __CFRunLoopUnlock(rl);
    struct _block_item *prev = NULL;
    struct _block_item *item = head;
    while (item) {
        struct _block_item *curr = item;
        item = item->_next;
        Boolean doit = false;
        if (CFStringGetTypeID() == CFGetTypeID(curr->_mode)) {
            // String 类型 比如 kCFRunLoopDefaultMode UITrackingRunLoopMode
            // 如果说这个block标识运行的模式为 kCFRunLoopCommonModes，
            // 也就是当前模式也打上了“common”标签
            // ps: 对于default track mode，都是默认打上了common标签的，所以会把modeItem加入到
            // commonModeItem中。而 commonModes 等同于标记common的名称数组
            // [kCFRunLoopDefaultMode,UITrackingRunLoopMode]
            doit = CFEqual(curr->_mode, curMode) || (CFEqual(curr->_mode, kCFRunLoopCommonModes) && CFSetContainsValue(commonModes, curMode));
        } else {
            // 如果 curr->mode 本身就是一个SetRef 集合 那么就要使用contain判断的
            // 场景应该是某个block是要求在多个mode下被调用
            // 条件一：表示当前模式在它“白名单”中
            // 条件二：白名单中可能还包含 kCFRunLoopCommonModes，所以还要遍历
            // 举个例子，curr->_mode 是block要求执行的场景比如 [kCFRunLoopCommonModes]
            // curMode = UITrackingRunLoopMode
            // 然后commonModes 应该包含的是所有打了common标签的mode,这里包含default tracking等等
            // 主要场景是用户其实不想为某个block指定具体的mode，直接common了事
            doit = CFSetContainsValue((CFSetRef)curr->_mode, curMode) || (CFSetContainsValue((CFSetRef)curr->_mode, kCFRunLoopCommonModes) && CFSetContainsValue(commonModes, curMode));
        }
        if (!doit) prev = curr;
        if (doit) {
            if (prev) prev->_next = item;
            if (curr == head) head = item;
            if (curr == tail) tail = prev;
            void (^block)(void) = curr->_block;
                CFRelease(curr->_mode);
                free(curr);
            if (doit) {
                    // 其他没有好说的，这里的calling out 有种打电话过来的意味
                    // 试想我们在上层代码中，突然runloop打电话过来告诉你事件...执行block
                    __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);
                did = true;
            }
            Block_release(block); // do this before relocking to prevent deadlocks where some yahoo wants to run the run loop reentrantly from their dealloc
        }
    }
    __CFRunLoopLock(rl);
    __CFRunLoopModeLock(rlm);
    if (head) {
	tail->_next = rl->_blocks_head;
	rl->_blocks_head = head;
        if (!rl->_blocks_tail) rl->_blocks_tail = tail;
    }
    return did;
}
```

</details>

> 但是现在问题来了，其实实现非常简单，但是我还是不知道这些Block到底是通过何种方式添加进去的。这个应该是明日要解决的问题。

# 2018/12/06
（明日待办任务列表）
- [ ] Main RunLoop 默认添加了哪些 Mode，各适用于哪些场景；
- [ ] CFRunLoopDoBlocks 执行的链表item是怎么加进去的
- [ ] RunLoop 的休眠，休眠时候真的什么都不做吗？那视图渲染呢？
- [ ] 屏幕的 UI 渲染更新机制，是放在RunLoop哪个阶段做的；

今日在看runLoop.c源码————从头至尾。基本就是DoXXXX系列。上述任务延后。

# 2018/12/08

今日小雪。看完了runloop.c文件的源码，收获很少，可能是因为没有结合学习目标，或是应用场景，明日还是按照计划来做事。

# 2018/12/09

### 1. Main RunLoop 默认添加了哪些 Mode，各适用于哪些场景

目前网上很多教程都会提及系统提供的4个Mode：
1. kCFRunLoopDefaultMode (NSDefaultRunLoopMode)
2. UITrackingRunLoopMode
3. UIInitializationRunLoopMode
4. GSEventReceiveRunLoopMode

另外 NSRunLoopCommonModes 根据上面的源码分析，可以看到仅仅是对正常Mode的标记“Common”。

> 上面除了 initializationRunLoopMode ，其他都可以 `NSRunLoop *runloop = [NSRunLoop currentRunLoop];` 打印这个runloop对象可以看到。

至于何时添加这些Mode，google后没找到

### 2. CFRunLoopDoBlocks 执行的链表item是怎么加进去的

首先block添加接口可以在源码中找到：
```c
void CFRunLoopPerformBlock(CFRunLoopRef rl, CFTypeRef mode, void (^block)(void)){}
```

`CFSocket.c` 文件中的 `__CFSocketManager` 有调用到，但是貌似只是日志输出：

```c
CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopDefaultMode, ^{
    CFTimeInterval dt = CFAbsoluteTimeGetCurrent() - endTime;
    if (dt > 0) {
        __CFSOCKETLOG("select() timeout %lu - took %.05f for the main runloop (TOO LONG!)", __CFSocketManagerIteration, dt);
    } else {
        __CFSOCKETLOG("select() timeout %lu - took %.05f for the main runloop", __CFSocketManagerIteration, dt < 0? -dt : dt);
    }
});
```
再去 gcd 源码中找了下，发现也仅是日志，可能是搜索方式不对，暂时reserved。

不过发现了这个方法和gcd的 `dispatch_async` 方法对比：

```c
dispatch_async(dispatch_get_main_queue(), ^{calayer.transform = newTransform});

CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {calayer.transform = newTransform});
```

简要总结下stackoverflow上的回答
1. 前者仅能控制在哪个队列中，比如mainloop，或其他runloop，但是无法指定mode类型，也就是说默认就是commonModes；后者显而易见就是更灵活；
2. `CFRunLoopPerformBlock` 并不能立马wake up唤醒当前runloop的休眠，只能等到有事件到来（user event occurs, timer fires, run loop source fires, mach message is received, etc.）唤醒runloop，下一次流程执行 `CFRunLoopDoBlocks`，这可能就解释了为啥有些地方有多个调用，可以回去再看下源码，我记得自己标记了不解；但是如果我们希望`CFRunLoopPerformBlock` 立马调用，就需要间接再调用 `CFRunLoopWakeUp` 方法；

因此，如果你使用 `CFRunLoopDoBlocks` 配合 `CFRunLoopWakeUp` 其实两者就很相似了。


### 3. RunLoop 的休眠，休眠时候真的什么都不做吗？那视图渲染呢？
没找到具体文档或者教程来阐述这方面的知识，搜了下Stackoverflow发现也有人又相关疑惑，比如 [Stackoverflow Question: NSRunLoop : Is it really idle between kCFRunLoopBeforeWaiting & kCFRunLoopAfterWaiting?](https://stackoverflow.com/questions/35872203/nsrunloop-is-it-really-idle-between-kcfrunloopbeforewaiting-kcfrunloopafterw) ，这里有个小技巧，看过源码我们知道内部的 `do{}while(0==retVal)` 处理流程第一步就是通知observer kCFRunLoopBeforeTimers 事件，紧接是 kCFRunLoopBeforeSources，所以我们可以简单认为beforeTimer这个观察事件是一次新runloop流程处理的开始，为此我们可以监听这个事件，然后搞个static静态变量计数，每次事件发生时计数加一，标识一次新的runloop处理Id，如下：

```oc
CFRunLoopObserverRef observerRef = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
    if (activity == kCFRunLoopBeforeTimers) {
        weakSelf.runloopId += 1;
    }
    NSLog(@"RunloopId : %lu, Activity : %ld, %lf\n", (unsigned long)weakSelf.runloopId, activity, [[NSDate date] timeIntervalSince1970]);
});
CFRunLoopAddObserver(CFRunLoopGetMain(), observerRef, kCFRunLoopCommonModes);

// 输入类似如下：
RunloopId : 156, Activity : 2, 1457445513.522846
RunloopId : 156, Activity : 4, 1457445513.522985
RunloopId : 156, Activity : 32, 1457445513.523144
RunloopId : 156, Activity : 64, 1457445529.002502
RunloopId : 157, Activity : 2, 1457445529.002820
RunloopId : 157, Activity : 4, 1457445529.003044
```

关于视图渲染，其实是 `Core Animation` 在干活。

[Understanding NSRunLoop](https://stackoverflow.com/questions/12091212/understanding-nsrunloop)，看了感觉干货不多，暂时留着给有需要的人看。

Yuri Romanchenko 的回答有点厉害：[Does UIApplication sendEvent: execute in a NSRunLoop?](https://stackoverflow.com/questions/22116698/does-uiapplication-sendevent-execute-in-a-nsrunloop/22121981#22121981)
让我知道了还有 purple system project 这一层，是iOS的代号？？？其实少数人只知道有springBoard.app来派发事件给launch的应用程序，比如告诉touches触摸事件，前后台切换等等，殊不知其实springboard是通过purple system event 的port来进行事件交流的。

另外还查到一个GCD比较有意思的东西，就是如何在一个应用程序或是一个runloop外进行GCD事件派发，即实现一个简单、且最小巧的GCD代码。[源码](https://wiki.freebsd.org/GCD)如下：

```c
#include <dispatch/dispatch.h>

#include <err.h>
#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char *argv[])
{
        dispatch_queue_t q;
        dispatch_time_t t;

        q = dispatch_get_main_queue();
        t = dispatch_time(DISPATCH_TIME_NOW, 5LL * NSEC_PER_SEC);

        // Print a message and exit after 5 seconds.
        dispatch_after(t, q, ^{
                printf("block_dispatch\n");
                exit(0);
            });

        dispatch_main();
        return (0);
}
```

以及不适用 C block的方式：

```c
#include <dispatch/dispatch.h>

#include <err.h>
#include <stdio.h>
#include <stdlib.h>

void
deferred_code(__unused void *arg)
{

        printf("block_dispatch\n");
        exit(0);
}

int
main(int argc, char *argv[])
{
        dispatch_queue_t q;
        dispatch_time_t t;

        q = dispatch_get_main_queue();
        t = dispatch_time(DISPATCH_TIME_NOW, 5LL * NSEC_PER_SEC);

        dispatch_after_f(t, q, NULL, deferred_code);

        dispatch_main();
        return (0);
}
```
关键还是 `dispatch_main()` 方法，内部估计也是开了个pthread，然后while1了。 之后学习GCD的时候就可以看到。

### 4. 屏幕的 UI 渲染更新机制，是放在RunLoop哪个阶段做的；

reserved ，不是很清楚是在哪一步提交的layer.content。



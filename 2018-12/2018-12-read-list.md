> Theme: RunLoop主题、年度整理
> Source Code Read Plan:
- [x] MachPort的设计思路以及写Example；
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

# 2018/12/02
- [x] MachPort的设计思路以及写Example

更正下上一个提交，首先mach port的资料真的很匮乏，即使到如今还是搜不到健全的资料，甚至连个完整能运行的Demo都没有（可能是我搜到的博文认为这都是基础，因此只贴了一些数据结构的解释），下面的代码运行ok的，我用pthread创建线程用于监听消息，在主线程里发送给指定的port一个`0x12345678`的数据。注意点罗列下：

1. `struct message` header的设置相当重要，比如size大小；其次body并非是数据源，而是一个描述数据源(类型`mach_msg_type_descriptor_t`)的个数，而type中的pad1才是真正要传的data，pad2为data占的字节数；
2. header中的`msgh_remote_port` 和 `msgh_local_port`分别是什么，如何赋值的说明，这得根据发送和接收两种场景而定。首先一个connection连接必定有两端，所以要分配两个port，这里是port和receive，receive属于main thread中Task，而port属于fork出来子线程Task的；可以看到我们想要在main thread中send一个消息给子线程，那么`msgh_remote_port` 目的端就是 port，`msgh_local_port` 源端口就是 receive，当然在send时候我认为不设也没关系的；再来看子线程接收的header，它只负责监听接收，那么只需要设置`msgh_local_port` 就可以，也就是 port，如果说服务端接收消息后还要发送，那么就要设置header中的`msgh_remote_port` 为目的端口 receive。感觉说的还是有点绕，用图可能会清晰点。总结来说，如果是send行为，那么header必定是要设置`msgh_remote_port`，如果是接收，那么设置`msgh_local_port`就行了，至于port就是一开始分配好的；
3. 关于port的 allocate，其实还没搞懂，官方文档总是说属于一个Task，关联很多thread，比较绕；
4. 刚才demo没跑起来，其实就是因为header中的size没有设置对，其实想想也对，因为接收端需要明确需要receive多少个字节后才能解析成对的数据结构；
5. pthread的使用，这个网上资料很多

<details>
  <summary>Hello World Demo 片段</summary>

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
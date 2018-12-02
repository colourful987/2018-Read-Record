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
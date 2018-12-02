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

# 2018/12/02
很遗憾，资料匮乏，官方文档说的也完全搞不清楚，网上demo还不兼容macos系统，下面的demo简单演示了一个server，一个client，但是server接收到总是error，不知道怎么解决：
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
    int err;
    
    struct message message;
//    message.header.msgh_remote_port = port;
    message.header.msgh_local_port = port; // 服务端监听的port
    message.header.msgh_size = 100;//sizeof(message);
    
    while (1) {
        /* Receive a message */
        err = mach_msg(&message.header,
                       MACH_RCV_MSG, // 设置为接收
                       0, // 这个是send 的size ，因此作为接收方这里无所谓 0都可以
                       100,//sizeof(message), // 要接收的包大小
                       port, // 接收端口
                       MACH_MSG_TIMEOUT_NONE, // 没有超时 即一直等待
                       MACH_PORT_NULL); // 不需要Notification
        if (err) {
            NSLog(@"mach_msg error");
        } else {
            unsigned int mag_data = message.type.pad1;
            NSLog(@"receive: %d",mag_data);
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
    static int idx = 3;
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
        msg.header.msgh_size = 100; //sizeof(msg)
        
        msg.body.msgh_descriptor_count = 1;
        msg.type.pad1 = msg_data;
        msg.type.pad2 = sizeof(msg_data);
        
        mach_msg_return_t err = mach_msg_send(&msg.header);
        if (err != MACH_MSG_SUCCESS) {
            NSLog(@"could not send uint:0x%x\n",err);
        }
        idx--;
    }
    
    
    return 0;
}
```
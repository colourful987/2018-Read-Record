# 1. CFRunLoopRun
总流程图：其中 `CFRunLoopRunSpecific` 方法实现是一套设计好的工作流程，针对不同的事件作出对应的响应处理，用枚举标识处理结果，可以看到结果状态为 `kCFRunLoopRunStopped` 或 `kCFRunLoopRunFinished` 时退出 while 循环：

![RunLoop_MainEntry.png](./resource/RunLoop_MainEntry.png)

当然类似：
```
do {
  ret = doSomething();
}while(ret);
```
上述代码存在一个问题，`doSomething` 如果一直返回 1，会导致无限循环，CPU 占据 100 % 使用率，这可以理解，因为始终保持工作状态。但是应用程序并非一直处于工作状态，所以在空闲时可以让进程休眠，一旦有事件产生，则唤醒应用处理。

举个例子：响应键盘输入，做出不同处理。有两种方式：方式一、轮询，即不断查询GPIO引脚高低电平值，但是这样做会导致CPU负荷很大，为了减轻CPU的压力，又能及时响应键盘输入，我们可以每隔100ms查询一次状态，假设只要查询状态代码耗时 10ms，那么工作时间占比是 10/110 ≈ 10%而已，如何设定时间间隔 100ms 呢？如下方式就可以了：

```
// 关于i,j的范围设定 并非是1000
for (int i = 0;i<1000;i++){
  for (int j = 0; j< 1000;j++){
    // NoOp
  }
}
```

首先这段代码双循环，但是未处理任何事务(No Operation)，所以 CPU 会自动切换到休眠状态，把时间片释放给其他进程使用，至于休眠多久，就这里 i =1000和j=1000是根据晶振频率决定。

方式二：中断，即默认休眠状态，只有当GPIO发生高低电平变化了触发硬件中断，跳入到中断处理代码。

两种方式区别在于一个主动，一个被动，后者响应准确且及时，避免不必要的CPU消耗。

**遗留问题：**
1. `CFRunLoopRun` 的 caller 是谁？

# 2. CFRunLoopGetCurrent

RunLoop 和线程一一对应，通过 `pthread_self()` 获取到当前线程信息的指针，类型为 `pthread_t`。

* `CHECK_FOR_FORK`:
* `_CFGetTSD` 线程特有数据，TSD:Thread-Specific Data，即一个线程内部的各个函数都能访问、但其他线程不能访问的变量，这种机制还称之为线程局部静态变量（Static memory local to a thread）或线程局部存储（TLS:Thread-Local storage），更多请见[Linux中的线程局部存储一文](https://blog.csdn.net/cywosp/article/details/26469435);
* `_CFRunLoopGet0(pthread_self())` 是大部分博客讲解的重点：每个线程在fork的时候得到唯一的一个 `pthread_t` 结构体指针，以它为key，value为RunLoop对象存储到一个全局字典中，按照代码逻辑来说，先从字典中尝试获取当前线程对应的runloop对象，获取直接返回，没有则创建一个，存储同时返回;

```objective-c
CFRunLoopRef CFRunLoopGetCurrent(void) {
    CHECK_FOR_FORK();
    CFRunLoopRef rl = (CFRunLoopRef)_CFGetTSD(__CFTSDKeyRunLoop);
    if (rl) return rl;
    return _CFRunLoopGet0(pthread_self());
}
```

**遗留问题：**
1. 为何有两种存储方式：TSD 和 CFMutableDictionaryRef；为何先从TSD尝试获取？

## 2.1 _CFRunLoopGet0

这里涉及的知识点不多，1. `__CFRunLoops` 静态字典变量作为cache，key=线程ID(pthread_t type) value=runloop；2.懒加载？其实也不算 3.所有的实现都是基于结构体，结构体比平常用到复杂一些，主要是成员多是函数指针;4.runloop结构体我觉得更像是一份配置描述：`CFMutableSetRef _modes`，内含多个运行mode配置，在不同事件下以配置好的mode加载运行，运行在那个`do{}while(1)` 代码块中，代码块要做的工作就是根据这个mode配置和处理流程做事罢了。

![RunLoop_GetCurrentRunLoop.png](./resource/RunLoop_GetCurrentRunLoop.png)

# 3. CFRunLoopRunSpecific

> Q: 何为运行(调起)一个 RunLoop ？
> A: RunLoop 是一系列配置+事件响应处理，`do {} while(1)`中的 代码块就是按照预先设定好的处理流程，来响应不同的事件。`CFRunLoopRunSpecific`函数 就是一次处理流程（除了网上说的7个步骤，其实还包括mode切换等），处理结果为 CFRunLoopRunResult 类型：

```
typedef CF_ENUM(SInt32, CFRunLoopRunResult) {
    kCFRunLoopRunFinished = 1,
    kCFRunLoopRunStopped = 2,
    kCFRunLoopRunTimedOut = 3,
    kCFRunLoopRunHandledSource = 4
};
```

`CFRunLoopRunSpecific` 函数定义如下，外部决定唤起rl中的哪个mode设置为当前运行模式：

```objective-c
SInt32 CFRunLoopRunSpecific(CFRunLoopRef rl, CFStringRef modeName, CFTimeInterval seconds, Boolean returnAfterSourceHandled){
SInt32 CFRunLoopRunSpecific(CFRunLoopRef rl, CFStringRef modeName, CFTimeInterval seconds, Boolean returnAfterSourceHandled) {     /* DOES CALLOUT */
    CHECK_FOR_FORK();
    // 1. 对于异常传参判断处理
    if (modeName == NULL || modeName == kCFRunLoopCommonModes || CFEqual(modeName, kCFRunLoopCommonModes)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            CFLog(kCFLogLevelError, CFSTR("invalid mode '%@' provided to CFRunLoopRunSpecific - break on _CFRunLoopError_RunCalledWithInvalidMode to debug. This message will only appear once per execution."), modeName);
            _CFRunLoopError_RunCalledWithInvalidMode();
        });
        return kCFRunLoopRunFinished;
    }
    // 2. 如果runloop已经释放掉了，标识为结束且退出
    if (__CFRunLoopIsDeallocating(rl)) return kCFRunLoopRunFinished;
    __CFRunLoopLock(rl);
    
    // 3. 从rl中寻找是否有预先设定的modeName
    CFRunLoopModeRef currentMode = __CFRunLoopFindMode(rl, modeName, false);
    if (NULL == currentMode || __CFRunLoopModeIsEmpty(rl, currentMode, rl->_currentMode)) {
        Boolean did = false;
        if (currentMode) __CFRunLoopModeUnlock(currentMode);
        __CFRunLoopUnlock(rl);
        return did ? kCFRunLoopRunHandledSource : kCFRunLoopRunFinished;
    }
    
    // 4. 这里是runloop的模式切换，比如之前是defaultRunloop 现在切换成trackingMode
    volatile _per_run_data *previousPerRun = __CFRunLoopPushPerRunData(rl);
    CFRunLoopModeRef previousMode = rl->_currentMode;
    rl->_currentMode = currentMode;
    int32_t result = kCFRunLoopRunFinished;
    
    // ====================== 5.Runloop Core Handle Flow ====================
    // 5.1 通知观察者 进入核心Runloop处理前的事件
	if (currentMode->_observerMask & kCFRunLoopEntry ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopEntry);
    // 5.2 进入 RunLoop Core Handle Flow
	result = __CFRunLoopRun(rl, currentMode, seconds, returnAfterSourceHandled, previousMode);
    // 5.3 通知观察者 进入核心Runloop处理退出的事件
	if (currentMode->_observerMask & kCFRunLoopExit ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
    // =====================================================================
    
    // 6. 处理完外部要求的runloop 模式后，还得恢复到之前的运行模式
    __CFRunLoopModeUnlock(currentMode);
    __CFRunLoopPopPerRunData(rl, previousPerRun);
	rl->_currentMode = previousMode;
    __CFRunLoopUnlock(rl);
    return result;
}
```

1. 对于异常传参判断处理
2. 如果runloop已经释放掉了，标识为结束且退出
3. 从rl中寻找是否有预先设定的modeName
4. 这里是runloop的模式切换，比如之前是defaultRunloop 现在切换成trackingMode
5. Runloop Core Handle Flow
  5.1 通知观察者 进入核心Runloop处理前的事件
  5.2 进入 RunLoop Core Handle Flow
  5.3 通知观察者 进入核心Runloop处理退出的事件
6. 处理完外部要求的runloop 模式后，还得恢复到之前的运行模式

## 3.1 __CFRunLoopRun 



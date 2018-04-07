# 如何实现一个优雅的KVO和KVB中间件

## KVO 基础用法

API 定义如下：
```
- (void)addObserver:(NSObject *)observer 
         forKeyPath:(NSString *)keyPath 
            options:(NSKeyValueObservingOptions)options 
            context:(void *)context;
```

* observer：观察者，即当被观察对象的属性变动时通知它，观察者必须实现 `observeValueForKeyPath:ofObject:change:context:` 协议方法；
* keyPath：被观察对象属性名称；
* options：值变动的时机，比如 `NSKeyValueChangeNewKey`，`NSKeyValueObservingOptionOld` 等四个选项；
* context：注册通知时候传入的上下文信息，在触发事件回调时可以拿到，这有点类似页面跳转时用字典传值；

观察者需要实现 `observeValueForKeyPath:ofObject:change:context:` 协议方法：
```
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                       context:(void *)context {
}
```
如果一位观察者 Observe 了多个实例的多个属性，那么它必定会焦头烂额，因为所有的回调只有一个入口————即上面的方法。

那么问题来了，这个方法内部必定会 `if-elseif-else` 分支处理不同被观察属性，导致代码混乱，难以维护。

## KVO 优雅的改进方式
> 分析问题关键：观察者承担了太多，就好比 Leader 告诉实习生，方案碰到问题来找我对下(`addObserver:self`)，若只有一个实习生时候，那么问题发生时就会找Leader讨论方案（回调方法中处理），但随着实习生越来越多，Leader要处理的也越来越多。怎么解决？ Leader选出几位导师，1对1和实习生对接，实习生碰到问题不再找Leader，而是导师，职责明确，而Leader可以随时更换导师和实习生的配对关系。

上述方式其实就是加了一个中间件，它作为观察者存在，负责观察某个对象的某个属性。而为了保证这个观察行为始终存在，所以我们需要持有这个中间件，当然我们也可以人为的 stop 销毁。

核心代码如下：
```
- (id)initForObject:(id)object
            keyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
              block:(dispatch_block_t)block
 blockArgumentsKind:(THObserverBlockArgumentsKind)blockArgumentsKind
{
    if((self = [super init])) {
        if(!object || !keyPath || !block) {
            [NSException raise:NSInternalInconsistencyException format:@"Observation must have a valid object (%@), keyPath (%@) and block(%@)", object, keyPath, block];
            self = nil;
        } else {
            _observedObject = object;
            _keyPath = [keyPath copy];
            _block = [block copy];
                        
            [_observedObject addObserver:self
                              forKeyPath:_keyPath
                                 options:options
                                 context:(void *)blockArgumentsKind];
        }
    }
    return self;
}

- (void)dealloc
{
    if(_observedObject) {
        [self stopObserving];
    }
}

- (void)stopObserving
{
    [_observedObject removeObserver:self forKeyPath:_keyPath];
    _block = nil;
    _keyPath = nil;
    _observedObject = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    switch((THObserverBlockArgumentsKind)context) {
        case THObserverBlockArgumentsNone:
            ((THObserverBlock)_block)();
            break;
        case THObserverBlockArgumentsOldAndNew:
            ((THObserverBlockWithOldAndNew)_block)(change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
            break;
        case THObserverBlockArgumentsChangeDictionary:
            ((THObserverBlockWithChangeDictionary)_block)(change);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"%s called on %@ with unrecognised context (%p)", __func__, self, context];
    }
}
```

## Reference
[THObserversAndBinders](https://github.com/th-in-gs/THObserversAndBinders)




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

## 关于KVO使用过程遇到的问题

THObserversAndBinders 按照源码Coding，过程中想到几个问题：

1. 对于`NSMutableArray、NSMutableSet`类型的属性，如何才能触发通知？调用`removeAtIndex:`或是 `addObject` 可以吗？
2. 关于`addObserver: forKeyPath: options: context:` 接口中的 options 有什么用？通常我们都是不假思索的填充 `NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld`（0x01 | 0x02 = 0x03），直接设置option=0又会怎么样呢？
3. 通知回调接口中的 change 字典，我们可以使用 `NSKeyValueChangeKey` 类型的键去取值，分别是`NSKeyValueChangeKindKey`、`NSKeyValueChangeNewKey`、`NSKeyValueChangeOldKey`、`NSKeyValueChangeIndexesKey`和`NSKeyValueChangeNotificationIsPriorKey`，什么情况下我们可以通过这些key取到值，什么时候取不到(即为null)

带着这些问题我测试了下：
1. 关于集合，调用`removeAtIndex`这些方法并不会触发通知回调，参照接口注释，如下即可触发:

```
[[_observedObject mutableArrayValueForKey:@"arrayPropertyName"] addObjectsFromArray:@[@3,@4]];
```
回调方法中，`change[NSKeyValueChangeKindKey]` 的值为 2 表示插入操作，而不再是 1 Setting操作。

2. options 相当于告诉观察者当发生改变时，你把我指定的变化值放到 change 字典中传过来。倘若你设置 options = 0，当发生变动时会触发回调方法，但是 change 字典中并没有存相应的值，唯一存的key就是 `NSKeyValueChangeKindKey` 告知你变动的类型，一般都是Setting。
3. 只要触发回调，change 字典必定有 `NSKeyValueChangeKindKey` 键以及对应的值，至于触发类型是`NSKeyValueChangeSetting`、`NSKeyValueChangeInsertion`或是其他，就需要用 `mutableArrayValueForKey` 这种方式取到值，然后在进行`add` `remove` 操作。

## Reference

[THObserversAndBinders](https://github.com/th-in-gs/THObserversAndBinders)




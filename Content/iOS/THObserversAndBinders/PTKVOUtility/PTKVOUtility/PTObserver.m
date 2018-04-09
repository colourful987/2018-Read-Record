//
//  PTObserver.m
//  PTKVOUtility
//
//  Created by pmst on 2018/4/9.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "PTObserver.h"
#import <objc/message.h>

typedef NS_ENUM(NSUInteger, PTObserverBlockArgumentsType) {
    PTObserverBlockArgumentsNone,
    PTObserverBlockArgumentsOldAndNew,
    PTObserverBlockArgumentsChangeDictionary,
};

@interface PTObserver()
@property(nonatomic, copy)NSString *keyPath;
@property(nonatomic, unsafe_unretained)id observedObject;
@property(nonatomic, copy) dispatch_block_t block;
@end

@implementation PTObserver


/**
 
 @param observedObject 被观察的对象
 @param keyPath 被观察对象某个属性的keyPath路径
 @param options 设置选项，changeDictionary中会返回对应的观察值
 @param block 处理代码块
 @param type 主要区分block的类型
 @return PTObserver 观察者实例，外部需要retain持有
 */
- (instancetype)initForObservedObject:(id)observedObject
                              keyPath:(NSString *)keyPath
                              options:(NSKeyValueObservingOptions)options
                                block:(dispatch_block_t)block
                            blockType:(PTObserverBlockArgumentsType)type {
    
    if (!observedObject || !keyPath || !block) {
        [NSException raise:NSInternalInconsistencyException format:@"check following parameters value, nil is invalid ! observedObject(%@) keyPath(%@) block(%@)", observedObject, keyPath, block];
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        self.keyPath = keyPath;
        self.observedObject = observedObject;
        self.block = block;
        
        [_observedObject addObserver:self forKeyPath:keyPath options:options context:(void *)type];
    }
    
    return self;
}

- (void)dealloc {
    if(_observedObject) {
        [self stopObserving];
    }
}

- (void)stopObserving {
    [_observedObject removeObserver:self forKeyPath:_keyPath];
    _block = nil;
    _keyPath = nil;
    _observedObject = nil;
}

#pragma mark - KVO Protocol Conformance
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    // 根据上下文context可以知道闭包参数类型，cast 到对应类型的block后调用
    switch ((PTObserverBlockArgumentsType)context) {
        case PTObserverBlockArgumentsNone:{
            ((PTObserverBlock)_block)();
        }
            break;
        case PTObserverBlockArgumentsOldAndNew:{
            id newValue = change[NSKeyValueChangeOldKey];
            id oldValue = change[NSKeyValueChangeNewKey];
            ((PTObserverBlockWithOldAndNew)_block)(oldValue, newValue);
        }
            break;
        case PTObserverBlockArgumentsChangeDictionary:{
            ((PTObserverBlockWithChangeDictionary)_block)(change);
        }
            break;
        default:
            break;
    }
}
#pragma mark - Block-based observer construction.
+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                                    block:(PTObserverBlock)block {
    return [[self alloc] initForObservedObject:observedObject
                                       keyPath:keyPath
                                       options:0
                                         block:(dispatch_block_t)block
                                     blockType:PTObserverBlockArgumentsNone];
}

+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                               valueBlock:(PTObserverBlockWithOldAndNew)block {
    return [[self alloc] initForObservedObject:observedObject
                                       keyPath:keyPath
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                         block:(dispatch_block_t)block
                                     blockType:PTObserverBlockArgumentsOldAndNew];
}

+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                                  options:(NSKeyValueObservingOptions)options
                              changeBlock:(PTObserverBlockWithChangeDictionary)block {
    return [[self alloc] initForObservedObject:observedObject
                                       keyPath:keyPath
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                         block:(dispatch_block_t)block
                                     blockType:PTObserverBlockArgumentsChangeDictionary];
}

#pragma mark - Target-Action observer construction.
static NSUInteger SelectorArgumentCount(SEL selector) {
    NSUInteger argumentCount = 0;
    
    const char *selectorStringCursor = sel_getName(selector);
    char ch;
    while((ch = *selectorStringCursor)) {
        if(ch == ':') {
            ++argumentCount;
        }
        ++selectorStringCursor;
    }
    
    return argumentCount;
}

+ (id)observerForObservedObject:(id)observedObject
                keyPath:(NSString *)keyPath
                 target:(id)target
                 action:(SEL)action {
    return [self observerForObservedObject:observedObject keyPath:keyPath options:0 target:target action:action];
}

+ (id)observerForObservedObject:(id)observedObject
                        keyPath:(NSString *)keyPath
                         target:(id)target
                    valueAction:(SEL)action {
    return [self observerForObservedObject:observedObject keyPath:keyPath options:0 target:target valueAction:action];
}

/**
 实现方式：依旧以 PTObserver 实例为中间件监听 `observedObject` 的 `keyPath` 键属性，
 构造一个 Block，内部若引用 target ,通过 objc_msgSend 调用SEL方法.
 */
+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                                  options:(NSKeyValueObservingOptions)options
                                   target:(id)target
                                   action:(SEL)action {
    __weak id wTarget = target;
    __weak id wObject = observedObject;
    
    dispatch_block_t block = nil;
    PTObserverBlockArgumentsType blockArgumentsKind;
    
    // 计算外部传入的 SEL 方法参数个数，决定构造的 block 类型
    NSUInteger actionArgCount = SelectorArgumentCount(action);
    
    switch (actionArgCount) {
        case 0: {
            block = [^{
                // strong reference, wheather it will cause retain cycle?
                id msgTarget = wTarget;
                if (msgTarget) {
                    // 保证值变更时给 msgTarget 发送 action 消息
                    ((void(*)(id, SEL))objc_msgSend)(msgTarget, action);
                }
            } copy];
            
            blockArgumentsKind = PTObserverBlockArgumentsNone;
        }
            break;
        case 1: {
            block = [^{
                id msgTarget = wTarget;
                if (msgTarget) {
                    // 保证值变更时给 msgTarget 发送 action 消息, 并告知被观察对象
                    ((void(*)(id, SEL, id))objc_msgSend)(msgTarget, action, wObject);
                }
            } copy];
            
            blockArgumentsKind = PTObserverBlockArgumentsNone;
        }
            break;
        case 2: {
            NSString *kp = [keyPath copy];
            block = [^{
                id msgTarget = wTarget;
                if (msgTarget) {
                    // 保证值变更时给 msgTarget 发送 action 消息, 并告知被观察对象以及被观察的keyPath
                    ((void(*)(id, SEL, id, NSString *))objc_msgSend)(msgTarget, action, wObject, kp);
                }
            } copy];
            
            blockArgumentsKind = PTObserverBlockArgumentsNone;
        }
            break;
        case 3: {
            NSString *kp = [keyPath copy];
            block = [^(NSDictionary *change){
                id msgTarget = wTarget;
                if (msgTarget) {
                    // 保证值变更时给 msgTarget 发送 action 消息, 并告知被观察对象、被观察的keyPath、change变更信息
                    ((void(*)(id, SEL, id, NSString *, NSDictionary *))objc_msgSend)(msgTarget, action, wObject, kp, change);
                }
            } copy];
            
            blockArgumentsKind = PTObserverBlockArgumentsChangeDictionary;
        }
        case 4: {
            NSString *kp = [keyPath copy];
            block = [^(id oldValue, id newValue){
                id msgTarget = wTarget;
                if (msgTarget) {
                    // 保证值变更时给 msgTarget 发送 action 消息, 并告知被观察对象、被观察的keyPath、change变更信息
                    ((void(*)(id, SEL, id, NSString *, id, id))objc_msgSend)(msgTarget, action, wObject, kp, oldValue, newValue);
                }
            } copy];
            
            blockArgumentsKind = PTObserverBlockArgumentsOldAndNew;
        }
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Your target's selector arguments incorrect. Five options for you, 1.(void) 2.(id observedObject) 3.(id observedObject, NSString *keyPath) 4.(id observedObject, NSString *keyPath, NSDictionary *change) 5.(id observedObject, NSString *keyPath, id oldValue, id newValue)"];
            break;
    }
    id ret = nil;
    
    if (block) {
        ret = [[self alloc] initForObservedObject:observedObject keyPath:keyPath options:options block:block blockType:blockArgumentsKind];
    }
    
    return ret;
}

+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                                  options:(NSKeyValueObservingOptions)options
                                   target:(id)target
                              valueAction:(SEL)action {
    __weak id wTarget = target;
    __weak id wObject = observedObject;
    
    dispatch_block_t block = nil;
    
    // 计算外部传入的 SEL 方法参数个数，决定构造的 block 类型
    NSUInteger actionArgCount = SelectorArgumentCount(action);
    
    options |= NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    switch (actionArgCount) {
        case 1: {
            
            block = [^(NSDictionary *change){
                // strong reference, wheather it will cause retain cycle?
                id msgTarget = wTarget;
                if (msgTarget) {
                    ((void(*)(id, SEL, id))objc_msgSend)(msgTarget, action, change[NSKeyValueChangeNewKey]);
                }
            } copy];
            
        }
            break;
        case 2: {
            block = [^(NSDictionary *change){
                id msgTarget = wTarget;
                if (msgTarget) {
                    
                    ((void(*)(id, SEL, id, id))objc_msgSend)(msgTarget, action, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
                }
            } copy];
            
        }
            break;
        case 3: {
            block = [^(NSDictionary *change){
                id msgTarget = wTarget;
                if (msgTarget) {
                    // 保证值变更时给 msgTarget 发送 action 消息, 并告知被观察对象以及被观察的keyPath
                    ((void(*)(id, SEL, id, id, id))objc_msgSend)(msgTarget, action, wObject, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
                }
            } copy];
            
        }
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Your target's selector arguments incorrect. Five options for you, 1.(id newValue) 2.(id oldValue，id newValue) 3.(id observedObject, id oldValue，id newValue) "];
            break;
    }
    id ret = nil;
    
    if (block) {
        ret = [[self alloc] initForObservedObject:observedObject keyPath:keyPath options:options block:block blockType:PTObserverBlockArgumentsChangeDictionary];
    }
    
    return ret;
}

@end

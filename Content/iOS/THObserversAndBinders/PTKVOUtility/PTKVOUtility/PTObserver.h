//
//  PTObserver.h
//  PTKVOUtility
//
//  Created by pmst on 2018/4/9.
//  Copyright © 2018 pmst. All rights reserved.
//  

#import <Foundation/Foundation.h>

/**
 三种类型block处理
 1. 只关心被观察对象的属性发生了改变
 2. 被观察对象的属性发生了改变，告知旧值和新值
 3. 被观察对象的属性发生了改变，设置 options 选项将变更信息存储到 change 字典中
 */
typedef void(^PTObserverBlock)(void);
typedef void(^PTObserverBlockWithOldAndNew)(id oldValue, id newValue);
typedef void(^PTObserverBlockWithChangeDictionary)(NSDictionary *change);

@interface PTObserver : NSObject

#pragma mark - Block-based observer construction.
+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                                    block:(PTObserverBlock)block;

+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                               valueBlock:(PTObserverBlockWithOldAndNew)block;

+ (instancetype)observerForObservedObject:(id)observedObject
                                  keyPath:(NSString *)keyPath
                                  options:(NSKeyValueObservingOptions)options
                              changeBlock:(PTObserverBlockWithChangeDictionary)block;

#pragma mark - Target-Action based observer construction.
/**
 Observer For observing value change that contain following infos
 
 SEL 参数必须符合如下三种格式
 1.selectorName(void)
 2.selectorName(id observedObject)
 3.selectorName(id observedObject, NSString *keyPath)
 4.selectorName(id observedObject, NSString *keyPath, NSDictionary *change)
 5.selectorName(id observedObject, NSString *keyPath, id oldValue, id newValue)
 */
+ (id)observerForObservedObject:(id)observedObject
                        keyPath:(NSString *)keyPath
                         target:(id)target
                         action:(SEL)action;


/**
 Observer For observing value change that only contain newValue, oldValue or both
 
 SEL 参数必须符合如下三种格式
 1.selectorName(id newValue)
 2.selectorName(id oldValue，id newValue)
 3.selectorName(id observedObject, id oldValue，id newValue)
 */
+ (id)observerForObservedObject:(id)observedObject
                        keyPath:(NSString *)keyPath
                         target:(id)target
                    valueAction:(SEL)action;

- (void)stopObserving;
@end

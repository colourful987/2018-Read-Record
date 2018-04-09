//
//  PTBinder.m
//  PTKVOUtility
//
//  Created by pmst on 2018/4/10.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "PTBinder.h"
#import "PTObserver.h"

@implementation PTBinder {
    PTObserver *_observer;
}


/**
 旨在被观察对象的属性发生变动时，联动的更改另一个对象的属性

 @param fromObject 被观察实例对象
 @param fromKeyPath 被观察实例对象的keyPath属性
 @param toObject 值更改时联动触发更改的实例对象
 @param toKeyPath 联动更改的keyPath属性
 @param transformationBlock 映射过程
 @return 绑定实例独享
 */
- (instancetype)initForBindingFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
                                toObject:(id)toObject keyPath:(NSString *)toKeyPath
                     transformationBlock:(PTBinderValueTransformerBlock)transformationBlock {
    self = [super init];
    
    if (self) {
        __weak id wToObject = toObject;
        NSString *tokp = [toKeyPath copy];
        PTObserverBlockWithChangeDictionary changeBlock;
        if (transformationBlock) {
            changeBlock = [^(NSDictionary *change){
                // 这里的change指被观察对象的keyPath属性 值变更信息
                [wToObject setValue:transformationBlock(change[NSKeyValueChangeNewKey]) forKey:tokp];
            } copy];
        } else {
            changeBlock = [^(NSDictionary *change){
                // 这里的change指被观察对象的keyPath属性 值变更信息
                [wToObject setValue:change[NSKeyValueChangeNewKey] forKey:tokp];
            } copy];
        }
        _observer = [PTObserver observerForObservedObject:fromObject keyPath:fromKeyPath options:NSKeyValueObservingOptionNew changeBlock:changeBlock];
    }
    
    return self;
}

- (void)stopBinding {
    [_observer stopObserving];
    _observer = nil;
}

+ (instancetype)binderFromObject:(id)fromObject
                         keyPath:(NSString *)fromKeyPath
                        toObject:(id)toObject
                         keyPath:(NSString *)toKeyPath {
    
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:nil];
}

+ (instancetype)binderFromObject:(id)fromObject
                         keyPath:(NSString *)fromKeyPath
                        toObject:(id)toObject
                         keyPath:(NSString *)toKeyPath
                valueTransformer:(NSValueTransformer *)valueTransformer {
    
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:^id(id value) {
                                  return [valueTransformer transformedValue:value];
                              }];
}

+ (instancetype)binderFromObject:(id)fromObject
                         keyPath:(NSString *)fromKeyPath
                        toObject:(id)toObject
                         keyPath:(NSString *)toKeyPath
                       formatter:(NSFormatter *)formatter {
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:^id(id value) {
                                  return [formatter stringForObjectValue: value];
                              }];
}

+ (instancetype)binderFromObject:(id)fromObject
                         keyPath:(NSString *)fromKeyPath
                        toObject:(id)toObject
                         keyPath:(NSString *)toKeyPath
             transformationBlock:(PTBinderValueTransformerBlock)transformationBlock {
    
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:transformationBlock];
}


@end

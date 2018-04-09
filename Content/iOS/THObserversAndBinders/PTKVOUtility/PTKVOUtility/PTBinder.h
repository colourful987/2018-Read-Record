//
//  PTBinder.h
//  PTKVOUtility
//
//  Created by pmst on 2018/4/10.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^PTBinderValueTransformerBlock)(id value);

/**
 场景应用：实例对象 A 的 A_property 属性值发生改变时，联动让实例对象 B 的 B_property 属性值也随之变动
 Binder 实现绑定 A 的 keyPath(A_property) 值变更事件到 B 的 keyPath(B_property)
 */
@interface PTBinder : NSObject

/**
 添加fromObject的fromkeyPath属性的观察者，变动时联动更改 toObject 的 toKeyPath 值.
 两者值始终保持一致.
 */
+ (instancetype)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
              toObject:(id)toObject keyPath:(NSString *)toKeyPath;

/**
 添加fromObject的fromkeyPath属性的观察者，变动时联动更改 toObject 的 toKeyPath 值.
 两者值映射关系为 `valueTransformer`.
 */
+ (instancetype)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
              toObject:(id)toObject keyPath:(NSString *)toKeyPath
      valueTransformer:(NSValueTransformer *)valueTransformer;

/**
 添加fromObject的fromkeyPath属性的观察者，变动时联动更改 toObject 的 toKeyPath 值.
 两者值映射关系为 `formatter`.
 */
+ (instancetype)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
              toObject:(id)toObject keyPath:(NSString *)toKeyPath
             formatter:(NSFormatter *)formatter;

/**
 添加fromObject的fromkeyPath属性的观察者，变动时联动更改 toObject 的 toKeyPath 值.
 两者值映射关系自定义，id value 为 fromObject 的 keyPath 属性 newValue
 */
+ (instancetype)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
              toObject:(id)toObject keyPath:(NSString *)toKeyPath
   transformationBlock:(PTBinderValueTransformerBlock)transformationBlock;

- (void)stopBinding;
@end

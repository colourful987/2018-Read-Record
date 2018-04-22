# 1. 从`yy_modelWithDictionary`构造方法说起

```objective-c
+ (instancetype)yy_modelWithDictionary:(NSDictionary *)dictionary {
    //... 略去类型判断
    
    /// 1.获取当前Model的类对象(Class Object)
    Class cls = [self class];
    
    /// 2.`_YYModelMeta` 内部定义了 `static CFMutableDictionaryRef cache;`
    /// key = cls指针地址 value = _YYModelMeta 实例
    /// _YYModelMeta 记录当前Model类的描述：包括实例变量 Ivar、属性Property和方法Method
    _YYModelMeta *modelMeta = [_YYModelMeta metaWithClass:cls];
    
    /// 3.由model类根据传入的dictionary取信息后决定类对象
    /// e.g. 定义基类 BaseUser，派生两个子类`LocalUser`和`RemoteUser`
    ///      如果dictionary中用户信息的 `key=localName`，则返回 `[LocalUser class]`
    ///      如果 `key=remoteName`，则返回 `[RemoteUser class]`
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls = [cls modelCustomClassForDictionary:dictionary] ?: cls;
    }
    
    /// 4. 生成model类的实例对象，可认为在堆上分配一块内存给one指针。
    ///    `yy_modelSetWithDictionary`传入值进行映射赋值
    NSObject *one = [cls new];
    if ([one yy_modelSetWithDictionary:dictionary]) return one;
    return nil;
}
```

**代码注释：**

1. 我们知道方法中隐藏了两个变量，一个是 self，另一个是 SEL，其中 self 在实例方法（`-` 打头）和类方法（`+` 打头）分别表示**实例**的指针和**类对象**的指针，`+(Class)class` 和 `-(Class)class` 的实现也不同，前者是返回self（类对象的地址）；后者间接调用 `object_getClass(self)`，这个方法内部实现是取 `self` 的 isa 指针，其实也是类对象起始地址。
2. `_YYModelMeta` 内部定义了 `static CFMutableDictionaryRef cache;`，key = cls指针地址 value = _YYModelMeta 实例， _YYModelMeta 记录当前Model类的描述：包括实例变量 Ivar、属性Property和方法Method，具体见下面小节
3. 场景：我们的Model 持有一个对用户的描述类 `BaseUser` ，由于它可能是 `LocalUser` 或是 `RemoteUser` ，这由传过来的数据源决定，如果传过来的字典数据中是 `{"remoteName:{// 用户描述}"}`，那么这就是一个远程用户；而如果数据是 `{"localName:{// 用户描述}"}`，那么这就是一个本地用户，而我们的Model为了兼容这两种情况，内部使用 `BaseUser *user` 来持有它，`modelCustomClassForDictionary` 所要做的是，如果解析发现字典包含 remoteName ，那么我们就应该用 `[LocalUser class]` 来解析，相反则是 `[RemoteUser class]`
4. YYModel 的实现机制：1.为我们的Model分配一块内存(`[cls new]`)，然后根据存储的类对象描述 `modelMeta`，将 `dictionary` 数据源一一映射写入内存中，具体请见下文，这里举个例子：

```objective-c
/// json 数据，描述一个人
{ 
"firstName":"John" , 
"lastName":"Doe",
"age":24
}

/// 为此我们定义的 Person Model如下：
@interface Person : NSObject
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, assign) int age;
@end
@implementation YYBook
@end
```
**硬编码方式 json 数据-->实例对象的过程**：读入json字符串数据流，利用苹果提供的API生成字典（建议自己写一个 JSON Parser）；现在我们使用 `Person *p = [Person new]` 生成一个实例对象，其中内容都是初始值，不是nil就是0；现在我们所要做的是从字典中取值，键Key就是json中的 "firstName"、"lastName" 和 "age"，然后分别调用 `p.firstName = jsonDict["firstName"]` 方式复制。

**动态解析:** 大前提是我们定义的 Model 必须和 JSON 数据格式一一对应，属性名就是 JSON 数据中的键名称，实现原理很简单，当我们读入 person 数据源时，遍历字典内容，获取键名称 `firstName`，值为`John`，然后 `[p setFirstName:@"John"]` 就ok了：

```
/// 伪代码如下：
Person *p = [Person new];

for key in jsonDict.allKeys {
  id value = jsonDict[key];
  SEL setterMethod = NSSelectorFromString("set"+key)
  [p performSelector:setterMethod with:value];
}
```
这里没有考虑属性的类型判断，自定义类型和Ivar实例变量又该如何赋值？要考虑的东西非常多。

# 2. `_YYModelMeta` 记录Class Object类对象信息

# 3. `yy_modelSetWithDictionary` 动态解析赋值




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

> 要点：应用生命周期内，每个类有且仅存在一个类对象（Class Object）和元类对象（MetaClass Object），前者是对实例对象的描述，包括实例变量、属性和实例方法('-'标识)；后者是对类对象的描述，包含类属性和类方法（`+`标识）。说到这里不免要问：1.实例对象的描述和类对象的描述如何生成的呢？2.应用程序又是何时把这两份描述加载到内存生成对象的类对象和元类对象？第一点：我认为在编译阶段就能获取到系统定义类(如NSObject，UIView)和自定义类（User，Person等自己定义的数据结构）的描述，要知道编译阶段要经过Lexer词法分析--> 语法解析生成 AST --> 语义分析(静态语法检测)等多个步骤，其中从 AST 抽象语法树中就可以获取每个类的描述，生成类对象的Image和元类对象的Image————其实就是描述，然后在应用启动时加载进来。 以上是我的猜想，若有不对之处请指正。

应用生命周期内，YYModel 使用字典数据结构保存我们所有用到的 Model 类的描述，key=类对象地址，value=YYModelMeta实例，YYModelMeta实例包含了对Model类的描述，后面会详细讲解。Note: 这里采用了懒加载的方式加载Model类对象的 YYModelMeta 实例，保证仅生成一次：

```objective-c
+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    
    // 1. 生成我们的缓存池 cache 字典
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    
    // 2. 尝试用key=cls地址 从cache字典取对象的描述
    _YYModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    
    // 3. 若未取到或需要更新 则重新创建一个
    if (!meta || meta->_classInfo.needUpdate) {
       // 4. 核心方法：生成一个 YYModelMeta 实例描述类对象：包括属性，Ivar和方法
        meta = [[_YYModelMeta alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            // 5. 将生成的YYModelMeta实例保存到字典中，方便之后获取
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}
```

这里着重讲**步骤四：**

```objective-c
///  _YYModelMeta implementation

- (instancetype)initWithClass:(Class)cls {
  /// 1. 生成 YYClassInfo 尼玛 怎么封装一层又一层！
  YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:cls];
  
  /// 2. 获取black list 和 white list，由Model自已定义这两个名单，省去代码
  NSSet *blacklist = nil;
  // ...
  NSSet *whitelist = nil;
  // ...
  
  /// 3. 获取容器类(诸如 NSArray NSDictionary, NSSet)中元素的类型
  ///    举例： @property (nonatomic, strong) NSArray *users; 
  ///           那么返回@{@"users" : YYBaseUser.class} 表明数组
  ///           元素类型为 YYBaseUser.class
  NSDictionary *genericMapper = nil;
  if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
      genericMapper = [(id<YYModel>)cls modelContainerPropertyGenericClass];
      if (genericMapper) {
          NSMutableDictionary *tmp = [NSMutableDictionary new];
          [genericMapper enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
              if (![key isKindOfClass:[NSString class]]) return;
              // ❤️ object_getClass 底层实现是获取obj的isa指针
              //    由于obj为类对象，所以这里获取的是元类对象
              //    处理用户没有返回Class类型，而是字符串类型的类名
              Class meta = object_getClass(obj);
              if (!meta) return;
              if (class_isMetaClass(meta)) {
                  tmp[key] = obj;
              } else if ([obj isKindOfClass:[NSString class]]) {
                  Class cls = NSClassFromString(obj);
                  if (cls) {
                      tmp[key] = cls;
                  }
              }
          }];
          genericMapper = tmp;
      }
  }
  
  /// 4. 创建并填充所有属性Property的描述信息
  NSMutableDictionary *allPropertyMetas = [NSMutableDictionary new];
  YYClassInfo *curClassInfo = classInfo;
  while (curClassInfo && curClassInfo.superCls != nil) { 
      // 递归解析superClass，忽略NSObject和NSProxy根类
      // 生成属性的元数据描述，源码解释见下：
      _YYModelPropertyMeta *meta = [_YYModelPropertyMeta metaWithClassInfo:classInfo
                                                              propertyInfo:propertyInfo   generic:genericMapper[propertyInfo.name]];
      // ...
  }
  // 将生成的所有属性Meta信息都存储到 _allPropertyMetas 数组中保存起来
  if (allPropertyMetas.count) _allPropertyMetas = allPropertyMetas.allValues.copy;
  
  /// 5. 创建映射mapper，就如之前说的 json 数据的键是缩写的 ln，而属性是全拼`lastName`，这里要有个映射。
  ///   这里会遍历 _allPropertyMetas，对于有映射的 PropertyMeta 绑定 _mappedToKey
  NSMutableDictionary *mapper = [NSMutableDictionary new];
  NSMutableArray *keyPathPropertyMetas = [NSMutableArray new];
  NSMutableArray *multiKeysPropertyMetas = [NSMutableArray new];
  if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
      NSDictionary *customMapper = [(id <YYModel>)cls modelCustomPropertyMapper];
      [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *mappedToKey, BOOL *stop) {
        // ...
      }]
  }
  [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString *name, _YYModelPropertyMeta *propertyMeta, BOOL *stop) {
    propertyMeta->_mappedToKey = name;
    propertyMeta->_next = mapper[name] ?: nil;
    mapper[name] = propertyMeta;
  }];
  
  // 6. 将上述得到的信息存储到 YYModelMeta 的实例变量中保存起来
  if (mapper.count) _mapper = mapper;
  if (keyPathPropertyMetas) _keyPathPropertyMetas = keyPathPropertyMetas;
  if (multiKeysPropertyMetas) _multiKeysPropertyMetas = multiKeysPropertyMetas;
  
  _classInfo = classInfo;
  _keyMappedCount = _allPropertyMetas.count;
  _nsType = YYClassGetNSType(cls);
  _hasCustomWillTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomWillTransformFromDictionary:)]);
  _hasCustomTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)]);
  _hasCustomTransformToDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)]);
  _hasCustomClassFromDictionary = ([cls respondsToSelector:@selector(modelCustomClassForDictionary:)]);
  return self;
}
```
## 2.1 `YYClassInfo` 记录类信息：属性、实例变量、方法以及递归superCls的上述三个信息
```objective-c
- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int methodCount = 0;
    /// 1. 生成 Method 通常只是为了得到getter setter方法 但是实际我们还有自定义方法
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            /// 1.1 将runtime的一套对method的描述转成自定义
            YYClassMethodInfo *info = [[YYClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    
    /// 2. 属性=实例变量+getter/setter 方法
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            /// 2.1
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    /// 3. 实例变量：包括属性的实例变量+一般声明的ivar
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            YYClassIvarInfo *info = [[YYClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}
```

> 这里涉及 runtime 的定义类型 `Method`，`objc_property_t` 和 `Ivar` ，YYModel自己又封装了一层。

## 2.2 `_YYModelPropertyMeta` 属性元数据

`_YYModelPropertyMeta` 是对 `YYClassPropertyInfo` 的二次修改封装，因为实际的 Property 可能要和JSON有一个映射。

```objective-c
+ (instancetype)metaWithClassInfo:(YYClassInfo *)classInfo propertyInfo:(YYClassPropertyInfo *)propertyInfo generic:(Class)generic {
    
    // support pseudo generic class with protocol name
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    
    // 可以看到实际就是把YYClassPropertyInfo Map到 _YYModelPropertyMeta 但是还是有修改的
    _YYModelPropertyMeta *meta = [self new];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;
    
    if ((meta->_type & YYEncodingTypeMask) == YYEncodingTypeObject) {
        meta->_nsType = YYClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = YYEncodingTypeIsCNumber(meta->_type);
    }
    if ((meta->_type & YYEncodingTypeMask) == YYEncodingTypeStruct) {
        /*
         It seems that NSKeyedUnarchiver cannot decode NSValue except these structs:
         */
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    meta->_cls = propertyInfo.cls;
    
    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    } else if (meta->_cls && meta->_nsType == YYEncodingTypeNSUnknown) {
        meta->_hasCustomClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    
    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }
    
    if (meta->_getter && meta->_setter) {
        /*
         KVC invalid type:
         long double
         pointer (such as SEL/CoreFoundation object)
         */
        switch (meta->_type & YYEncodingTypeMask) {
            case YYEncodingTypeBool:
            case YYEncodingTypeInt8:
            case YYEncodingTypeUInt8:
            case YYEncodingTypeInt16:
            case YYEncodingTypeUInt16:
            case YYEncodingTypeInt32:
            case YYEncodingTypeUInt32:
            case YYEncodingTypeInt64:
            case YYEncodingTypeUInt64:
            case YYEncodingTypeFloat:
            case YYEncodingTypeDouble:
            case YYEncodingTypeObject:
            case YYEncodingTypeClass:
            case YYEncodingTypeBlock:
            case YYEncodingTypeStruct:
            case YYEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            } break;
            default: break;
        }
    }
    
    return meta;
}
```

## 2.3 `mapper、keyPathPropertyMetas、multiKeysPropertyMetas`



# 3. `yy_modelSetWithDictionary` 动态解析赋值
实现基本原理上面已经提及，即 JSON 的key经过我们自己的mapper映射之后就是属性或者Ivar名称，然后把value赋值，这里涉及到映射，类型判断，递归等，核心代码其实

```objective-c
- (BOOL)yy_modelSetWithDictionary:(NSDictionary *)dic {
  // 省略异常情况处理....
  
  // 1. ❤️上下文实际就是 类描述+实例内存地址+json数据源
  //      后面要做的就是根据json数据源根据类描述，把值填充到实例的内存中
  ModelSetContext context = {0};
  context.modelMeta = (__bridge void *)(modelMeta);
  context.model = (__bridge void *)(self);
  context.dictionary = (__bridge void *)(dic);
  
  
  if (modelMeta->_keyMappedCount >= CFDictionaryGetCount((CFDictionaryRef)dic)) {
      // 2. ❤️核心方法 `ModelSetWithDictionaryFunction`
      //       以及 `ModelSetWithPropertyMetaArrayFunction`
      CFDictionaryApplyFunction((CFDictionaryRef)dic, ModelSetWithDictionaryFunction, &context);
      if (modelMeta->_keyPathPropertyMetas) {
          CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas,
                               CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)),
                               ModelSetWithPropertyMetaArrayFunction,
                               &context);
      }
      if (modelMeta->_multiKeysPropertyMetas) {
          CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas,
                               CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)),
                               ModelSetWithPropertyMetaArrayFunction,
                               &context);
      }
  } else {
      CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas,
                           CFRangeMake(0, modelMeta->_keyMappedCount),
                           ModelSetWithPropertyMetaArrayFunction,
                           &context);
  }
  
  if (modelMeta->_hasCustomTransformFromDictionary) {
      return [((id<YYModel>)self) modelCustomTransformFromDictionary:dic];
  }
  return YES;
}
```
上面用了 Core Foundation 的字典和数据接口，即对字典每个key-value pair应用 `ModelSetWithDictionaryFunction` 方法，对数组每个元素应用 `ModelSetWithPropertyMetaArrayFunction` 方法。 这么做可能就是为了效率吧。

```objective-c
static void ModelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context) {
    ModelSetContext *context = _context;
    __unsafe_unretained _YYModelMeta *meta = (__bridge _YYModelMeta *)(context->modelMeta);
    __unsafe_unretained _YYModelPropertyMeta *propertyMeta = [meta->_mapper objectForKey:(__bridge id)(_key)];
    __unsafe_unretained id model = (__bridge id)(context->model);
    while (propertyMeta) {
        if (propertyMeta->_setter) {
            // ❤️ 核心方法：可理解为做数据派发，将值赋值给对应的实例变量
            // 内部采用了 objc_msgSend 方法进行消息发送赋值
            ModelSetValueForProperty(model, (__bridge __unsafe_unretained id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    };
}
```


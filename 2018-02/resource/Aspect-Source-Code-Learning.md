### 1. 具体和抽象
具体：客观存在着的或在认识中反映出来的事物的整体，是具有多方面属性、特点、关系的统一；
抽象：从具体事物中被抽取出来的相对独立的各个方面、属性、关系等。

以 Person 为例：“pmst”，“numbbbbb”，“MM”等都是客观存在的，称之为具体；然后我们抽取共同的特性：姓名，性别，年龄和介绍自己等（当然这是极小、极小的一部分）。

### 2. C 语言抽象的雏形
先用 C 语言抽象，实现如下:
```
typedef struct Person Person;

typedef void (*Method)(Person *my_self);

typedef struct Person {
    char name[12];
    int age;
    int sex;
    Method behavior1; // 行为1
} Person;


void selfIntroducation(Person *my_self) {
    printf("my name is %s,age %d,sex %d\n",my_self->name,my_self->age,my_self->sex);
}

int main(int argc, const char * argv[]) {
    // 1
    Person *pmst = (Person *)malloc(sizeof(Person));
    // 1.1
    strcpy(pmst->name, "pmst");
    pmst->age = 18;
    pmst->sex = 0;
    // 2
    pmst->behavior1 = selfIntroducation;
    // 3
    pmst->behavior1(pmst);

    return 0;
}
```
1.  `int`，`float`，`struct` 等类型在编译之后转变成对内存地址的访问，比如 `1` 中的 pmst 指针在调用 `malloc` 方法后返回分配的地址为 `0x12345678`，会标识占 `sizeof(Person)` 个字节；`pmst->age = 18` 其实是对 0x12345678  偏移 12 字节内存的赋值，占4个字节；
2. 函数在编译之后放置在代码段，入口为函数指针；
3. `pmst->behavior1(pmst);` 先取到 0x12345678 偏移 20 字节内存的值————函数指针，然后 call 命令调用

> 编译之后代码都变成了对内存地址的访问，称之为静态绑定；那么该如何实现 Runtime 运行时的动态访问呢？比如在UI界面上（ps:Terminal那种古老的输入输出方式也是OK的）输入一个类的名称以及调用方法名称，紧接着我们要实例化一个该类的对象，然后调用方法。

### 3. C 语言实现动态性

想要运行时随心所欲地将**抽象**转变成***具体**，就需要在内存中保存一份对抽象的描述，这里的描述并非指 `typedef struct Person {...}Person` 定义 ———— 这是静态的，而是开辟一块内存加载一份 json 抽象描述：
```
{
  "Name": "Person",
  "VariableList":[
    {
      "VarName":"name",
      "Type":"char[]",
      "MemorySize":12,
    },
    {
      "VarName":"age",
      "Type":"int",
      "MemorySize":4,
    },
    {
      "VarName":"sex",
      "Type":"int",
      "MemorySize":4,
    },
  ],
  "MethodList":[
    {
      "name":"selfIntroducation",
      "methodAddress":0x12345678
    },
  ]
}
```
关于这串json描述，可以是在编译阶段生成的，运行时使用 `char *description` 加载到堆内存上，需要时通过对应的 Key 取到 Value：例如 Key=Name 可以取到类名，Key=VariableList 可以取到变量列表，Key=MethodList 可以取到方法列表。这里可能需要有个小小的Parser解析器。

倘若每次用到时就要进行一次 `char *description` 信息 parser 解析，性能这关都过不去，正确做法是解析成某个数据结构，保存到堆内存中：
```
// 伪代码如下
typedef struct Variable {
  char *name,
  char *type,
  int memorySize
}Variable;

typedef struct Method {
  char *name,
  void (*address)(void *my_self);// 显然这里多参传入 当然这些暂时不考虑
}Method;

typedef struct Class {
  char *className,
  /// Variable List 是一个数组 类型为 Variable
  Variable *variableList,
  /// Method List 也是一个数组 类型为 Method
  Method *methodList
}
```
上述是最简单的抽象定义，现在我们将解析json信息，然后分配内存填充信息（抽象->具体）的过程，首先 Class 是一个抽象概念，抽象出类名、变量列表和方法列表等信息，但此刻我们开辟了一块内存填充信息———— 客观存在了，称之为对象（通常我们称之为class object，类对象）

```
//////////////伪代码如下/////////////////
//////////////////////////////////////////
// parse person json proccess get result
///////////////////end////////////////////

// 分配一块内存
Class *personClsObject = (Class *)malloc(sizeof(Class));

strcpy(personClsObject->className, "Person");

personClsObject->variableList = (Variable *)malloc(sizeof(Variable) * 3);// 有3个变量

Variable *nameVar = (Variable *)malloc(sizeof(Variable));
strcpy(nameVar->name, "name");
strcpy(nameVar->type, "char[]");
nameVar->memorySize = 12;
//... ageVar & sexVar 生成

personClsObject->variableList[0] = nameVar;
personClsObject->variableList[1] = ageVar;
personClsObject->variableList[2] = sexVar;

// 同理生成一个个Method 然后填充到 personClsObject->methodList;
```
你、我、他是客观存在的称之为对象，进一步抽象出了姓名、性别和年龄三个方面，使用 `struct Person` 结构体定义，之前说了编译之后不存在所谓的结构体，都会转而变成对内存地址的访问；我们换了种思路，又抽象出了一个 Class 结构体，然后分配一块具体客观存在的内存保存信息，即 `personClsObject` 类对象(class object)，然后将所有变量信息存储到`variableList`，方法信息存储到 `methodList`。

### 1. 具体和抽象
具体：客观存在着的或在认识中反映出来的事物的整体，是具有多方面属性、特点、关系的统一；
抽象：从具体事物中被抽取出来的相对独立的各个方面、属性、关系等。

以 Person 为例：“pmst”，“numbbbbb”，“MM”等都是客观存在的，称之为具体；然后我们抽取共同的特性：姓名，性别，年龄和介绍自己等（当然这是极小、极小的一部分）。

先用 C 语言抽象:
```
typedef struct Person Person;

typedef void (*Method)(Person *my_self);

typedef struct Person {
    char name[10];
    int age;
    int sex;
    Method behavior1; // 行为1
} Person;


void selfIntroducation(Person *my_self) {
    printf("my name is %s,age %d,sex %d\n",my_self->name,my_self->age,my_self->sex);
}

int main(int argc, const char * argv[]) {
    Person *pmst = (Person *)malloc(sizeof(Person));
    strcpy(pmst->name, "pmst");
    pmst->age = 18;
    pmst->sex = 0;
    pmst->behavior1 = selfIntroducation;
    pmst->behavior1(pmst);

    return 0;
}
```
1.  `int`，`float`，`struct` 等类型在编译之后转变成对内存地址的访问，比如 `1` 中的 pmst 指针在调用 `malloc` 方法返回值为  0x12345678，会标识占 `sizeof(Person)` 个字节；`pmst->age = 18` 其实是对 0x12345678  偏移 12 字节内存的赋值，占4个字节；
2.  函数在编译之后放置在代码段，入口为函数指针；
3.  `pmst->behavior1(pmst);` 先取到 0x12345678 偏移 20 字节内存的值————函数指针，然后 call 命令调用



> 编译之后代码都变成了对内存地址的访问，称之为静态绑定；那么该如何实现 Runtime 运行时的动态访问呢？比如在UI界面上（ps:Terminal那种古老的输入输出方式也是OK的）输入一个类的名称以及调用方法名称，紧接着我们要实例化一个该类的对象，然后调用方法。

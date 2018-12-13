zombie设计的目的：向一个已经释放掉的实例变量发送消息会导致崩溃，那么如何监察这种情况发生呢？是哪里发送消息给一个已经释放掉的对象呢？ 

这时候可以在debug调试面板中开启Zombie模式，此后实例对象将不再释放。在解释何为实例对象不释放之前，先理解下实例对象，`objc_object` 就是一个指针isa，指向class object对象，后面紧跟实例变量，这个是分配在堆上面的，核心把这个isa指向另外一个`Zombie` 的 class object 就可以了，当然这样还不行，因为我们所有的类都指向这个Zombie class object 就没法区分了，所以我们会复制 `Zombie` 类，然后把名字改成以`Zombie_`前缀加上自身类名的新类；我们还需要在 Zombie 中监察当有消息发过来时，告知这个类实际已经被dealloc了。

```
// self 为实例变量，object_getClass 取到 class object，生命周期中会存在一个
Class cls = object_getClass(self);

const char *clsName = class_getName(cls); 

// 以Zombie为前缀重命名
char zombieClsName[10];
strcat(zombieClsName, "_NSZombie_");
strcat(zombieClsName,clsName);

Class zombieCls = objc_lookUpClass(zombieClsName);

if (!zombieCls) {

Class baseZombieCls = objc_lookUpClass("_NSZombie_");

zombieCls = objc_duplicateClass(baseZombieCls,zombieClsName, 0);

}
objc_destructInstance(self);

object_setClass(self, zombieCls); // 这里书中有误
```

然后在 Zombie 类中 我们需要在 `resolveInstanceMethod` 中直接抛出异常，因为这个类本来就应该释放掉的，但是居然有人给它发送消息！

```

int string_has_prefix(const char *str1, char *str2) {
 if(str1 == NULL || str2 == NULL)
    return -1;
    
  int len1 = strlen(str1);
  int len2 = strlen(str2);
  
  if((len1 < len2) || (len1 == 0 || len2 == 0))
    return -1;
    
  char *p = str2;
  int i = 0;
  while(*p != '\0')
  {
    if(*p != str1[i])
      return 0;
    p++;
    i++;
  }
  return 1;
}


+ (BOOL)resolveInstanceMethod:(SEL)selector {

Class cls = object_getClass(self); 
const char *clsName = class_getName(cls);

if (string_has_prefix(clsName, "_NSZombie_") { 
  const char *selectorName = sel_getName(selector);
  NSLog("*** -[%s %s]: message sent to deallocated instance %p", originalClsName, selectorName, self);
}
  
  abort();
}
```
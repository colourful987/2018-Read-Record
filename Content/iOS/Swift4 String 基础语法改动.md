# Swift4 String 基础语法改动

## 1. String 数据结构改回集合
String 类型改回 Swift2.0 的集合设计，自身就是一个数组，元素类型为 Character，当然内部还是有编码区分的，`unicodeScalars, utf16 和 utf8`，更多关于编码知识，可以回顾[字符编码演变史](https://www.jianshu.com/p/9ee21d13144e)一文。

```Objective-c
/// 之前用法
var sentence = "Never odd or even"
for character in sentence.characters {
  print(character)
}

/// Swift 4
let sentence = "Never odd or even"
for character in sentence {
  print(character)
}
```

## 2. 字符计数
计算String字符串内部的字符个数方式稍有改动，可以直接取 `count`，应该默认是unicode编码吧，但是想知道其他编码下占几个字符和之前一样

```Objective-c
/// 之前用法
spain.characters.count  // 6 

// Swift 4
let spain = "España"
spain.count // 6

//  UTF8 编码字符计数
spain.utf8.count                   // 7
```

## 3. 新增了 `Substring` 类型
新增了 `Substring` 类型，Swift4.0中截取字符串得到新的字符串类型不再是 String 类型，而是 Substring 类型，它遵循`StringProtocol`协议，意味着很多方法和`String`是一致的；另外很重要的一点：**Substring 内容其实是指向原始字符串的内存**，换句话说，它并没有copy一份新的字符串，而是共享了原始字符串，意味着它是**临时的**，一旦原始字符串内存被释放掉，那么这个substring也不复存在。

> 官方文档说明：substrings aren’t suitable for long-term storage – because they reuse the storage of the original string the entire original string must be kept in memory as long as any of its substrings are being used.

Swift4中，截取string成substring的方式是使用下标方式，即 `[指定截取起始和结束]`，例子如下：

```Objective-c
let template = "<<<Hello>>>"
let indexStartOfText = template.index(template.startIndex, offsetBy: 3)
let indexEndOfText = template.index(template.endIndex, offsetBy: -3)

// Swift 4
let substring1 = template[indexStartOfText...]  // "Hello>>>"

// Swift 3 deprecated
// let substring1 = template.substring(from: indexStartOfText)

// Swift 4
let substring2 = template[..<indexEndOfText]    // "<<<Hello"

// Swift 3 deprecated
// let substring2 = template.substring(to: indexEndOfText)

// Swift 4
let substring3 = template[indexStartOfText..<indexEndOfText] // "Hello"

// Swift 3 deprecated
// let substring3 = template.substring(with: indexStartOfText..<indexEnd
```

使用 substring 重新实例化一个String很简单：

```Objective-c
let string1 = String(substring1)
```

如果不想用下标截取字符串，也可以使用`prefix`和`suffix`

```
let digits = "0123456789"
let index4 = digits.index(digits.startIndex, offsetBy: 4)

// The first of each of these examples is preferred
digits[...index4]              // "01234"
digits.prefix(through: index4)  

digits[..<index4]              // "0123"
digits.prefix(upTo: index4)     

digits[index4...]              // "456789"
digits.suffix(from: index4)
```

## 4. 关于字符串多行显示

```
let verse = """
    To be, or not to be - that is the question;
    Whether 'tis nobler in the mind to suffer
    The slings and arrows of outrageous fortune,
    Or to take arms against a sea of troubles,
    """
```

可以使用 `\` 来略过换行

```
let singleLongLine = """
    This is a single long line split \
    over two lines by escaping the newline.
    """
```
## 5. Objc Swift Functional Programming 解析器一节例子更新 

注意点只有一个 `dropFirst()` 返回的是 `Substring` 类型，所以这里使用前文说到的`String()`转成字符串类型。

```
struct Parser<Result> {
    typealias Stream = String
    let parser:(Stream)->(Result, Stream)?
}

extension Parser {
    func run(_ string:String)->(Result, String)? {
        guard let (result, remainder) = parser(string) else {
            return nil
        }
        return (result, String(remainder))
    }
}

func character(matching condition:@escaping(Character)->Bool) -> Parser<Character> {
    return Parser(parser: { input in
        guard let char = input.first, condition(char) else { return nil}
        return (char, String(input.dropFirst()))
    })
}

let one = character{$0 == "1"}
print(one.run("123"))
```
## Reference

* [Updating Strings For Swift 4](https://useyourloaf.com/blog/updating-strings-for-swift-4/)
* [Swift 字符串一口闷](https://www.jianshu.com/p/956665e3a0e5)
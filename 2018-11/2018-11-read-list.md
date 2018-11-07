> Theme: 编译器/解释器
> Source Code Read Plan:
* [x] 实现一个计算器解释器；
* [x] 实现pascal解释器 ；
* [ ] 指标平台公示解释器；
* [ ] AST source to source 解释成诸如C语言的其他形式，或者是自定义一门标记语言解释成OC的button或是html的元素；
* [ ] 编译器的话，可能就是要基于 source to source 到汇编或者C代码，再用对应的编译器编译成可执行文件。

# 2018/11/01
开箱....



> Theme: 编译器/解释器
> Source Code Read Plan:
* [x] 实现一个计算器解释器；
* [x] 实现pascal解释器 ；
* [ ] 指标平台公示解释器；
* [ ] AST source to source 解释成诸如C语言的其他形式，或者是自定义一门标记语言解释成OC的button或是html的元素；
* [ ] 编译器的话，可能就是要基于 source to source 到汇编或者C代码，再用对应的编译器编译成可执行文件。

# 2018/11/01
开箱....

# 2018/11/03
ruslanspivak 的解释器系列文章只更新到14节，关于procedure的语法和形参等都没有讲解，其实就是有关函数和栈堆的使用问题，这些之后就自己摸索了，关于14节比较完整的demo源码我更新到14-1。

# 2018/11/04
Imp a new language：**ECHO**。

实现Lisp解释器练手，实现最基础的 `(+ 3 (- 4 2))`表达式，但是我对atom expr感觉领悟有些不足，果然光看教程码和独立自己实现一个其他语言的解释器差距有点大。

源码我放在Content/iOS/Pascal Interpreter/LISP_INTERPRETER目录下，就当个demo看。



# 2018/11/05
校对了几篇swiftgg译文，感觉自己还是英文渣渣。



# 2018/11/06

实现 **ECHO** 语言的基础语法：

```echo
Simple Grammer:

program: statement_list

statement_list: statement
                | (statement)+

statement: declaration_statement  
           | assignment_statement
           | empty

declaration_statement: var ID COLON type_spec # e.g var x: int

assignment_statement: variable ASSIGN expr

expr : term ((PLUS | MINUS) term)*

term : factor ((MUL | DIV) factor)*

factor : PLUS factor
       | MINUS factor
       | INTEGER_CONST
       | REAL_CONST
       | LPAREN expr RPAREN
       | variable

variable: ID

emprty : 

----------- code example -----------
var x:int
var y:int
var z:int
x = 12 + 2
y = 2*x - 1
z = x + (y - 3 * x)
------------------------------------
```
# 2018/11/07
完成了 ECHO LANGUAGE 的 Token Lexer AST Parser 编写，自己实现一门语言只有真正code的时候才发现真的不容易，maybe是因为我还处于入门的边缘，目前的境况就像那扇大门漏出了一丝缝隙，缝隙中透出一束光，让人想继续打开。
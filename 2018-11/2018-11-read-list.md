> Theme: 编译器/解释器
> Source Code Read Plan:
* [x] 实现一个计算器解释器；
* [x] 实现pascal解释器 ；
* [x] 实现一门简单的语言 ECHO；
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

# 2018/11/08
已实现 “ECHO” 的最基础语法，目前仅支持 declaration statement 和 assignment statement 两种：
* `var x:int`
* `z = x + (y - 3 * x)`

另外我新建了一个 Compiler Interpreter 主题的目录，[传送门](https://github.com/colourful987/2018-Read-Record/tree/master/Content/Compiler%20Interpreter)。

接下来的目标是增加基础语法：    
1. `if-else if - else`
2. `for(;;){statement}`
3. `while(condition){ statement}`



# 2018/11/09
添加了 `if-else` 语句的 Token (大括号`{}`/if/else/`> == <`)、Lexer 添加对上述Token的解析，以及 AST 支持条件语句的node，这里我构建的方式其实不是很好，整个`if-else` 作为condBlock代码块，而每一个条件+处理封装成了 CondBranchDecl，条件语句可以有多个CondBranchDecl，所以数据结构用了数组，最后是Condition条件，例如 `x+1 > 2`，这个和Assign赋值表达式很像，如下：

```
# if-else condition declaration
class CondBlock(AST):
    def __init__(self):
        self.condBranchs = []

# condition + expr()
# note: now the block node is program
class CondBranchDecl(AST):
    def __init__(self,condition_node,block_node):
        self.condtion = condition_node
        self.block = block_node

# expr </==/> expr
class Condition(AST):
    def __init__(self,left,op,right):
        self.left = left
        self.op = op
        self.right = right
```

NodeVisitor代码也基本实现，遍历所有条件branch时，满足第一个执行后退出：

```
def visit_CondBlock(self,node):

    for condBranch in node.condBranchs:
        self.visit(condBranch) # TODO must has break

def visit_CondBranchDecl(self,node):
    cond_node = node.condition_node
    block_node = node.block
    value = self.visit(cond_node)
    if value != 0 :
        self.visit(block_node)

def visit_Condition(self,node):
    op = node.op
    leftValue = self.visit(node.left)
    rightValue = self.visit(node.right)

    ret = 0
    if op.type == GREATER:
        ret = leftValue > rightValue
    elif op.type == EQUAL:
        ret = leftValue == rightValue
    elif op.type == LESS:
        ret = leftValue < rightValue

    return ret
```
明天调试代码。
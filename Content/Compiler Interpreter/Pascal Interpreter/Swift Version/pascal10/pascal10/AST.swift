//
//  AST.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation

class AST {
    var name="AST"
}

// 一元操作符
class UnaryOp:AST {
    var op:Token
    var token:Token
    var expr:AST
    
    init(op:Token,token:Token,expr:AST) {
        self.op = op
        self.token = token
        self.expr = expr
        super.init()
        self.name = "UnaryOp"
    }
}

/// PROGRAM 关键字 + 程序名称 + 分号";"
/// e.g. PROGRAM helloworld ;
/// 后面才是程序主体
class Program:AST {
    var program_name:String
    var block:AST
    
    init(program_name:String, block:AST) {
        self.program_name = program_name
        self.block = block
        super.init()
        self.name = "Program"
    }
}

/// Program 后面紧跟变量声明和复合语句
class Block: AST {
    // 声明语句，可看做是内部用数组 [] 存储了多条的声明语句
    var declarations:[AST]
    // 复合语句
    var compound_statement:AST
    
    init(declarations:[AST],compound_statement:AST) {
        self.declarations =  declarations
        self.compound_statement = compound_statement
        super.init()
        self.name = "Block"
    }
}

/// VAR variable_declaration SEMI(;)
/// e.g.
/// 1. VAR number : INTEGER;
/// 2. VAR a, b, c, x : INTEGER;
class VarDecl:AST {
    var var_node:AST
    var type_node:AST
    
    init(var_node:AST,type_node:AST) {
        self.var_node = var_node
        self.type_node = type_node
        super.init()
        self.name = "VarDecl"
    }
}

/// Type 类型描述 比如 Integer Real
class Type: AST {
    var token:Token
    
    init(token:Token) {
        self.token = token
        super.init()
        self.name = "Type"
    }
}

// 描述 + - * /
// 左右操作数 + 一个运算符
class BinOp: AST {
    var left:AST
    var right:AST
    var op:Token
    var token:Token
    
    init(left:AST, op:Token, right:AST, token:Token) {
        self.left = left
        self.right = right
        self.op = token
        self.token = token
        super.init()
        self.name = "BinOp"
        
    }
    
}

/// 描述 2 3.13 常量数字
class Num: AST {
    var value:Float = 0
    var token:Token
    
    init(token:Token) {
        self.token = token
        if case let Token.integer_const(value) = token {
            self.value = Float(value)
        }
        
        if case let Token.real_const(value) = token  {
            self.value = value
        }
        super.init()
        self.name = "Num"
        
    }
}


/// BEGIN ... END 的关键字标识的 block
class Compound: AST {
    var children : [AST] = []
    
    override init() {
        super.init()
        self.name = "Compound"
    }
}

/// := left是变量var token是:=赋值 right 是表达式
class Assign: AST {
    var variable:Var
    var token:Token
    var expr:AST
    
    init(variable:Var, token:Token, expr:AST) {
        self.variable = variable
        self.token = token
        self.expr = expr
        super.init()
        self.name = "Assign"
    }
}

class Var: AST {
    var var_name:String!
    var token:Token
    
    init(token:Token) {
        self.token = token
        if case let .id(var_name) = token {
            self.var_name = var_name
        }
        super.init()
        self.name = "Var"
        
    }
}

class NoOp: AST {
    
    override init() {
        super.init()
        self.name = "NoOp"
    }
}

// parser 生成AST抽象语法树
class Parser {
    // 方式一：[Character]存储
    // 方式二：String 存储 但是存取需要用index索引去拿
    var lexer : Lexer
    var current_token:Token?
    
    init(lexer:Lexer) {
        self.lexer = lexer
        self.current_token = self.lexer.get_next_token()
    }
    
    // Core Method 类似advance() 方法，前者移动一个char字符
    // 而eat是移动一个token
    func eat(_ token_type:Token){
        if self.current_token! == token_type {
            self.current_token = self.lexer.get_next_token()
        } else {
            print("error happened no expect value!!")
        }
    }

    /**
     example:
     
             PROGRAM helloworld; // 注意分号
           --VAR a:INTEGER
           | ...
block  <===| BEGIN
           | ...
           --END
             .  //<=== 注意圆点 并不属于block的一部分 而是标识程序结束
     */
    
    func program() -> AST {
        self.eat(.program)
        // 获取程序名称 可以认为是 ID
        let var_node = self.variable()
        let prog_name = var_node.var_name
        self.eat(.semi)
        
        // ========= Block AST Node ===========
        let block_node = self.block()
        // ====================================
        let program_node = Program(program_name: prog_name!, block:block_node)
        self.eat(.dot)
        return program_node
    }
    
    func block()->AST {
        // 将所有的变量声明 都转变成 [VarDecl]
        let declaration_nodes = self.declarations()
        //
        let compound_statement_node = self.compound_statement()
        let node = Block(declarations: declaration_nodes, compound_statement: compound_statement_node)
        return node
    }
    
    // 声明 以 VAR 作为发起者, 以下是三个变量声明
    // number     : INTEGER;
    // a, b, c, x : INTEGER;
    // y          : REAL;
    // 实际返回的 [VarDecl] 一个 VarDecl 表示 a:INTEGER
    func declarations()->[AST]  {
        var declarations = [AST]()
        
        if self.current_token! == .vvar {
            self.eat(.vvar)
            while self.current_token! == .id("reserved") {
                let var_decl = self.variable_declaration()
                // var_decl 为 [VarDecl] 继续合并成[VarDecl]
                // note 而不是 [AST,[VarDecl]]
                declarations += var_decl
                self.eat(.semi)
            }
        }
        return declarations
    }
    
    // 一条声明 比如下面的 a 就是一个变量用 VAR AST 呈现
    // 而 Token的"VAR"就是一个保留关键字
    // 例如：a, b: INTEGER;
    //      id(a) comma(,) id(b) colon(:) type_id(INTEGER) semi(;)
    func variable_declaration() -> [AST] {
        // 提取所有 : 左侧的变量 a b c x
        var var_nodes = [Var(token: self.current_token!)]
        self.eat(.id("reserved"))
        
        while self.current_token! == .comma {
            self.eat(.comma)
            var_nodes.append(Var(token: self.current_token!))
            self.eat(.id("reserved"))
        }
        self.eat(.colon)
        // 类型 integer 和 real
        let type_node = self.type_spec()
        let ret = var_nodes.map { (vn) -> VarDecl in
            return VarDecl(var_node: vn, type_node: type_node)
        }
        return ret
    }
    
    func type_spec() -> AST {
        let token = self.current_token!
        if token == .integer {
            self.eat(.integer)
        } else {
            self.eat(.real)
        }
        return Type(token: token)
    }
    
    /// Begin End 关键字包裹了多个 statement
    /// 每个statement 由";" 分号隔开的,更多请见下面
    ///
    /// - Returns: AST
    func compound_statement()->AST{
        self.eat(.begin)
        let nodes = self.statement_list()
        self.eat(.end)
        
        let root = Compound()
        for statement in nodes {
            root.children.append(statement)
        }
        return root
    }
    
    /// 生成一个statement数组,以“;”为分隔符来拆分多条statement
    /// 然后将所有statement 放到一个数组中返回
    /// 其实可以直接把这个函数放到 `compound_statement` 中
    /// 但是区分的话更好理解
    func statement_list()->[AST]{
        let node = self.statement()
        
        var results:[AST] = [node]
        
        while self.current_token! == .semi {
            self.eat(.semi)
            results.append(self.statement())
        }
        
        // 这个判断有什么用？？？
        if self.current_token! == .id("reserved") {
            print("error happened")
        }
        return results
    }
    
    
    /// 分号隔开的statement
    /// 目前有两种：
    /// Assign:   `Var := Integer`
    /// Begin-End:   `Begin End;`
    /// - Returns: Statement AST
    func statement()->AST {
        var node : AST = AST()
        if self.current_token! == .begin {
            node = self.compound_statement()
        } else if self.current_token! == .id("reserved") {
            node = self.assignment_statement()
        }else {
            node  = self.empty()
        }
        return node;
    }
    
    func assignment_statement()->AST{
        let variable = self.variable()
        let token = self.current_token!
        self.eat(.assign)
        let expr = self.expr()
        let node = Assign(variable: variable, token: token, expr: expr)
        return node
    }
    
    func variable()->Var{
        let node = Var(token: self.current_token!)
        self.eat(.id("reserved"))
        return node
    }
    
    func empty()->AST{
        return NoOp()
    }
    
    /// factor === integer | (expr) | (MINUS|PLUS)factor
    ///
    /// - Returns: integer value
    func factor() -> AST {
        let token = self.current_token!
        if token == .lparen {
            self.eat(.lparen)
            let node = self.expr()
            self.eat(.rparen)
            return node
        } else if token == .minus {
            self.eat(.minus)
            return UnaryOp(op: token, token: token, expr: self.factor())
        } else if token == .plus {
            self.eat(.plus)
            return UnaryOp(op: token, token: token, expr: self.factor())
        } else if token == .integer {
            self.eat(.integer)
            return Num(token: token)
        } else if token == .integer_const(-1) {
            self.eat(.integer_const(-1))
            return Num(token: token)
        } else if token == .real_const(-1) {
            self.eat(.real_const(-1))
            return Num(token: token)
        }  else {
            return self.variable()
        }
    }
    
    /// term === factor((MUL|DIV)factor)*
    ///
    /// - Returns: integer value
    func term()->AST {
        var node = self.factor()
        
        while self.current_token! == .mul ||
            self.current_token! == .float_div ||
            self.current_token! == .integer_div {
                let token = self.current_token!
                if token == .mul {
                    self.eat(.mul)
                } else if token == .integer_div {
                    self.eat(.integer_div)
                } else if token == .float_div {
                    self.eat(.float_div)
                }
                node = BinOp(left: node, op: token, right: self.factor(), token: token)
        }
        return node
        
    }
    
    /// expr === term((ADD|MINUS)term)*
    ///
    /// - Returns: integer value
    func expr()->AST {
        
        // 将当前指向的token转成Int类型 并且吃掉它指向下一个操作符 * /
        var node = self.term()
        
        while self.current_token! == .plus ||
            self.current_token! == .minus {
                let token = self.current_token!
                if token == .plus {
                    self.eat(.plus)
                } else if token == .minus {
                    self.eat(.minus)
                }
                node = BinOp(left: node, op: token, right: self.term(), token: token)
        }
        return node
    }
    
    func parse() -> AST {
        let node = self.program()
        if self.current_token! == .eof {
            return node
        } else {
            print("parse AST error")
            return AST()
        }
    }
}

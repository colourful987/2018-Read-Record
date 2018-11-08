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

class Num: AST {
    var value:Int
    var token:Token
    
    init(token:Token) {
        self.token = token
        if case let Token.integer(value) = token {
            self.value = value
        } else {
            self.value = 0
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
    
    func program() -> AST {
        let node = self.compound_statement()
        self.eat( .dot)
        return node
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
        } else if token == .integer(-1) {
            self.eat(.integer(-1))
            return Num(token: token)
        }else {
            return self.variable()
        }
    }
    
    /// term === factor((MUL|DIV)factor)*
    ///
    /// - Returns: integer value
    func term()->AST {
        var node = self.factor()
        
        while self.current_token! == .mul ||
            self.current_token! == .div {
                let token = self.current_token!
                if token == .mul {
                    self.eat(.mul)
                } else if token == .div {
                    self.eat(.div)
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

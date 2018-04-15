//: Playground - noun: a place where people can play


import Foundation
enum Token {
    case none
    case integer(value:Int)
    case plus
    case minus
    case mul
    case div
    case lparen
    case rparen
    case eof
}

func == (lhs:Token,rhs:Token)->Bool{
    switch (lhs,rhs) {
    case (.none,.none):
        return true
    case (.integer,.integer):
        return true
    case (.plus,.plus):
        return true
    case (.minus,.minus):
        return true
    case (.mul,.mul):
        return true
    case (.div,.div):
        return true
    case (.eof,.eof):
        return true
    case (.lparen,.lparen):
        return true
    case (.rparen,.rparen):
        return true
    default:
        return false
    }
}

extension CharacterSet {
    func contains(_ c:Character) -> Bool {
        let scalars = String(c).unicodeScalars
        guard scalars.count == 1 else {
            return false
        }
        return contains(scalars.first!)
    }
}

extension Character {
    func isspace()->Bool {
        return CharacterSet.whitespaces.contains(self)
    }
    
    func isdigit()->Bool {
        return CharacterSet.decimalDigits.contains(self)
    }
    
}

// 分词器 吐出来的东西就是 Token 实例
class Lexer {
    // 方式一：[Character]存储
    // 方式二：String 存储 但是存取需要用index索引去拿
    var text:[Character]
    var pos:Int = 0
    var current_char:Character?
    
    init(sourceCode:String) {
        self.text = Array(sourceCode)
        self.pos = 0
        self.current_char = self.text[self.pos]
    }
    
    // 每次读取一个字符
    func advance(){
        self.pos += 1;
        if self.pos >= self.text.count {
            self.current_char = nil
        } else {
            self.current_char = self.text[self.pos]
        }
    }
    
    func skip_whitespace() {
        while self.current_char != nil && self.current_char!.isspace() {
            self.advance()
        }
    }
    
    func integer() -> Int {
        var result = ""
        while self.current_char != nil && self.current_char!.isdigit() {
            result += String(self.current_char!)
            self.advance()
        }
        return Int(result)!
    }
    
    // Core Method
    func get_next_token()-> Token {
        while self.current_char != nil {
            // 空格
            if self.current_char!.isspace() {
                self.skip_whitespace()
                continue;
            }
            
            if self.current_char!.isdigit() {
                return .integer(value: self.integer())
            }
            
            if self.current_char == "*" {
                self.advance()
                return .mul
            }
            
            if self.current_char == "/" {
                self.advance()
                return .div
            }
            
            if self.current_char == "+" {
                self.advance()
                return .plus
            }
            
            if self.current_char == "-" {
                self.advance()
                return .minus
            }
            
            if self.current_char == "(" {
                self.advance()
                return .lparen
            }
            
            if self.current_char == ")" {
                self.advance()
                return .rparen
            }
            
            print("error happened no expect value!!")
            break
        }
        return .eof
    }
    
}

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
    func eat(token_type:Token){
        if self.current_token! == token_type {
            self.current_token = self.lexer.get_next_token()
        } else {
            print("error happened no expect value!!")
        }
    }
    
    
    /// factor === integer | (expr) | (MINUS|PLUS)factor
    ///
    /// - Returns: integer value
    func factor() -> AST {
        let token = self.current_token!
        if token == .lparen {
            self.eat(token_type: .lparen)
            let node = self.expr()
            self.eat(token_type: .rparen)
            return node
        } else if token == .minus {
            self.eat(token_type: .minus)
            return UnaryOp(op: token, token: token, expr: self.factor())
        } else if token == .plus {
            self.eat(token_type: .plus)
            return UnaryOp(op: token, token: token, expr: self.factor())
        } else {
            self.eat(token_type: .integer(value: 1))
            return Num(token: token)
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
                    self.eat(token_type: .mul)
                } else if token == .div {
                    self.eat(token_type: .div)
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
                    self.eat(token_type: .plus)
                } else if token == .minus {
                    self.eat(token_type: .minus)
                }
                node = BinOp(left: node, op: token, right: self.term(), token: token)
        }
        return node
    }
    
    func parse() -> AST {
        return self.expr()
    }
}


class Interpreter {
    var parser:Parser
    
    init(parser:Parser) {
        self.parser = parser
    }
    
    func visit(_ node:AST) -> Int {
        
        if node.name == "BinOp" {
            return self.visit_BinOp(node: node as! BinOp)
        } else if node.name == "Num" {
            return self.visit_Num(node as! Num)
        } else if node.name == "UnaryOp" {
            return self.visit_UnaryOp(node as! UnaryOp)
        }
        print("error in visit")
        return 0
    }
    
    func visit_UnaryOp(_ node:UnaryOp)->Int {
        let op = node.token
        if op == .plus {
            return +self.visit(node.expr)
        } else if op == .minus {
            return -self.visit(node.expr)
        }
        print("error in visit")
        return 0
    }
    
    func visit_BinOp(node:BinOp) -> Int {
        if node.token == .plus {
            return self.visit(node.left) + self.visit(node.right)
        } else if node.token == .minus {
            return self.visit(node.left) - self.visit(node.right)
        } else if node.token == .mul {
            return self.visit(node.left) * self.visit(node.right)
        } else if node.token == .div {
            return self.visit(node.left) / self.visit(node.right)
        }
        print("error !!!")
        return 0
    }
    
    func visit_Num(_ node:Num) -> Int {
        return node.value
    }
    
    func interpret()-> Int{
        let tree = self.parser.parse()
        return self.visit(tree)
    }
}

let case_0 = "1+2 + 10 * 3 + (2 + -3) * 4 "
let lexer = Lexer(sourceCode: case_0)
let parser = Parser(lexer: lexer)
let interpreter = Interpreter(parser: parser)
let ret = interpreter.interpret()
print(ret)

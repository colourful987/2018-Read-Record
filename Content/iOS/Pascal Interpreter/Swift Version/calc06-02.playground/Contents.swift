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

class Interpreter {
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
    
    
    /// factor === integer | (expr)
    ///
    /// - Returns: integer value
    func factor() -> Int {
        let token = self.current_token
        var ret = 0
        if token! == .lparen {
            self.eat(token_type: .lparen)
            ret = self.expr()
            self.eat(token_type: .rparen)
        } else {
            self.eat(token_type: .integer(value: 1))
            if case let Token.integer(value) = token! {
                ret = value
            }
            
        }
        return ret
    }
    
    /// term === factor((MUL|DIV)factor)*
    ///
    /// - Returns: integer value
    func term()->Int {
        var result = self.factor()
        
        while self.current_token! == .mul ||
            self.current_token! == .div {
                let token = self.current_token!
                if token == .mul {
                    self.eat(token_type: .mul)
                    result *= self.factor()
                } else if token == .div {
                    self.eat(token_type: .div)
                    result /= self.factor()
                }
        }
        return result
        
    }
    
    /// expr === term((ADD|MINUS)term)*
    ///
    /// - Returns: integer value
    func expr()->Int {
        
        // 将当前指向的token转成Int类型 并且吃掉它指向下一个操作符 * /
        var result = self.term()
        
        while self.current_token! == .plus ||
            self.current_token! == .minus {
                let token = self.current_token!
                if token == .plus {
                    self.eat(token_type: .plus)
                    result += self.term()
                } else if token == .minus {
                    self.eat(token_type: .minus)
                    result -= self.term()
                }
        }
        return result
    }
}

var case0 = "2 * 3  + 100 / (5 - 10)"
var lexer = Lexer(sourceCode: case0)
var interpreter = Interpreter(lexer: lexer)
var ret = interpreter.expr()
print(ret)

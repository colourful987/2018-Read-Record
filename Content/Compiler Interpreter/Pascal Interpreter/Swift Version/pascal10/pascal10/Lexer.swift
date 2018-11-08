//
//  Lexer.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation


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
    
    // 只是看一下后面的字符并不会
    func peek()->Character? {
        let peek_pos = self.pos + 1;
        if peek_pos >= self.text.count {
            return nil
        } else {
            return self.text[peek_pos]
        }
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
    
    func number() -> Token {
        var result = ""
        while self.current_char != nil && self.current_char!.isdigit() {
            result += String(self.current_char!)
            self.advance()
        }
        
        if self.current_char == "." {
            result += String(self.current_char!)
            self.advance()
            
            while self.current_char != nil && self.current_char!.isdigit() {
                result += String(self.current_char!)
                self.advance()
            }
            return .real_const(Float(result)!)
        }
        return .integer_const(Int(result)!)
    }
    
    func id() -> Token {
        var result = ""
        while self.current_char != nil && self.current_char!.isalnum() {
            result += String(self.current_char!)
            self.advance()
        }
        return RESERVED_KEYWORDS[result] ?? .id(result)
    }
    
    func skip_comment() {
        while self.current_char! != "}" {
            self.advance()
        }
        // 越过最后 ”}“ 符号
        self.advance()
    }
    
    // Core Method
    func get_next_token()-> Token {
        while self.current_char != nil {
            // 空格
            if self.current_char!.isspace() {
                self.skip_whitespace()
                continue;
            }
            
            // 去除 "{}" 注释
            if self.current_char! == "{" {
                self.advance()
                self.skip_comment()
                continue;
            }
            
            if self.current_char! == "," {
                self.advance()
                return .comma
            }
            
            if self.current_char!.isdigit() {
                return self.number()
            }
            
            if self.current_char!.isalpha() {
                return self.id()
            }
            
            if self.current_char! == ":" && self.peek() == "=" {
                self.advance()
                self.advance()
                return .assign
            }
            
            if self.current_char! == ":" {
                self.advance()
                return .colon
            }
            
            if self.current_char! == ";"{
                self.advance()
                return .semi
            }
            
            if self.current_char! == "."{
                self.advance()
                return .dot
            }
            
            if self.current_char == "*" {
                self.advance()
                return .mul
            }
            
            if self.current_char == "/" {
                self.advance()
                return .float_div
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

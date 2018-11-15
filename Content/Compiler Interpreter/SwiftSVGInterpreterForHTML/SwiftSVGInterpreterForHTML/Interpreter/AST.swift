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

class HTML:AST {
    var body:AST
    
    init(body:AST) {
        self.body = body
        super.init()
        self.name = "HTML"
    }
}

class Body:AST {
    // 目前body 仅支持 svg element，以后可以支持 div, form, audio 等等
    var elements:[AST]
    
    override init() {
        self.elements = []
        super.init()
        self.name = "Body"
    }
}

class SVG:AST {
    var shapeElms:[Shape]
    var propertyList:PropertyList
    
    init(shapes:[Shape], propertyList:PropertyList) {
        self.shapeElms = shapes
        self.propertyList = propertyList
        super.init()
        self.name = "SVG"
    }
}

class Shape:AST {
    // rect circle etc shapes
    var shapeType:Token
    // 属性
    var propertyList:PropertyList
    
    init(shapeType:Token, propertyList:PropertyList) {
        self.shapeType = shapeType
        self.propertyList = propertyList
        super.init()
        self.name = "Shape"
    }
}

class PropertyList:AST {
    // 属性
    var properties:[Property]
    
    override init() {
        self.properties = []
        super.init()
        self.name = "PropertyList"
    }
}

class Property:AST {
    var key:Token
    var value:AST // PropertyNum or PropertyString
    
    init(key:Token, value:AST) {
        self.key = key
        self.value = value
        super.init()
        self.name = "Property"
    }
}

class PropertyNum: AST {
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
        self.name = "PropertyNum"
    }
}

class PropertyString: AST {
    var value:String = ""
    var token:Token
    
    init(token:Token) {
        self.token = token
        if case let Token.id(value) = token {
            self.value = value
        }
        super.init()
        self.name = "PropertyString"
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
    
    func eat(_ token_type:Token){
        if self.current_token! == token_type {
            self.current_token = self.lexer.get_next_token()
        } else {
            print("error happened no expect value!!")
        }
    }
    func html() -> AST {
        self.eat(.angleLeftBracket)
        self.eat(.html)
        self.eat(.angleRightBracket)
        
        let bodyNode = self.body()
        // 好蠢的写法啊~~~~~
        self.eat(.angleLeftBracket)
        self.eat(.backslash)
        self.eat(.html)
        self.eat(.angleRightBracket)
        
        return HTML(body: bodyNode)
    }
    
    func body() -> AST {
        self.eat(.angleLeftBracket)
        self.eat(.body)
        self.eat(.angleRightBracket)
        // 其实这里应该是允许有多个元素类型的 目前写死一个
        let svg = self.svg()
        
        self.eat(.angleLeftBracket)
        self.eat(.backslash)
        self.eat(.body)
        self.eat(.angleRightBracket)
        
        let body = Body()
        body.elements.append(svg)
        return body
    }
    
    func svg() -> AST {
        self.eat(.angleLeftBracket)
        self.eat(.svg)
        let propertyList = self.properties()
        self.eat(.angleRightBracket)
        
        var shapes:[AST] = []
        while self.current_token! == .angleLeftBracket && self.lexer.current_char! != "/" {
            self.eat(.angleLeftBracket)
            let shape = self.shape()
            self.eat(.backslash)
            self.eat(.angleRightBracket)
            shapes.append(shape)
        }
        self.eat(.angleLeftBracket)
        self.eat(.backslash)
        self.eat(.svg)
        self.eat(.angleRightBracket)
        
        return SVG(shapes: shapes as! [Shape], propertyList:propertyList as! PropertyList)
    }
    
    func shape() -> AST {
        let shapeType = self.current_token!
        self.eat(.id("whatever"))
        let propertyList = self.properties()
        return Shape(shapeType: shapeType, propertyList: propertyList as! PropertyList)
    }
    
    func properties() -> AST {
        let propertyList = PropertyList()
        // 这里我可以再分成properties 我觉得比较好
        while self.current_token! == .id("whatever") {
            let key = self.current_token!
            self.eat(.id("whatever"))
            self.eat(.assign)
            self.eat(.quote)
            let valueToken = self.current_token!
            var value:AST!
            if self.current_token! == .id("whatever") {
                value = PropertyString(token: valueToken)
                self.eat(.id("whatever"))
            } else if self.current_token! == .integer_const(100) {
                value = PropertyNum(token: valueToken)
                self.eat(.integer_const(100))
            } else if self.current_token! == .real_const(100) {
                value = PropertyNum(token: valueToken)
                self.eat(.real_const(100))
            }
            self.eat(.quote)
            let property = Property(key: key, value: value)
            propertyList.properties.append(property)
        }
        return propertyList
    }
    
    func parse() -> AST {
        let node = self.html()
        if self.current_token! == .eof {
            return node
        } else {
            print("parse AST error")
            return AST()
        }
    }
}

//
//  SymbolTable.swift
//  pascal11
//
//  Created by pmst on 2018/4/16.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation


class Symbol:CustomStringConvertible{

    
    var name : String
    var type : String
    
    init(name:String, type:String) {
        self.name = name
        self.type = type
    }

    var description: String {
        return "{\(self.type)} {\(self.name)}"
    }
}

/// Integer Real 符号？
class BuiltinTypeSymbol: Symbol {
    init(name:String) {
        super.init(name: name, type: "BuiltinTypeSymbol")
    }
    
    override var description: String {
        return "内置类型:\(self.name)"
    }
}

class VarSymbol: Symbol {
    override var description: String {
        return "变量:\(self.name) 类型:\(self.type)"
    }
}


class SymbolTable:CustomStringConvertible{
    var symbols:[String:Symbol] = [:]
    
    init() {
        self.init_builtins()
    }
    
    func init_builtins(){
        self.define(BuiltinTypeSymbol(name:"INTEGER" ))
        self.define(BuiltinTypeSymbol(name:"REAL" ))
    }
    
    var description: String {
        var result = ""
        for symbol in self.symbols {
            result += "\(symbol)"
        }
        return result
    }
    
    func define(_ symbol:Symbol) {
        print("Define \(symbol)")
        self.symbols[symbol.name] = symbol
    }
    
    func lookup(name:String) -> Symbol? {
        return self.symbols[name]
    }
}

























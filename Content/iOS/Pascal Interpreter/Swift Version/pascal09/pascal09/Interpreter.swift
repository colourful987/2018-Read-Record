//
//  Interpreter.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation


class Interpreter {
    var parser:Parser
    var global_scope :[String:Int] = [:]
    
    init(parser:Parser) {
        self.parser = parser
    }
    
    @discardableResult func visit(_ node:AST)->Int {
        
        if node.name == "BinOp" {
            return self.visit_BinOp(node: node as! BinOp)
        } else if node.name == "Num" {
            return self.visit_Num(node as! Num)
        } else if node.name == "UnaryOp" {
            return self.visit_UnaryOp(node as! UnaryOp)
        } else if node.name == "Var" {
            return self.visit_Var(node as! Var)
        } else if node.name == "Compound" {
            return self.visit_Compound(node as! Compound)
        } else if node.name == "Assign" {
            return self.visit_Assign(node as! Assign)
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
    
    func visit_NoOp(_ node:NoOp)->Int {
        return -1
    }
    
    func visit_Assign(_ node:Assign)->Int{
        let var_name = node.variable.var_name
        self.global_scope[var_name!] = self.visit(node.expr)
        return -1
    }
    
    func visit_Var(_ node:Var)->Int{
        let var_name = node.var_name
        let val = self.global_scope[var_name!]!
        
        return val
        
    }
    
    func visit_Compound(_ node:Compound)->Int {
        for child in node.children{
            self.visit(child)
        }
        return -1
    }
    
    func interpret()-> Int{
        let tree = self.parser.parse()
        return self.visit(tree)
    }
}

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
    var global_scope :[String:Float] = [:]
    
    init(parser:Parser) {
        self.parser = parser
    }
//
//    @discardableResult func visit(_ node:AST)->Float {
//
//        if node.name == "BinOp" {
//            return self.visit_BinOp(node: node as! BinOp)
//        } else if node.name == "Num" {
//            return self.visit_Num(node as! Num)
//        } else if node.name == "UnaryOp" {
//            return self.visit_UnaryOp(node as! UnaryOp)
//        } else if node.name == "Var" {
//            return self.visit_Var(node as! Var)
//        } else if node.name == "Compound" {
//            return self.visit_Compound(node as! Compound)
//        } else if node.name == "Assign" {
//            return self.visit_Assign(node as! Assign)
//        } else if node.name == "Program" {
//            return self.visit_Program(node as! Program)
//        } else if node.name == "Block" {
//            return self.visit_Block(node as! Block)
//        } else if node.name == "Type" {
//            return self.visit_Type(node as! Type)
//        } else if node.name == "VarDecl" {
//            return self.visit_VarDel(node as! VarDecl)
//        } else if node.name == "NoOp" {
//            return self.visit_NoOp(node as! NoOp)
//        }
//
//        print("error in visit")
//        return 0
//    }
//
//    func visit_Type(_ node:Type)->Float {
//        return -1
//    }
//
//    func visit_UnaryOp(_ node:UnaryOp)->Float {
//        let op = node.token
//        if op == .plus {
//            return +self.visit(node.expr)
//        } else if op == .minus {
//            return -self.visit(node.expr)
//        }
//        print("error in visit")
//        return 0
//    }
//
//    func visit_BinOp(node:BinOp) -> Float {
//        if node.token == .plus {
//            return Float(self.visit(node.left) + self.visit(node.right))
//        } else if node.token == .minus {
//            return Float(self.visit(node.left) - self.visit(node.right))
//        } else if node.token == .mul {
//            return Float(self.visit(node.left) * self.visit(node.right))
//        } else if node.token == .integer_div {
//            return Float(self.visit(node.left) / self.visit(node.right))
//        } else if node.token == .float_div {
//            return Float(self.visit(node.left)) / Float(self.visit(node.right))
//        }
//        print("error !!!")
//        return 0
//    }
//
//    func visit_Num(_ node:Num) -> Float {
//        return node.value
//    }
//
//    func visit_NoOp(_ node:NoOp)->Float {
//        return -1
//    }
//
//    func visit_VarDel(_ node:VarDecl)->Float {
//        return -1
//    }
//
//    func visit_Assign(_ node:Assign)->Float{
//        let var_name = node.variable.var_name
//        self.global_scope[var_name!] = self.visit(node.expr)
//        return -1
//    }
//
//    func visit_Var(_ node:Var)->Float{
//        let var_name = node.var_name
//        let val = self.global_scope[var_name!]!
//
//        return val
//    }
//
//    func visit_Compound(_ node:Compound)->Float{
//        for child in node.children{
//            self.visit(child)
//        }
//        return -1
//    }
//
//    func visit_Program(_ node:Program)->Float {
//        self.visit(node.block)
//        return -1
//    }
//
//    func visit_Block(_ node:Block)->Float {
//        // 遍历所有的 VarDecl 设置到 GLOBAL 中
//        for declaration in node.declarations {
//            self.visit(declaration)
//        }
//
//        // 遍历所有的复合程序
//        self.visit(node.compound_statement)
//        return -1
//    }
    
    func interpret()-> Float {
        let tree = self.parser.parse()
        return 1.0
//        return self.visit(tree)
    }
}














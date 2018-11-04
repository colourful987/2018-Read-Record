//
//  SymbolTableBuilder.swift
//  pascal11
//
//  Created by pmst on 2018/4/16.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation

// 只是为了生成所有的变量映射表
class SymbolTableBuilder {
    var symtab = SymbolTable()
    
    
    func visit(_ node:AST) {
        
        if node.name == "BinOp" {
            self.visit_BinOp(node: node as! BinOp)
        } else if node.name == "Num" {
            self.visit_Num(node as! Num)
        } else if node.name == "UnaryOp" {
            self.visit_UnaryOp(node as! UnaryOp)
        } else if node.name == "Var" {
            self.visit_Var(node as! Var)
        } else if node.name == "Compound" {
            self.visit_Compound(node as! Compound)
        } else if node.name == "Assign" {
            self.visit_Assign(node as! Assign)
        } else if node.name == "Program" {
            self.visit_Program(node as! Program)
        } else if node.name == "Block" {
            self.visit_Block(node as! Block)
        } else if node.name == "Type" {
            self.visit_Type(node as! Type)
        } else if node.name == "VarDecl" {
            self.visit_VarDel(node as! VarDecl)
        } else if node.name == "NoOp" {
            self.visit_NoOp(node as! NoOp)
        } else {
            
            print("error in visit")
        }
        
    }
    
    func visit_Block(_ node:Block) {
        // 遍历所有的 VarDecl 设置到 GLOBAL 中
        for declaration in node.declarations {
            self.visit(declaration)
        }
        
        // 遍历所有的复合程序
        self.visit(node.compound_statement)
    }
    
    func visit_Program(_ node:Program) {
        self.visit(node.block)
    }
    
    
    func visit_Type(_ node:Type) {
    }
    
    func visit_BinOp(node:BinOp) {
        self.visit(node.left)
        self.visit(node.right)
    }
    
    func visit_Num(_ node:Num) {
        
    }
    
    func visit_UnaryOp(_ node:UnaryOp) {
        self.visit(node.expr)
    }
    
    
    func visit_NoOp(_ node:NoOp) {
        
    }
    
    func visit_Compound(_ node:Compound){
        for child in node.children{
            self.visit(child)
        }
    }
    
    /// 访问一条语句声明 变量Var + 类型
    /// 其中变量Var 就是 a b x 这种
    func visit_VarDel(_ node:VarDecl) {
        let type_name = node.type_node.value!
        let type_symbol = self.symtab.lookup(name: type_name)
        let var_name = node.var_node.var_name
        let var_symbol = VarSymbol(name: var_name!, type: type_symbol!.name)
        self.symtab.define(var_symbol)
    }
    
    func visit_Assign(_ node:Assign){
        let var_name = node.variable.var_name
        let var_symbol = self.symtab.lookup(name: var_name!)
        
        if var_symbol == nil {
            print("error in visit_Assign")
        }
        
        self.visit(node.expr)
    }
    
    func visit_Var(_ node:Var){
        let var_name = node.var_name
        let var_symbol = self.symtab.lookup(name: var_name!)
        
        if var_symbol == nil {
            print("error in visit_Var")
        }
    }
    
    
}

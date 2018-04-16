//
//  Token.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation


enum Token {
    case vvar
    case begin
    case end
    case integer    // 类型：整数
    case real       // 类型：实数
    case integer_const(Int)
    case real_const(Float)
    case integer_div
    case float_div
    case plus
    case minus
    case mul
    case program
    case colon  // :
    case comma  // ,
    case lparen // (
    case rparen // )
    case id(String)     // x y z 变量名称 begin end 也算
    case assign // :=
    case semi   // ;
    case dot    // .
    case eof
}

let RESERVED_KEYWORDS : [String:Token] = ["BEGIN":.begin,
                                          "END":.end,
                                          "PROGRAM":.program,
                                          "VAR":.vvar,
                                          "REAL":.real,
                                          "INTEGER":.integer,
                                          "DIV":.integer_div]


func == (lhs:Token,rhs:Token)->Bool{
    switch (lhs,rhs) {
    case (.vvar,.vvar):
        return true
    case (.integer,.integer):
        return true
    case (.real,.real):
        return true
    case (.begin,.begin):
        return true
    case (.end,.end):
        return true
    case (.integer_const,.integer_const):
        return true
    case (.colon,.colon):
        return true
    case (.comma,.comma):
        return true
    case (.program,.program):
        return true
    case (.integer_div,.integer_div):
        return true
    case (.real_const,.real_const):
        return true
    case (.plus,.plus):
        return true
    case (.minus,.minus):
        return true
    case (.mul,.mul):
        return true
    case (.float_div,.float_div):
        return true
    case (.eof,.eof):
        return true
    case (.lparen,.lparen):
        return true
    case (.rparen,.rparen):
        return true
    case (.id(_),.id(_)):
        return true
    case (.assign,.assign):
        return true
    case (.semi,.semi):
        return true
    case (.dot,.dot):
        return true
    default:
        return false
    }
}

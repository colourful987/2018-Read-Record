//
//  Token.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation


enum Token {
    case begin
    case end
    case integer(Int)
    case plus
    case minus
    case mul
    case div
    case lparen // (
    case rparen // )
    case id(String)     // x y z 变量名称 begin end 也算
    case assign // :=
    case semi   // ;
    case dot    // .
    case eof
}

let RESERVED_KEYWORDS : [String:Token] = ["BEGIN":.begin,
                                          "END":.end]


func == (lhs:Token,rhs:Token)->Bool{
    switch (lhs,rhs) {
    case (.begin,.begin):
        return true
    case (.end,.end):
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

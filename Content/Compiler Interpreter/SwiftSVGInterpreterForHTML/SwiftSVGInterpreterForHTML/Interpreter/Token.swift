//
//  Token.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation


enum Token {
    case html               // html
    case body               // body
    case svg                // svg = swift UIView
    case rect
    case circle
    case angleLeftBracket   // <
    case angleRightBracket  // >
    case quote              // '
    case assign             // =
    case backslash          // /
    case dot                // . 目前只出现在浮点数中
    case integer            // 类型：整数 pascal里是INTEGER 表示类型 这里不需要
    case real               // 类型：实数
    case integer_const(Int)
    case real_const(Float)
    case id(String)         // x y z 变量名称 begin end 也算
    case semi               // ;
    case eof
}

let RESERVED_KEYWORDS : [String:Token] = ["HTML":.html,
                                          "body":.body,
                                          "svg":.svg,
                                          "rect":.rect,
                                          "circle":.circle]


func == (lhs:Token,rhs:Token)->Bool{
    switch (lhs,rhs) {
    case (.html,.html):
        return true
    case (.body,.body):
        return true
    case (.svg,.svg):
        return true
    case (.rect,.rect):
        return true
    case (.angleLeftBracket,.angleLeftBracket):
        return true
    case (.angleRightBracket,.angleRightBracket):
        return true
    case (.quote,.quote):
        return true
    case (.assign,.assign):
        return true
    case (.backslash,.backslash):
        return true
    case (.dot,.dot):
        return true
    case (.real_const,.real_const):
        return true
    case (.integer,.integer):
        return true
    case (.real,.real):
        return true
    case (.eof,.eof):
        return true
    case (.id(_),.id(_)):
        return true
    case (.semi,.semi):
        return true
    default:
        return false
    }
}

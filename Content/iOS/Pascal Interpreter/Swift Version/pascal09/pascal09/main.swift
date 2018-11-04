//
//  main.swift
//  pascal09
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation

let case_0 =
"""
BEGIN
    BEGIN
        number := 2;
        a := number;
        b := 10 * a + 10 * number / 4;
        c := a - - b
    END;
    x := 11;
END.
"""

let lexer = Lexer(sourceCode: case_0)
let parser = Parser(lexer: lexer)
let interpreter = Interpreter(parser: parser)
let ret = interpreter.interpret()
print(interpreter.global_scope)


//
//  main.swift
//  pascal11
//
//  Created by pmst on 2018/4/16.
//  Copyright © 2018 pmst. All rights reserved.
//

import Foundation

let case_0 =
"""
PROGRAM Part10;
VAR
number     : INTEGER;
a, b, c, x : INTEGER;
y          : REAL;

BEGIN {Part10}
BEGIN
number := 3;
a := number + 10 * 2 - 1;
b := 10 * a + 10 * number DIV 4;
c := a - - b
END;
END.
"""

let lexer = Lexer(sourceCode: case_0)
let parser = Parser(lexer: lexer)
let tree = parser.parse()
let symtabBuilder = SymbolTableBuilder()
symtabBuilder.visit(tree)


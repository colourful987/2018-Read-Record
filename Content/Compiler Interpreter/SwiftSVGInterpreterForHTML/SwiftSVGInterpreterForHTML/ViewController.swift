//
//  ViewController.swift
//  SwiftSVGInterpreterForHTML
//
//  Created by pmst on 2018/11/14.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

let case_0 =
"""
<html>
    <body>
        <svg width='250' height='250'>
            <rect x='110.0' y='10.0' width='100.0' height='130.0' stroke='teal' fill='aqua' stroke-width='5' />
            <circle cx='80.0' cy='160.0' r='60.0' stroke='red' fill='yellow' stroke-width='5'/>
        </svg>
    </body>
</html>
"""

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lexer = Lexer(sourceCode: case_0)
        let parser = Parser(lexer: lexer)
        let interpreter = Interpreter(parser: parser)
        interpreter.interpret()
    }


}


//
//  Render.swift
//  SwiftSVGInterpreterForHTML
//
//  Created by pmst on 2018/11/17.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

enum Color {
    case named(name:ColorName)
    case rgb(red:UInt8, green:UInt8, blue:UInt8)
}

extension Color {
    enum ColorName: String, CaseIterable {
        case black, silver, gray, white, maroon, red, purple, fuchsia, green,
        lime, olive, yellow, navy, blue, teal, aqua
    }
}

extension Color: CustomStringConvertible {
    var description: String {
        switch self {
        case .named(let colorName):
            return colorName.rawValue
        case .rgb(let red, let green, let blue):
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
}

extension Color {
    init(gray:UInt8) {
        self = .rgb(red: gray, green: gray, blue: gray)
    }
}

protocol Drawable {
    func draw(in context:CGContext)
}


protocol ParseRenderParams {
    func parse(with params:Dictionary<String, Any>)
}

struct Circle:Drawable,ParseRenderParams {
    var strokeWidth = 5
    var strokeColor = Color.named(name: .red)
    var fillColor = Color.named(name: .yellow)
    var center = (x:80.0, y:160.0)
    var raduis = 60.0
    
    func draw(in context: CGContext) {
        context.saveGState()
        context.strokeEllipse(in: CGRect(x: center.x, y: center.y, width: raduis, height: raduis))
        context.restoreGState()
    }
    
    func parse(with params: Dictionary<String, Any>) {
        print("解析传入的参数: \(params)")
    }
}

struct Rectangle: Drawable,ParseRenderParams {
    var strokeWidth = 5
    var strokeColor = Color.named(name: .teal)
    var fillColor = Color.named(name: .aqua)
    var origin = (x: 110.0, y: 10.0)
    var size = (width: 100.0, height: 130.0)
    
    func draw(in context: CGContext) {
        context.saveGState()
        context.stroke(CGRect(x: origin.x, y: origin.y, width: size.width, height: size.width))
        context.restoreGState()
    }
    
    func parse(with params: Dictionary<String, Any>) {
        print("解析传入的参数: \(params)")
    }
}


























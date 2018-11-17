//
//  Interpreter.swift
//  12312
//
//  Created by pmst on 2018/4/15.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit


class Interpreter {
    var parser:Parser
    var global_scope :[String:Float] = [:]
    
    init(parser:Parser) {
        self.parser = parser
    }

    @discardableResult func visit(_ node:AST) -> Any {

        if node.name == "HTML" {
            return self.visit_HTML(node as! HTML)
        } else if node.name == "Body" {
            return self.visit_Body(node as! Body)
        } else if node.name == "SVG" {
            return self.visit_SVG(node as! SVG)
        } else if node.name == "Shape" {
            return self.visit_Shape(node as! Shape)
        } else if node.name == "PropertyList" {
            return self.visit_PropertyList(node as! PropertyList)
        } else if node.name == "Property" {
            return self.visit_Property(node as! Property)
        } else if node.name == "PropertyNum" {
            return self.visit_PropertyNum(node as! PropertyNum)
        } else if node.name == "PropertyString" {
            return self.visit_PropertyString(node as! PropertyString)
        } else if node.name == "NoOp" {
            return self.vist_NoOp(node as! NoOp)
        }

        print("error in visit")
        return UIView.init()
    }
    
    func visit_HTML(_ node:HTML) -> UIView {
        return self.visit(node.body) as! UIView
    }
    
    func visit_Body(_ node:Body) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        var subView : UIView
        for node in node.elements {
            subView = self.visit(node) as! UIView
            view.addSubview(subView)
        }
        return view
    }
    
    func visit_SVG(_ node:SVG) -> UIView {
        let property:PropertyList = node.propertyList
        var width:Float = 0.0
        var height:Float = 0.0
        for property in property.properties {
            guard case let .id(keyName) = property.key else {continue}

            if keyName == "width" {
                width = (property.value as! PropertyNum).value
            } else if keyName == "height" {
                height = (property.value as! PropertyNum).value
            } else {
                print("Not support property in SVG!!!")
            }
        }
        let svgCanvas = UIView(frame: CGRect(x: 0.0, y: 0.0, width:Double(width), height: Double(height)))
        UIGraphicsBeginImageContext(svgCanvas.bounds.size)
        for shape in node.shapeElms {
            self.visit(shape)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        svgCanvas.addSubview(UIImageView(image: image))
        return svgCanvas
    }
    
    func visit_Shape(_ node:Shape) {
        let context = UIGraphicsGetCurrentContext()
        let params = self.visit(node.propertyList) as! [String:Any]
        guard case let .id(shapeName) = node.shapeType else {
            return
        }
        
        if shapeName == "circle" {
            let circle = Circle()
            circle.parse(with: params)
            circle.draw(in: context!)
        } else if shapeName == "rect" {
            let rectangle = Rectangle()
            rectangle.parse(with: params)
            rectangle.draw(in: context!)
        } else {
            print("暂不支持的Shape类型")
        }
        
    }
    
    func visit_PropertyList(_ node:PropertyList) -> [String:Any] {
        var ret : [String:Any] = Dictionary()
        for property in node.properties {
            let (key,value) = self.visit(property) as! (String,Any)
            ret[key] = value
        }
        return ret
    }
    
    func visit_Property(_ node:Property) -> (String,Any) {
        var keyRet:String = ""
        if case let .id(key) = node.key {
            keyRet = key
        }
        let valueRet = self.visit(node.value)

        return (keyRet, valueRet)
    }
    
    func visit_PropertyNum(_ node:PropertyNum) -> Float {
        return node.value
    }
    
    func visit_PropertyString(_ node: PropertyString) -> String {
        return node.value
    }
    
    func vist_NoOp(_ node:NoOp) -> Float {
        return -1
    }
    
    
    func interpret() -> UIView {
        let tree = self.parser.parse()
        return self.visit(tree) as! UIView
    }
}














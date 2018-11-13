import UIKit


enum ColorName: String, CaseIterable {
    case black, silver, gray, white, maroon, red, purple, fuchsia, green,
    lime, olive, yellow, navy, blue, teal, aqua
}

enum CSSColor {
    case named(name:ColorName)
    case rgb(red:UInt8, green:UInt8, blue:UInt8)
}

extension CSSColor: CustomStringConvertible {
    var description: String {
        switch self {
        case .named(let colorName):
            return colorName.rawValue
        case .rgb(let red, let green, let blue):
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
}

protocol Drawable {
    func draw(with context:DrawingContext)
}

protocol DrawingContext {
    func draw(_ circle:Circle)
    func draw(_ rectangle:Rectangle)
}

// Circle 只是描述圆这个对象
// draw 方法认为是其 Behavior
// 这里的 DrawingContext 可以认为是一个render Object
// 一个 Circle 绑定一个 Render，这样做的好处不言而喻
// 1. 职责分明 2. 分离render后，可为Circle动态绑定不同的渲染对象 灵活
// 这里的 DrawingContext 可认为是一个画笔 可以绘制圆形和矩形的画笔
// 并非是仅支持一种Shape的渲染器
@dynamicMemberLookup
struct Circle:Drawable {
    func draw(with context: DrawingContext) {
        context.draw(self)
    }
    
    var strokeWidth = 5
    var stockColor = CSSColor.named(name: .red)
    var fillColor = CSSColor.named(name: .yellow)
    var center = (x:80.0,y:160.0)
    var radius = 60.0
    
    subscript(dynamicMember member: String) -> String {
        let properties = ["name": "Mr Circle"]
        return properties[member, default: ""]
    }
}

struct Rectangle:Drawable {
    var strokeWidth = 5
    var strokeColor = CSSColor.named(name: .teal)
    var fillColor = CSSColor.named(name: .aqua)
    var origin = (x: 110.0, y: 10.0)
    var size = (width: 100.0, height: 130.0)
    
    func draw(with context: DrawingContext) {
        context.draw(self)
    }
}


// SVGContext 就好比是UIKit 中的绘制上下文，它知道怎么绘制圆 矩形等Shape
// 而SVGContext是被我们的SVGDocument维护的。一份文档对应一个上下文
final class SVGContext:DrawingContext {
    private var commands: [String] = []
    
    var width = 250
    var height = 250
    
    // 1
    func draw(_ circle: Circle) {
        let command = """
        <circle cx='\(circle.center.x)' cy='\(circle.center.y)\' r='\(circle.radius)' \
        stroke='\(circle.strokeColor)' fill='\(circle.fillColor)' \
        stroke-width='\(circle.strokeWidth)' />
        """
        commands.append(command)
    }
    
    // 2
    func draw(_ rectangle: Rectangle) {
        let command = """
        <rect x='\(rectangle.origin.x)' y='\(rectangle.origin.y)' \
        width='\(rectangle.size.width)' height='\(rectangle.size.height)' \
        stroke='\(rectangle.strokeColor)' fill='\(rectangle.fillColor)' \
        stroke-width='\(rectangle.strokeWidth)' />
        """
        commands.append(command)
    }
    
    var svgString: String {
        var output = "<svg width='\(width)' height='\(height)'>"
        for command in commands {
            output += command
        }
        output += "</svg>"
        return output
    }
    
    var htmlString: String {
        return "<!DOCTYPE html><html><body>" + svgString + "</body></html>"
    }
}

struct SVGDocument {
    var drawables: [Drawable] = []
    
    var htmlString: String {
        let context = SVGContext()
        for drawable in drawables {
            drawable.draw(with: context)
        }
        return context.htmlString
    }
    
    mutating func append(_ drawable: Drawable) {
        drawables.append(drawable)
    }
}

// 我们不直接操作SVGContext上下文 而是采用以add的方式假如到Document中
// 然后通过遍历一个个draw in svgContext 中，draw这个action其实就是输出html标记语言罢了


var document = SVGDocument()

let rectangle = Rectangle()
document.append(rectangle)

let circle = Circle()
document.append(circle)

let htmlString = document.htmlString
print(htmlString)

import WebKit
import PlaygroundSupport
let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
view.loadHTMLString(htmlString, baseURL: nil)
PlaygroundPage.current.liveView = view



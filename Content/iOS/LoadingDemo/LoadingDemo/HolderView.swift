//
//  HolderView.swift
//  LoadingDemo
//
//  Created by pmst on 2018/8/20.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

protocol HolderViewDelegate:class {
    func animateLabel()
}

class HolderView: UIView {

    var parentFrame :CGRect = CGRect.zero
    weak var delegate:HolderViewDelegate?
    let ovalLayer = OvalLayer()
    let triangleLayer = TriangleLayer()
    let redRectangleLayer = RectangleLayer()
    let blueRectangleLayer = RectangleLayer()
    let arcLayer = ArcLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.clear
    }
    
    func addOval(){
        layer.addSublayer(ovalLayer)
        ovalLayer.expand()
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(wobbleOval), userInfo: nil, repeats: false)
    }
    
    @objc func wobbleOval(){
        layer.addSublayer(triangleLayer)
        ovalLayer.wobble()
        
        Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(drawAnimatedTriangle), userInfo: nil, repeats: false)
        
    }
    
    @objc func drawAnimatedTriangle(){
        triangleLayer.animate()
        Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(spinAndTransform), userInfo: nil, repeats: false)
        
    }
    
    @objc func spinAndTransform(){
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.6)
        // 2
        var rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(.pi * 2.0)
        rotationAnimation.duration = 0.45
        rotationAnimation.isRemovedOnCompletion = true
        layer.add(rotationAnimation, forKey: nil)
        
        // 3
        ovalLayer.contract()
        
        Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(drawRedAnimatedRectangle), userInfo: nil, repeats: false)
        
        Timer.scheduledTimer(timeInterval: 0.65, target: self, selector: #selector(drawBlueAnimatedRectangle), userInfo: nil, repeats: false)
    }
    
    @objc func drawRedAnimatedRectangle() {
        layer.addSublayer(redRectangleLayer)
        redRectangleLayer.animateStrokeWithColor(color: Colors.red)
    }
    
    @objc func drawBlueAnimatedRectangle() {
        layer.addSublayer(blueRectangleLayer)
        blueRectangleLayer.animateStrokeWithColor(color: Colors.blue)
        
        Timer.scheduledTimer(timeInterval: 0.40, target: self, selector: #selector(drawArc), userInfo: nil, repeats: false)
    }
    
    @objc func drawArc(){
        layer.addSublayer(arcLayer)
        arcLayer.animate()
        
        Timer.scheduledTimer(timeInterval: 0.90, target: self, selector: #selector(expandView), userInfo: nil, repeats: false)
    }
    
    @objc func expandView(){
        // 1
        backgroundColor = Colors.blue
        
        // 2

        frame = CGRect(x: frame.origin.x - blueRectangleLayer.lineWidth, y: frame.origin.y - blueRectangleLayer.lineWidth, width: frame.size.width + blueRectangleLayer.lineWidth * 2, height: frame.size.height + blueRectangleLayer.lineWidth * 2)
        
        // 3
        layer.sublayers = nil
        
        // 4
        UIView.animate(withDuration:0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.frame = self.parentFrame
        }, completion: { finished in
            self.addLabel()
        })
    }
    
    func addLabel(){
        delegate?.animateLabel()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

}

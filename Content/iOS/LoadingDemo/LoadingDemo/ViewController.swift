//
//  ViewController.swift
//  LoadingDemo
//
//  Created by pmst on 2018/8/20.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class ViewController: UIViewController,HolderViewDelegate{

    var holderView = HolderView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()
        holderView.addOval()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addHolderView() {
        let boxSize: CGFloat = 100.0
        holderView.frame = CGRect(x: view.bounds.width / 2 - boxSize / 2,
                                  y: view.bounds.height / 2 - boxSize / 2,
                                  width: boxSize,
                                  height: boxSize)
        holderView.parentFrame = view.frame
        holderView.delegate = self
        view.addSubview(holderView)
    }
    
    func animateLabel() {
        // 1
        holderView.removeFromSuperview()
        view.backgroundColor = Colors.blue
        
        // 2
        var label: UILabel = UILabel(frame: view.frame)
        label.textColor = Colors.white
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 170.0)
        label.textAlignment = NSTextAlignment.center
        label.text = "S"
        label.transform = label.transform.scaledBy(x: 0.25, y: 0.25)
        view.addSubview(label)
        
        // 3
        UIView.animate(withDuration:0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseInOut,
                                   animations: ({
                                    label.transform = label.transform.scaledBy(x: 4.0, y: 4.0)
                                   }), completion: { finished in
                                    self.addButton()
        })
    }
    
    func addButton() {
        let button = UIButton()
        button.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func buttonPressed(sender: UIButton!) {
        view.backgroundColor = Colors.white
        view.subviews.map({ $0.removeFromSuperview() })
        holderView = HolderView(frame: CGRect.zero)
        addHolderView()
    }

}

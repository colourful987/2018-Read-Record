//
//  ViewController.swift
//  PTMarkdown
//
//  Created by pmst on 2018/9/22.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  var textView: UITextView!
  var textStorage: PTMarkdownSyntaxTextStorage!
  var contents : String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createTextView()
    textView.isScrollEnabled = true
    navigationController?.navigationBar.barStyle = .black
    textView.adjustsFontForContentSizeCategory = true
    
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardDidShow),
                                           name: UIResponder.keyboardDidShowNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardDidHide),
                                           name: UIResponder.keyboardDidHideNotification,
                                           object: nil)
  }

  func createTextView() {
    // 1
    let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
    let attrString = NSAttributedString(string: contents, attributes: attrs)
    textStorage = PTMarkdownSyntaxTextStorage()
    textStorage.append(attrString)
    
    let newTextViewRect = view.bounds
    
    // 2
    let layoutManager = NSLayoutManager()
    
    // 3
    let containerSize = CGSize(width: newTextViewRect.width, height: .greatestFiniteMagnitude)
    let container = NSTextContainer(size: containerSize)
    container.widthTracksTextView = true
    layoutManager.addTextContainer(container)
    textStorage.addLayoutManager(layoutManager)
    
    // 4
    textView = UITextView(frame: newTextViewRect, textContainer: container)
    textView.delegate = self
    view.addSubview(textView)
    
    // 5
    textView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      textView.topAnchor.constraint(equalTo: view.topAnchor),
      textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
  }
  
  override func viewDidLayoutSubviews() {
    textStorage.update()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  func updateTextViewSizeForKeyboardHeight(keyboardHeight: CGFloat) {
    textView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardHeight)
  }
  @objc func keyboardDidShow(notification: NSNotification) {
    if let rectValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
      let keyboardSize = rectValue.cgRectValue.size
      updateTextViewSizeForKeyboardHeight(keyboardHeight: keyboardSize.height)
    }
  }
  
  @objc func keyboardDidHide(notification: NSNotification) {
    updateTextViewSizeForKeyboardHeight(keyboardHeight: 0)
  }
}

// MARK: - UITextViewDelegate
extension ViewController: UITextViewDelegate {
  func textViewDidEndEditing(_ textView: UITextView) {
    contents = textView.text
  }
}


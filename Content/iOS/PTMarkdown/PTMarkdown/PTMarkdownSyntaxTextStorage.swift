//
//  PTMarkdownSyntaxTextStorage.swift
//  PTMarkdown
//
//  Created by pmst on 2018/9/22.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class PTMarkdownSyntaxTextStorage: NSTextStorage {
  let backingStore = NSMutableAttributedString()
  private var replacements : [String:[NSAttributedString.Key:Any]] = [:]
  
  override var string : String {
    return backingStore.string
  }
  
  override init() {
    super.init()
    
    createHighlightPatterns()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func attributes(at location: Int, effectiveRange range:
  NSRangePointer?) -> [NSAttributedString.Key: Any] {
    return backingStore.attributes(at: location, effectiveRange: range)
  }
  
  override func replaceCharacters(in range: NSRange, with str: String) {
    beginEditing()
    backingStore.replaceCharacters(in: range, with:str)
    edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    endEditing()
  }
  
  override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
    beginEditing()
    backingStore.setAttributes(attrs, range: range)
    edited(.editedAttributes, range: range, changeInLength: 0)
    endEditing()
  }
  
  override func processEditing() {
    performReplacementsForRange(changedRange: editedRange)
    super.processEditing()
  }
  
  func applyStylesToRange(searchRange:NSRange) {
    let normalAttrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
    addAttributes(normalAttrs, range: searchRange)
    
    for (pattern, attributes) in replacements {
      do {
          let regex = try NSRegularExpression(pattern: pattern)
        regex.enumerateMatches(in: backingStore.string, options: [], range: searchRange) { match, flags, stop in
          if let matchRange = match?.range(at: 1) {
            addAttributes(attributes, range: matchRange)
            
            let maxRange = matchRange.location + matchRange.length
            if maxRange + 1 < length {
              addAttributes(normalAttrs, range: NSMakeRange(maxRange, 1))
            }
          }
        }
      } catch {
        print("An error occurred attempting to locate pattern:\(error.localizedDescription)")
      }
    }
  }
  
  func performReplacementsForRange(changedRange: NSRange) {
    // 第一个字所在的行
    var extendedRange =
      NSUnionRange(changedRange,
                   NSString(string: backingStore.string).lineRange(for: NSMakeRange(changedRange.location, 0)))
    // 最后一个字所在的行，然后两者union求汇总的range
    extendedRange =
      NSUnionRange(changedRange,
                   NSString(string: backingStore.string).lineRange(for: NSMakeRange(NSMaxRange(changedRange), 0)))
    applyStylesToRange(searchRange: extendedRange)
  }

  func createAttributesForFontStyle(_ style: UIFont.TextStyle, withTrait trait: UIFontDescriptor.SymbolicTraits) -> [NSAttributedString.Key: Any] {
    let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
    let descriptorWithTrait = fontDescriptor.withSymbolicTraits(trait)
    let font = UIFont(descriptor: descriptorWithTrait!, size: 0)
    return [.font: font]
  }
  
  func createHighlightPatterns() {
    /**
     Simple markdown Syntax:
     # 一级标题 ## 二级标题 以此类推
     **加粗文字**
     *斜体文字*
     ~加删除线的文字~
     `代码`
     */
    
    // 1. 创建markdown语法对应的字体样式
    // head 语法 更改字体大小即可
    let head1Attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 40)]
    let head2Attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 30)]
    // 黑体加粗 语法:**加粗文字**
    let boldAttributes = createAttributesForFontStyle(.body, withTrait:.traitBold)
    // 斜体 语法：*斜体文字*
    let italicAttributes = createAttributesForFontStyle(.body, withTrait:.traitItalic)
    // 删除线 ~加删除线的文字~
    let strikeThroughAttributes =  [NSAttributedString.Key.strikethroughStyle: 1]
    // `代码`
    let codeGrammerTextAttributes = [NSAttributedString.Key.backgroundColor: UIColor.lightGray]
    
    // 2. construct a dictionary of replacements based on regexes
    replacements = [
      "(#[^#]*)": head1Attributes, // 一级标题
      "(##.*)": head2Attributes,// 二级标题
      "(\\*\\*\\w+(\\s\\w+)*\\*\\*)": boldAttributes, // 黑体
      "(\\*[^\\*]*\\*)": italicAttributes, // 斜体
      "(~\\w+(\\s\\w+)*~)": strikeThroughAttributes, // 删除线
      "(`\\w+(\\s\\w+)*`)": codeGrammerTextAttributes, // 代码
    ]
  }
  
  func update() {
    let bodyFont = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
    addAttributes(bodyFont, range: NSMakeRange(0, length))
    
    createHighlightPatterns()
    applyStylesToRange(searchRange: NSMakeRange(0, length))
  }

}

//
//  Book.swift
//  BookTutorial
//
//  Created by pmst on 2018/8/21.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class Book {
    
    convenience init (dict: NSDictionary) {
        self.init()
        self.dict = dict
    }
    
    var dict: NSDictionary?
    
    func coverImage () -> UIImage? {
        if let cover = dict?["cover"] as? String {
            return UIImage(named: cover)
        }
        return nil
    }
    
    func pageImage (index: Int) -> UIImage? {
        if let pages = dict?["pages"] as? NSArray {
            if let page = pages[index] as? String {
                return UIImage(named: page)
            }
        }
        return nil
    }
    
    func numberOfPages () -> Int {
        if let pages = dict?["pages"] as? NSArray {
            return pages.count
        }
        return 0
    }
    
}

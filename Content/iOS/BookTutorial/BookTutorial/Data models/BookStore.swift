//
//  BookStore.swift
//  BookTutorial
//
//  Created by pmst on 2018/8/21.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BookStore {
    
    class var sharedInstance : BookStore {
        return BookStore()
    }
    
    func loadBooks(plist: String) -> [Book] {
        var books: [Book] = []
        
        if let path = Bundle.main.path(forResource:plist, ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                for dict in array as! [NSDictionary] {
                    let book = Book(dict: dict)
                    books += [book]
                }
            }
        }
        
        return books
    }
    
}

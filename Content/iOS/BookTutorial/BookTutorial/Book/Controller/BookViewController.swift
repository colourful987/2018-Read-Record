//
//  BookViewController.swift
//  BookTutorial
//
//  Created by pmst on 2018/8/21.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BookViewController: UICollectionViewController {
    
    var book: Book? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
}

// MARK: UICollectionViewDataSource

extension BookViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let book = book {
            return book.numberOfPages() + 1
        }
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"BookPageCell" , for: indexPath) as! BookPageCell
        
        if indexPath.row == 0 {
            // Cover page
            cell.textLabel.text = nil
            cell.image = book?.coverImage()
        }
            
        else {
            // Page with index: indexPath.row - 1
            cell.textLabel.text = "\(indexPath.row)"
            cell.image = book?.pageImage(index: indexPath.row - 1)
        }
        
        return cell
    }
    
}

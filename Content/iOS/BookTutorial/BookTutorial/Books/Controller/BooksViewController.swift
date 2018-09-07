//
//  BooksViewController.swift
//  BookTutorial
//
//  Created by pmst on 2018/8/21.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BooksViewController: UICollectionViewController {
    
    var books: Array<Book>? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedInstance.loadBooks(plist: "Books")
    }
    
    // MARK: Helpers
    
    func openBook() {
        let vc = storyboard?.instantiateViewController(withIdentifier:"BookViewController") as! BookViewController
        vc.book = selectedCell()?.book
        // UICollectionView loads it's cells on a background thread, so make sure it's loaded before passing it to the animation handler
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    func selectedCell()->BookCoverCell? {
        if let indexPath = collectionView?.indexPathForItem(at: CGPoint(x: collectionView!.contentOffset.x + collectionView!.bounds.width/2, y: collectionView!.bounds.height/2)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? BookCoverCell {
                return cell
            }
        }
        return nil
    }
    
    
    
}

// MARK: UICollectionViewDelegate

extension BooksViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openBook()
    }
    
}

// MARK: UICollectionViewDataSource

extension BooksViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let books = books {
            return books.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"BookCoverCell" , for: indexPath as IndexPath) as! BookCoverCell
        
        cell.book = books?[indexPath.row]
        
        return cell
    }
    
}

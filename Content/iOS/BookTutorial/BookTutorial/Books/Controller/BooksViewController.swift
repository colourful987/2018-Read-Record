//
//  BooksViewController.swift
//  BookTutorial
//
//  Created by pmst on 2018/8/21.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BooksViewController: UICollectionViewController {
    var transition:BookOpeningTransition?
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    // 添加双指捏合手势
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    var books: Array<Book>? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedInstance.loadBooks(plist: "Books")
        recognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:)))
    }

    @objc func handlePinch(recognizer:UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            if recognizer.scale >= 1 {
                if recognizer.view == collectionView {
                    var book = self.selectedCell()?.book
                    self.openBook()
                }
            } else {
                navigationController?.popViewController(animated: true)
            }
        case .changed:
            if transition!.isPush {
                let progress = min(max(abs((recognizer.scale - 1)) / 5, 0), 1)
                interactionController?.update(progress)
            } else {
                var progress = min(max(abs((1 - recognizer.scale)), 0), 1)
                interactionController?.update(progress)
            }
        case .ended:
            interactionController?.finish()
            interactionController = nil
        default:
            break
        }
    }
    // MARK: Helpers
    
    func openBook() {
        let vc = storyboard?.instantiateViewController(withIdentifier:"BookViewController") as! BookViewController
        vc.book = selectedCell()?.book
        // UICollectionView loads it's cells on a background thread, so make sure it's loaded before passing it to the animation handler
        vc.view.snapshotView(afterScreenUpdates: true)
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

extension BooksViewController {
    func animationControllerForPresentController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 1
        let transition = BookOpeningTransition()
        // 2
        transition.isPush = true
        transition.interactionController = interactionController
        // 3
        self.transition = transition
        // 4
        return transition 
    }
    
    func animationControllerForDismissController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = false
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
}

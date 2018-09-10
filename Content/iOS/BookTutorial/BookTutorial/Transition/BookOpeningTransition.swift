//
//  BookOpeningTransition.swift
//  BookTutorial
//
//  Created by pmst on 2018/9/10.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BookOpeningTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var interactionController:UIPercentDrivenInteractiveTransition?
    
    var transforms = [UICollectionViewCell: CATransform3D]()
    var toViewBackgroundColor: UIColor?
    var isPush = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        if isPush {
            let fromVC = transitionContext.viewController(forKey: .from) as! BooksViewController
            let toVC = transitionContext.viewController(forKey: .to) as! BookViewController
            
            container.addSubview(toVC.view) // always add toVC.view is right
            self.setStartPositionForPush(fromVC: fromVC, toVC: toVC)// 书本都收起来
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
                self.setEndPositionForPush(fromVC: fromVC, toVC: toVC)
            }) { finished in
                self.cleanupPush(fromVC: fromVC, toVC: toVC)
                toVC.recognizer = fromVC.recognizer
                transitionContext.completeTransition(finished)
            }
        } else {
            let fromVC = transitionContext.viewController(forKey: .from) as! BookViewController
            let toVC = transitionContext.viewController(forKey: .to) as! BooksViewController
            
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            setStartPositionForPop(fromVC: fromVC, toVC: toVC)
            UIView.animate(withDuration:self.transitionDuration(using: transitionContext), animations: {
                self.setEndPositionForPop(fromVC: fromVC, toVC: toVC)
            }, completion: { finished in
                self.cleanupPop(fromVC: fromVC, toVC: toVC)
                toVC.recognizer = fromVC.recognizer
                transitionContext.completeTransition(finished)
            })

        }
    }
    
    func setStartPositionForPop(fromVC: BookViewController, toVC: BooksViewController) {
        // Remove background from the pushed view controller
        toViewBackgroundColor = fromVC.collectionView?.backgroundColor
        fromVC.collectionView?.backgroundColor = nil
    }
    
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000
        return transform
    }
    
    func closePageCell(cell : BookPageCell) {
        var transform = self.makePerspectiveTransform()
        
        if cell.layer.anchorPoint.x == 0 {
            transform = CATransform3DRotate(transform, CGFloat(0), 0, 1, 0)
            transform = CATransform3DTranslate(transform, -0.7 * cell.layer.bounds.width / 2, 0, 0)
            transform = CATransform3DScale(transform, 0.7, 0.7, 1)
        } else {
            transform = CATransform3DRotate(transform, CGFloat(-Double.pi), 0, 1, 0)
            transform = CATransform3DTranslate(transform, 0.7 * cell.layer.bounds.width / 2, 0, 0)
            transform = CATransform3DScale(transform, 0.7, 0.7, 1)
        }
        cell.layer.transform = transform
    }
    
    // 设置push的起始状态 书页都是close的状态
    func setStartPositionForPush(fromVC: BooksViewController, toVC: BookViewController) {
        
        toViewBackgroundColor = fromVC.collectionView?.backgroundColor
        toVC.collectionView?.backgroundColor = nil
        
        fromVC.selectedCell()?.alpha = 0
        
        for cell in toVC.collectionView!.visibleCells as! [BookPageCell] {

            transforms[cell] = cell.layer.transform

            closePageCell(cell: cell)
            cell.updateShadowLayer()
            if let indexPath = toVC.collectionView?.indexPath(for:cell) {
                if indexPath.row == 0 {
                    cell.shadowLayer.opacity = 0
                }
            }
        }
    }
    
    func setEndPositionForPush(fromVC: BooksViewController, toVC: BookViewController) {
        //1
        for cell in fromVC.collectionView!.visibleCells as! [BookCoverCell] {
            cell.alpha = 0
        }
        
        //2
        for cell in toVC.collectionView!.visibleCells as! [BookPageCell] {
            cell.layer.transform = transforms[cell]!
            cell.updateShadowLayer(animated: true)
        }
    }
    
    func cleanupPush(fromVC: BooksViewController, toVC: BookViewController) {
        // Add background back to pushed view controller
        toVC.collectionView?.backgroundColor = toViewBackgroundColor
    }
    
    func setEndPositionForPop(fromVC: BookViewController, toVC: BooksViewController) {
        //1
        let coverCell = toVC.selectedCell()
        //2
        for cell in toVC.collectionView!.visibleCells as! [BookCoverCell] {
            if cell != coverCell {
                cell.alpha = 1
            }
        }
        //3
        for cell in fromVC.collectionView!.visibleCells as! [BookPageCell] {
            closePageCell(cell: cell)
        }
    }
    
    func cleanupPop(fromVC: BookViewController, toVC: BooksViewController) {
        // Add background back to pushed view controller
        fromVC.collectionView?.backgroundColor = self.toViewBackgroundColor
        // Unhide the original book cover
        toVC.selectedCell()?.alpha = 1
    }
}

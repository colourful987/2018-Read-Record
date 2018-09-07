//
//  BooksLayout.swift
//  BookTutorial
//
//  Created by pmst on 2018/8/21.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BooksLayout: UICollectionViewFlowLayout {
    private let PageWidth : CGFloat = 362
    private let PageHeight : CGFloat = 568
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        scrollDirection = .horizontal
        itemSize = CGSize(width: PageWidth, height: PageHeight)
        minimumInteritemSpacing = 10
    }
    
    override func prepare() {
        super.prepare()
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        
        collectionView?.contentInset = UIEdgeInsets(
            top: 0,
            left: collectionView!.bounds.width/2 - PageWidth/2,
            bottom:0 ,
            right: collectionView!.bounds.width/2 - PageWidth/2)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let array = super.layoutAttributesForElements(in: rect) as! [UICollectionViewLayoutAttributes]
        
        for attributes in array {

            let frame = attributes.frame
            let distance = abs(collectionView!.contentOffset.x + collectionView!.contentInset.left - frame.origin.x)

            let scale = 0.7 * min(max(1 - distance / (collectionView!.bounds.width), 0.75), 1)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        return array
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // 确定collectionView 应该在哪个点stop 然后返回一个合适的collection的contentoffset
    // 如果不override 那么就返回默认的 offset
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var newOffset = CGPoint()
        var layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        var width = layout.itemSize.width + layout.minimumInteritemSpacing
        var offset = proposedContentOffset.x + collectionView!.contentInset.left
        
        //5
        if velocity.x > 0 {
            //ceil returns next biggest number
            offset = width * ceil(offset / width)
        } else if velocity.x == 0 { //6
            //rounds the argument
            offset = width * round(offset / width)
        } else if velocity.x < 0 { //7
            //removes decimal part of argument
            offset = width * floor(offset / width)
        }
        //8
        newOffset.x = offset - collectionView!.contentInset.left
        newOffset.y = proposedContentOffset.y //y will always be the same...
        return newOffset
    }
}

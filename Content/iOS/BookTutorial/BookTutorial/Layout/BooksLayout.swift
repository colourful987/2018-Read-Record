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
}

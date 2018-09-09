//
//  BookLayout.swift
//  BookTutorial
//
//  Created by pmst on 2018/9/7.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BookLayout: UICollectionViewFlowLayout {
    private let PageWidth: CGFloat = 362
    private let PageHeight: CGFloat = 568
    private var numberOfItems = 0
    
    
    override func prepare() {
        super.prepare()
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        numberOfItems = collectionView!.numberOfItems(inSection: 0)
        collectionView?.isPagingEnabled = true
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(numberOfItems/2) * collectionView!.bounds.width, height: collectionView!.bounds.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array:[UICollectionViewLayoutAttributes] = []
        
        for i in 0...max(0, numberOfItems-1){
            let indexPath = IndexPath(item: i, section: 0)
            let attributes = layoutAttributesForItem(at: indexPath)
            
            if attributes != nil {
                array += [attributes!]
            }
        }
        
        return array
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //1
        var layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        //2  设置一页书的大小 362 568，frame 每一页都不同
        var frame = getFrame(collectionView: collectionView!)
        layoutAttributes.frame = frame
        
        //3
        var ratio = getRatio(collectionView: collectionView!, indexPath: indexPath as NSIndexPath)
        
        //4 这里还有个技巧就是左边的都是奇数页 1 3 5 ... 可见
        // 右边的都是 2 4 6 8 可见
        if ratio > 0 && indexPath.item % 2 == 1
            || ratio < 0 && indexPath.item % 2 == 0 {
            // Make sure the cover is always visible
            if indexPath.row != 0 {
                return nil
            }
        }
//        print("indexpath :\(indexPath.item)")
        //5
        var rotation = getRotation(indexPath: indexPath as NSIndexPath, ratio: min(max(ratio, -1), 1))
        layoutAttributes.transform3D = rotation
        
        //6
        if indexPath.row == 0 {
            layoutAttributes.zIndex = Int.max
        }
        
        return layoutAttributes
    }
    
    func getFrame(collectionView: UICollectionView) -> CGRect {
        var frame = CGRect()
        
        frame.origin.x = (collectionView.bounds.width / 2) - (PageWidth / 2) + collectionView.contentOffset.x
        frame.origin.y = (collectionView.contentSize.height - PageHeight) / 2
        frame.size.width = PageWidth
        frame.size.height = PageHeight
        
        return frame
    }
    
    func getRatio(collectionView: UICollectionView, indexPath: NSIndexPath) -> CGFloat {
        //1 获取页码 其实这里的算法过于奇怪 还不如直接 index.item/2 就可以了 page为int类型
        // i indexPath 对应的页码！！！
        let page = CGFloat(indexPath.item - indexPath.item % 2) * 0.5
        
        //2 ratio范围[-1.0,1.0] 就是摊开的一本书 0.0对应垂直书本，而-0.5 和 0.5对应45°角的页码
        // 一开始进来对应的是第0页，所以这个初始值是0.5（当然后面一步还会校准），以这个为基准
        // 这里尼玛有个坑啊！ pageWidth = collectionView.bounds.width/2
        // 即当前屏幕整flow布局时候是放两页书的
        var ratio: CGFloat = -0.5 + page - (collectionView.contentOffset.x / collectionView.bounds.width)
//        print("==========================")
//        print("indexPath:\(indexPath.item)")
//        print("page:\(page)")
//        print("滑动offset.x\(collectionView.contentOffset.x)")
//        print("偏移除以宽度\(collectionView.contentOffset.x / collectionView.bounds.width)")
//        print("ratio:\(ratio)")
//        print("==========================")
        //3
        if ratio > 0.5 {
            ratio = 0.5 + 0.1 * (ratio - 0.5)
            
        } else if ratio < -0.5 {
            ratio = -0.5 + 0.1 * (ratio + 0.5)
        }
        
        return ratio
    }
    
    func getAngle(indexPath: NSIndexPath, ratio: CGFloat) -> CGFloat {
        // Set rotation
        var angle: CGFloat = 0
        
        //1 要知道当前屏幕的两页(正面和反面) 它们的 ratio 是一样的！
        // 关键是奇数页和偶数页怎么旋转 保证和现实中的翻页是一致的
        // 比如书页在左边时，正面内容朝下是看不见的 反面内容朝上是看的见的
        // 弧度和度单位的转换
        // 垂直方向的pi/2（90°）或者-pi/2 为界限进行
        // 左边和右边的锚点是不一样的 也就是按照y轴旋转的锚点更多请看 anchorpoint
        if indexPath.item % 2 == 0 {
            // 左边的页
            // The book's spine is on the left of the page
            angle = (1-ratio) * CGFloat(-(Double.pi/2))
        } else {
            // 右边的页
            // The book's spine is on the right of the page
            angle = (1 + ratio) * CGFloat(Double.pi/2)
        }
        print("==========================")
        print("indexPath:\(indexPath.item)")
        print("angle:\(angle)")
        print("==========================")
        //3
        // Make sure the odd and even page don't have the exact same angle
        angle += CGFloat(indexPath.row % 2) / 1000
        //4
        return angle
    }
    
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000
        return transform
    }
    
    func getRotation(indexPath: NSIndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = makePerspectiveTransform()
        let angle = getAngle(indexPath: indexPath, ratio: ratio)
        transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        return transform
    }
}

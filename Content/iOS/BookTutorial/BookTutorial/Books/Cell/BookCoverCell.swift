//
//  BookCoverCell.swift
//  BookTutorial
//
//  Created by pmst on 2018/8/21.
//  Copyright © 2018 pmst. All rights reserved.
//

import UIKit

class BookCoverCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var book: Book? {
        didSet {
            image = book?.coverImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            let corners: UIRectCorner = [.topRight , .bottomRight]
            imageView.image = image!.imageByScalingAndCroppingForSize(targetSize:bounds.size).imageWithRoundedCornersSize(cornerRadius: 20, corners: corners)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

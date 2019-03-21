//
//  LocalImageCell.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/21.
//  Copyright © 2019 bestdew. All rights reserved.
//

import UIKit

class LocalImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if imageView.frame.contains(point) {
            return super.hitTest(point, with: event)
        }
        return nil
    }
}

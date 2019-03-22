//
//  ZKCycleScrollViewFlowLayout.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/22.
//  Copyright © 2019 bestdew. All rights reserved.
//

import UIKit

open class ZKCycleScrollViewFlowLayout: UICollectionViewFlowLayout {

    open var zoomFactor: CGFloat = 0.0
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes: [UICollectionViewLayoutAttributes] = NSArray(array: super.layoutAttributesForElements(in: rect) ?? [], copyItems: true) as! [UICollectionViewLayoutAttributes]
        if let collectionView = collectionView {
            switch scrollDirection {
            case .vertical:
                let centerY = collectionView.contentOffset.y + collectionView.bounds.height / 2
                for attr in attributes {
                    let distance = abs(attr.center.y - centerY)
                    let scale = 1 / (1 + distance * zoomFactor)
                    attr.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            default:
                let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
                for attr in attributes {
                    let distance = abs(attr.center.x - centerX)
                    let scale = 1 / (1 + distance * zoomFactor)
                    attr.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
        return attributes
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

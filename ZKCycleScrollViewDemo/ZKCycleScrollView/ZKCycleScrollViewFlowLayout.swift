//
//  ZKCycleScrollViewFlowLayout.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/22.
//  Copyright © 2019 bestdew. All rights reserved.
//
//                      d*##$.
// zP"""""$e.           $"    $o
//4$       '$          $"      $
//'$        '$        J$       $F
// 'b        $k       $>       $
//  $k        $r     J$       d$
//  '$         $     $"       $~
//   '$        "$   '$E       $
//    $         $L   $"      $F ...
//     $.       4B   $      $$$*"""*b
//     '$        $.  $$     $$      $F
//      "$       R$  $F     $"      $
//       $k      ?$ u*     dF      .$
//       ^$.      $$"     z$      u$$$$e
//        #$b             $E.dW@e$"    ?$
//         #$           .o$$# d$$$$c    ?F
//          $      .d$$#" . zo$>   #$r .uF
//          $L .u$*"      $&$$$k   .$$d$$F
//           $$"            ""^"$$$P"$P9$
//          JP              .o$$$$u:$P $$
//          $          ..ue$"      ""  $"
//         d$          $F              $
//         $$     ....udE             4B
//          #$    """"` $r            @$
//           ^$L        '$            $F
//             RN        4N           $
//              *$b                  d$
//               $$k                 $F
//               $$b                $F
//                 $""               $F
//                 '$                $
//                  $L               $
//                  '$               $
//                   $               $

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

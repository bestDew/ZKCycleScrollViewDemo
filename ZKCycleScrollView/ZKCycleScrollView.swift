//
//  ZKCycleScrollView.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/8.
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

public typealias ZKCycleScrollViewCell = UICollectionViewCell

public enum ZKScrollDirection: Int {
    case horizontal
    case vertical
}

public protocol ZKCycleScrollViewDataSource: NSObjectProtocol {
    /// Return number of pages
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int
    /// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndex:
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt index: Int) -> ZKCycleScrollViewCell
}

@objc public protocol ZKCycleScrollViewDelegate: NSObjectProtocol {
    /// Called when the cell is clicked
    @objc optional func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt index: Int)
    /// Called when the offset changes. The progress range is from 0 to the maximum index value, which means the progress value for a round of scrolling
    @objc optional func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView, progress: Double)
    /// Called when scrolling to a new index page
    @objc optional func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didScrollFromIndex fromIndex: Int, toIndex: Int)
}

open class ZKCycleScrollView: UIView {
    
    open weak var delegate: ZKCycleScrollViewDelegate?
    open weak var dataSource: ZKCycleScrollViewDataSource?

    /// default horizontal. scroll direction
    open var scrollDirection: ZKScrollDirection = .horizontal {
        didSet {
            switch scrollDirection {
            case .vertical:
                flowLayout?.scrollDirection = .vertical
            default:
                flowLayout?.scrollDirection = .horizontal
            }
        }
    }
    /// default 3.f. automatic scroll time interval
    open var autoScrollInterval: TimeInterval = 3 {
        didSet {
            addTimer()
        }
    }
    open var isAutoScroll: Bool = true {
        didSet {
            addTimer()
        }
    }
    /// default true. turn off any dragging temporarily
    open var allowsDragging: Bool = true {
        didSet {
            collectionView.isScrollEnabled = allowsDragging
        }
    }
     /// default the view size
    open var itemSize: CGSize = CGSize.zero {
        didSet {
            itemSizeFlag = true
            flowLayout.itemSize = itemSize
            flowLayout.headerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
            flowLayout.footerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
        }
    }
    /// default 0.0
    open var itemSpacing: CGFloat = 0.0 {
        didSet {
            flowLayout.minimumLineSpacing = itemSpacing
        }
    }
    /// default 1.f(no scaling), it ranges from 0.f to 1.f
    open var itemZoomScale: CGFloat = 1.0 {
        didSet {
            flowLayout.zoomScale = itemZoomScale
        }
    }
    
    open var hidesPageControl: Bool = false {
        didSet {
            pageControl?.isHidden = hidesPageControl
        }
    }
    open var pageIndicatorTintColor: UIColor = UIColor.gray {
        didSet {
            pageControl?.pageIndicatorTintColor = pageIndicatorTintColor
        }
    }
    open var currentPageIndicatorTintColor: UIColor = UIColor.white {
        didSet {
            pageControl?.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    /// current page index
    open var pageIndex: Int {
        return changeIndex(currentIndex())
    }
    /// current content offset
    open var contentOffset: CGPoint {
        switch scrollDirection {
        case .vertical:
            return CGPoint(x: 0.0, y: max(0.0, collectionView.contentOffset.y - (flowLayout.itemSize.height + flowLayout.minimumLineSpacing) * 2))
        default:
            return CGPoint(x: max(0.0, collectionView.contentOffset.x - (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * 2), y: 0.0)
        }
    }
    /// load completed callback
    open var loadCompletion: (() -> Void)? = nil
    
    private var pageControl: UIPageControl!
    private var collectionView: UICollectionView!
    private var flowLayout: ZKCycleScrollViewFlowLayout!
    private var timer: Timer?
    private var numberOfItems: Int = 0
    private var fromIndex: Int = 0
    private var itemSizeFlag: Bool = false
    private var indexOffset: Int = 0
    
    // MARK: - Open Func
    open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> ZKCycleScrollViewCell {
        let indexPath = IndexPath(item: changeIndex(index), section: 0)
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    open func reloadData() {
        removeTimer()
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        collectionView.performBatchUpdates(nil) { _ in
            self.configuration()
            self.loadCompletion?()
        }
    }
    
    open func adjustWhenViewWillAppear() {
        guard numberOfItems > 1 else { return }
        
        var index = currentIndex()
        let position = scrollPosition()
        if index == 1 {
            index = numberOfItems - 3
        } else if index == numberOfItems - 2 {
            index = 2
        }
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: false)
    }
    
    // MARK: - Override Func
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialization()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if itemSizeFlag {
            flowLayout.itemSize = itemSize
            flowLayout.headerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
            flowLayout.footerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
        } else {
            flowLayout.itemSize = bounds.size
            flowLayout.headerReferenceSize = CGSize.zero
            flowLayout.footerReferenceSize = CGSize.zero
        }
        collectionView.frame = bounds
        pageControl.frame = CGRect(x: 0.0, y: bounds.height - 15.0, width: bounds.width, height: 15.0)
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil { removeTimer() }
    }
    
    deinit {
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    // MARK: - Private Func
    private func initialization() {
        flowLayout = ZKCycleScrollViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        addSubview(pageControl);
        
        DispatchQueue.main.async {
            self.configuration()
            self.loadCompletion?()
        }
    }
    
    private func configuration() {
        fromIndex = 0
        indexOffset = 0
        
        guard numberOfItems > 1 else { return }
        
        let position = scrollPosition()
        let indexPath = IndexPath(item: 2, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        
        addTimer()
        updatePageControl()
    }
    
    private func addTimer() {
        removeTimer()
        
        if numberOfItems < 2 || !isAutoScroll || autoScrollInterval <= 0.0 { return }
        timer = Timer.scheduledTimer(timeInterval: autoScrollInterval, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updatePageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = max(0, numberOfItems - 4)
        pageControl.isHidden = (hidesPageControl || pageControl.numberOfPages < 2)
    }

    @objc private func automaticScroll() {
        let index = currentIndex() + 1
        let position = scrollPosition()
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: true)
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scrollPosition() -> UICollectionView.ScrollPosition {
        switch scrollDirection {
        case .vertical:
            return .centeredVertically
        default:
            return .centeredHorizontally
        }
    }
    
    private func currentIndex() -> Int {
        var index = 0
        
        if numberOfItems < 2 || bounds.width <= 0.0 || bounds.height <= 0.0 {
            return index
        }
        
        switch scrollDirection {
        case .vertical:
            index = Int((collectionView.contentOffset.y + (flowLayout.itemSize.height + flowLayout.minimumLineSpacing) / 2) / (flowLayout.itemSize.height + flowLayout.minimumLineSpacing))
        default:
            index = Int((collectionView.contentOffset.x + (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) / 2) / (flowLayout.itemSize.width + flowLayout.minimumLineSpacing))
        }
        return min(numberOfItems - 2, max(1, index))
    }
    
    private func changeIndex(_ index: Int) -> Int {
        guard numberOfItems > 1 else { return index }
        
        var idx = index
        
        if index == 0 {
            idx = numberOfItems - 6
        } else if index == 1 {
            idx = numberOfItems - 5
        } else if index == numberOfItems - 2 {
            idx = 0
        } else if index == numberOfItems - 1 {
            idx = 1
        } else {
            idx = index - 2
        }
        return idx
    }
}

extension ZKCycleScrollView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didSelectItemAt:))) {
            delegate.cycleScrollView!(self, didSelectItemAt: changeIndex(indexPath.item))
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = pageIndex
        
        var total: CGFloat = 0.0
        var offset: CGFloat = 0.0
        switch scrollDirection {
        case .vertical:
            total = CGFloat(numberOfItems - 5) * (flowLayout.itemSize.height + flowLayout.minimumLineSpacing)
            offset = contentOffset.y.truncatingRemainder(dividingBy:((flowLayout.itemSize.height + flowLayout.minimumLineSpacing) * CGFloat(numberOfItems - 4)))
        default:
            total = CGFloat(numberOfItems - 5) * (flowLayout.itemSize.width + flowLayout.minimumLineSpacing)
            offset = contentOffset.x.truncatingRemainder(dividingBy:((flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * CGFloat(numberOfItems - 4)))
        }
        let percent = Double(offset / total)
        let progress = percent * Double(numberOfItems - 5)
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollViewDidScroll(_:progress:))) {
            delegate.cycleScrollViewDidScroll!(self, progress: progress)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = currentIndex()
        if index == 1 {
            let position = scrollPosition()
            let indexPath = IndexPath(item: numberOfItems - 3, section: 0)
            collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        } else if index == numberOfItems - 2 {
            let position = scrollPosition()
            let indexPath = IndexPath(item: 2, section: 0)
            collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        }
        let toIndex = changeIndex(index)
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didScrollFromIndex:toIndex:))) {
            delegate.cycleScrollView!(self, didScrollFromIndex: fromIndex, toIndex: toIndex)
        }
        fromIndex = toIndex
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard pageIndex == fromIndex else { return }
        
        let sum = velocity.x + velocity.y
        if sum > 0 {
            indexOffset = 1
        } else if sum < 0 {
            indexOffset = -1
        } else {
            indexOffset = 0
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let position = scrollPosition()
        let index = currentIndex() + indexOffset
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: true)
        indexOffset = 0
    }
}

extension ZKCycleScrollView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
        if numberOfItems > 1 { numberOfItems += 4 }
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = changeIndex(indexPath.item)
        return (dataSource?.cycleScrollView(self, cellForItemAt: index))!
    }
}

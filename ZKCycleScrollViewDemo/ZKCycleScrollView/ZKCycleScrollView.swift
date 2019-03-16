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
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt indexPath: IndexPath) -> ZKCycleScrollViewCell
}

@objc public protocol ZKCycleScrollViewDelegate: NSObjectProtocol {
    @objc optional func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt indexPath: IndexPath)
    @objc optional func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView)
    @objc optional func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didScrollTo indexPath: IndexPath)
}

open class ZKCycleScrollView: UIView {

    open weak var delegate: ZKCycleScrollViewDelegate?
    open weak var dataSource: ZKCycleScrollViewDataSource?

    open var scrollDirection: ZKScrollDirection = .horizontal {
        didSet {
            switch scrollDirection {
            case .horizontal:
                flowLayout?.scrollDirection = .horizontal
            case .vertical:
                flowLayout?.scrollDirection = .vertical
            }
        }
    }
    open var isAutoScroll: Bool = true {
        didSet {
            if isAutoScroll {
                addTimer()
            } else {
                removeTimer()
            }
        }
    }
    /// default true. turn off any dragging temporarily
    open var isDragEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = isDragEnabled
        }
    }
    open var autoScrollDuration: TimeInterval = 3 {
        didSet {
            if isAutoScroll { addTimer() }
        }
    }
    open var contentOffset: CGPoint {
        return collectionView.contentOffset
    }
    open private(set) var pageControl = UIPageControl()

    private let numberOfSections: Int = 100
    private let kCellReuseId = "ZKCycleScrollViewCell"
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    private var timer: Timer?
    private var count: Int = 0
    
    // MARK: - Open Func
    open func register(cellClass: AnyClass?) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: kCellReuseId)
    }
    
    open func register(nib: UINib?) {
        collectionView.register(nib, forCellWithReuseIdentifier: kCellReuseId)
    }
    
    open func dequeueReusableCell(for indexPath: IndexPath) -> ZKCycleScrollViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseId, for: indexPath)
    }
    
    open func reloadData() {
        collectionView.reloadData()
        DispatchQueue.main.async { self.configuration() }
    }
    
    open func adjustWhenViewWillAppear() {
        if count <= 0 { return }
        let indexPath = currentIndexPath()
        guard indexPath.section < numberOfSections && indexPath.item < count else { return }
        let position = scrollPosition()
        collectionView.scrollToItem(at: indexPath, at: position, animated: false)
    }
    
    open func currentIndexPath() -> IndexPath {
        if bounds.width <= 0 || bounds.height <= 0 {
            return IndexPath(item: 0, section: 0)
        }
        var index: Int = 0
        switch scrollDirection {
        case .horizontal:
            index = Int((collectionView.contentOffset.x + flowLayout.itemSize.width / 2) / flowLayout.itemSize.width)
        case .vertical:
            index = Int((collectionView.contentOffset.y + flowLayout.itemSize.height / 2) / flowLayout.itemSize.height)
        }
        index = max(0, index)
        let section: Int = Int(index / count)
        let item: Int = Int(index % count)
        return IndexPath(item: item, section: section)
    }
    
    // MARK: - Override Func
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialization()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        initialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        flowLayout.itemSize = bounds.size
        collectionView.frame = bounds
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
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.headerReferenceSize = CGSize.zero
        flowLayout.footerReferenceSize = CGSize.zero
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        addSubview(pageControl);
        
        DispatchQueue.main.async { self.configuration() }
    }
    
    private func configuration() {
        addTimer()
        updatePageControl()
        
        let position = scrollPosition()
        let section = Int(numberOfSections / 2)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: section), at: position, animated: false)
        collectionView.isScrollEnabled = (count > 1 && isDragEnabled)
    }
    
    private func addTimer() {
        removeTimer()
        if count < 2 || !isAutoScroll { return }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(autoScrollDuration), target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updatePageControl() {
        let height: CGFloat = 15.0;
        let width: CGFloat = CGFloat(count * 15)
        let x: CGFloat = (bounds.width - width) / 2
        let y: CGFloat = bounds.height - height
        pageControl.frame = CGRect(x: x, y: y, width: width, height: height)
        pageControl.currentPage = 0
        pageControl.numberOfPages = count
    }

    @objc private func automaticScroll() {
        let section: Int = currentIndexPath().section
        let item: Int = currentIndexPath().item
        let position = scrollPosition()
        var targetIndexPath: IndexPath!
        var animated: Bool!
        
        if section < numberOfSections - 1 {
            if item < count - 1 {
                targetIndexPath = IndexPath(item: item + 1, section: section)
            } else {
                targetIndexPath = IndexPath(item: 0, section: section + 1)
            }
            animated = true
        } else {
            if item < count - 1 {
                targetIndexPath = IndexPath(item: item + 1, section: section)
                animated = true
            } else {
                let sec = Int(numberOfSections / 2)
                targetIndexPath = IndexPath(item: 0, section: sec)
                animated = false
            }
        }
        collectionView.scrollToItem(at: targetIndexPath, at: position, animated: animated)
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scrollPosition() -> UICollectionView.ScrollPosition {
        switch scrollDirection {
        case .horizontal:
            return .left
        case .vertical:
            return .top
        }
    }
}

extension ZKCycleScrollView: UICollectionViewDelegate {
    
    // MARK: - UICollectionView Delegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didSelectItemAt:))) {
            delegate.cycleScrollView!(self, didSelectItemAt: indexPath)
        }
    }
    
    // MARK: - UIScrollView Delegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollViewDidScroll(_:))) {
            delegate.cycleScrollViewDidScroll!(self)
        }
        guard count > 0 else { return }
        let indexPath = currentIndexPath()
        pageControl.currentPage = indexPath.item
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll { removeTimer() }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll { addTimer() }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didScrollTo:))) {
            guard count > 0 else { return }
            let indexPath = currentIndexPath()
            delegate.cycleScrollView!(self, didScrollTo: indexPath)
        }
    }
}

extension ZKCycleScrollView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        count = dataSource?.numberOfItems(in: self) ?? 0
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource?.cycleScrollView(self, cellForItemAt: indexPath) ?? collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseId, for: indexPath)
    }
}

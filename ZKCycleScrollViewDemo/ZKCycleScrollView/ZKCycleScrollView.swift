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
    open var isAutoScroll: Bool = true {
        didSet {
            addTimer()
        }
    }
    /// default true. turn off any dragging temporarily
    open var isScrollEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    /// default 3.f. automatic scroll time interval
    open var autoScrollInterval: TimeInterval = 3 {
        didSet {
            addTimer()
        }
    }
    open var pageIndex: Int {
        return changeIndex(currentIndex())
    }
    open var contentOffset: CGPoint {
        switch scrollDirection {
        case .vertical:
            return CGPoint(x: 0.0, y: max(0.0, collectionView.contentOffset.y - bounds.height))
        default:
            return CGPoint(x: max(0.0, collectionView.contentOffset.x - bounds.width), y: 0.0)
        }
    }
    open private(set) var pageControl: UIPageControl!

    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    private var timer: Timer?
    private var numberOfItems: Int = 0
    private var fromIndex: Int = 0
    
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
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }, completion: { _ in
                self.configuration()
            })
        }
    }
    
    open func adjustWhenViewWillAppear() {
        guard numberOfItems > 1 else { return }
        
        let index = currentIndex()
        let position = scrollPosition()
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        
        if index == 0 {
            let indexPath = IndexPath(item: numberOfItems - 2, section: 0)
            collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        } else if index == numberOfItems - 1 {
            let indexPath = IndexPath(item: 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        }
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
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        addSubview(pageControl);
        
        DispatchQueue.main.async { self.configuration() }
    }
    
    private func configuration() {
        addTimer()
        updatePageControl()
        guard numberOfItems > 1 else { return }
        
        let position = scrollPosition()
        let indexPath = IndexPath(item: 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: false)
    }
    
    private func addTimer() {
        removeTimer()
        
        if numberOfItems < 2 || !isAutoScroll || autoScrollInterval <= 0.0 { return }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(autoScrollInterval), target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updatePageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = max(0, numberOfItems - 2);
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
        if numberOfItems <= 0 || bounds.width <= 0.0 || bounds.height <= 0.0 {
            return 0
        }
        
        var index = 0
        switch scrollDirection {
        case .vertical:
            index = Int((collectionView.contentOffset.y + flowLayout.itemSize.height / 2) / flowLayout.itemSize.height)
        default:
            index = Int((collectionView.contentOffset.x + flowLayout.itemSize.width / 2) / flowLayout.itemSize.width)
        }
        return max(0, index)
    }
    
    private func changeIndex(_ index: Int) -> Int {
        guard numberOfItems > 1 else { return index }
        
        var idx = index
        
        if index == 0 {
            idx = numberOfItems - 3
        } else if index == numberOfItems - 1 {
            idx = 0
        } else {
            idx = index - 1
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
            total = CGFloat(numberOfItems - 3) * bounds.height
            offset = contentOffset.y.truncatingRemainder(dividingBy:(bounds.height * CGFloat(numberOfItems - 2)))
        default:
            total = CGFloat(numberOfItems - 3) * bounds.width
            offset = contentOffset.x.truncatingRemainder(dividingBy:(bounds.width * CGFloat(numberOfItems - 2)))
        }
        let percent = Double(offset / total)
        let progress = percent * Double(numberOfItems - 3)
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
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = currentIndex()
        if index == 0 {
            let position = scrollPosition()
            let indexPath = IndexPath(item: numberOfItems - 2, section: 0)
            collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        } else if index == numberOfItems - 1 {
            let position = scrollPosition()
            let indexPath = IndexPath(item: 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        }
        let toIndex = changeIndex(index)
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didScrollFromIndex:toIndex:))) {
            delegate.cycleScrollView!(self, didScrollFromIndex: fromIndex, toIndex: toIndex)
        }
        fromIndex = toIndex
    }
}

extension ZKCycleScrollView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
        if numberOfItems > 1 { numberOfItems += 2 }
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = changeIndex(indexPath.item)
        return (dataSource?.cycleScrollView(self, cellForItemAt: index))!
    }
}

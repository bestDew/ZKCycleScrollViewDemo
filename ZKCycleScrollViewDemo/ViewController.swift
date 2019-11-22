//
//  ViewController.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/8.
//  Copyright © 2019 bestdew. All rights reserved.
//

import UIKit
import CHIPageControl
import ZKCycleScrollView_Swift

class ViewController: UIViewController {
    
    let textCellId = "TextCell"
    let imageCellId = "ImageCell"
    let colorCellId = "ColorCell"
    
    var didUpdates = false
    
    lazy var textArray: [String] = {
        let textArray = ["~这是一个强大好用的轮播图~", "~如果你也觉得不错的话~", "~给我点个赞吧:）~"]
        return textArray
    }()
    
    lazy var imageNamesArray: [String] = {
        let imageNamesArray = ["1", "2", "3", "4", "5"]
        return imageNamesArray
    }()
    
    lazy var pageControl: CHIPageControlJaloro = {
        let pageControl = CHIPageControlJaloro()
        return pageControl
    }()
    
    lazy var colorCycleScrollView: ZKCycleScrollView = {
        let colorCycleScrollView = ZKCycleScrollView(frame: CGRect.zero, shouldInfiniteLoop: false)
        return colorCycleScrollView
    }()

    @IBOutlet weak var imageCycleScrollView: ZKCycleScrollView!
    @IBOutlet weak var textCycleScrollView: ZKCycleScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 1.xib方式创建纯文字轮播
        textCycleScrollView.register(TextCell.self, forCellWithReuseIdentifier: textCellId)
        
        /// 2.xib方式创建图片轮播
        imageCycleScrollView.itemSize = CGSize(width: imageCycleScrollView.bounds.width - 80.0, height: imageCycleScrollView.bounds.height)
        imageCycleScrollView.register(UINib(nibName: imageCellId, bundle: nil), forCellWithReuseIdentifier: imageCellId)
        /// 如果需要设置默认显示页，可以像下面这样做
        imageCycleScrollView.loadCompletion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.imageCycleScrollView.scrollToItem(at: 3, animated: false)
        }
        
        /// 3.纯代码方式创建有限轮播
        colorCycleScrollView.frame = CGRect(x: 0.0, y: textCycleScrollView.frame.origin.y - 200.0, width: view.bounds.width, height: 50.0)
        colorCycleScrollView.delegate = self
        colorCycleScrollView.dataSource = self
        colorCycleScrollView.hidesPageControl = true /// 隐藏默认的 pageControl，如果有需要你可以通过 -addSubView: 的方式添加自定义的 pageControl，然后在代理方法中进行联动
        colorCycleScrollView.isAutoScroll = false /// 关闭自动滚动
        colorCycleScrollView.itemSpacing = 10.0 /// 设置 cell 间距
        colorCycleScrollView.itemSize = CGSize(width: colorCycleScrollView.bounds.width - 50.0, height: colorCycleScrollView.bounds.height) // 设置 cell 大小
        colorCycleScrollView.register(ZKCycleScrollViewCell.self, forCellWithReuseIdentifier: colorCellId)
        view.addSubview(colorCycleScrollView)
        /// 自定义 PageControl
        pageControl.frame = CGRect(x: 0.0, y: colorCycleScrollView.frame.maxY + 10.0, width: colorCycleScrollView.bounds.width, height: 15.0)
        pageControl.radius = 3.0
        pageControl.padding = 8.0
        pageControl.inactiveTransparency = 0.8 // 未命中点的不透明度
        pageControl.tintColor = UIColor.blue
        pageControl.currentPageTintColor = UIColor.red
        pageControl.numberOfPages = 3
        pageControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        view.addSubview(pageControl)
    }
    
    @IBAction func updateLayout(_ sender: Any) {
        didUpdates = !didUpdates
        
        /// 如果需要更新当前布局，必须先调用 -beginUpdates
        imageCycleScrollView.beginUpdates()
        /// 在这里可以更新以下单个或多个属性值
        if didUpdates {
            imageCycleScrollView.itemSpacing = 10.0
            imageCycleScrollView.itemZoomScale = 1.0
            imageCycleScrollView.scrollDirection = .vertical
            imageCycleScrollView.itemSize = CGSize(width: imageCycleScrollView.bounds.width, height: imageCycleScrollView.bounds.height - 80.0)
        } else {
            imageCycleScrollView.itemSpacing = -10.0
            imageCycleScrollView.itemZoomScale = 0.85
            imageCycleScrollView.scrollDirection = .horizontal
            imageCycleScrollView.itemSize = CGSize(width: imageCycleScrollView.bounds.width - 80.0, height: imageCycleScrollView.bounds.height)
        }
        /// 更改后，必须调用 -endUpdates，更新当前布局
        imageCycleScrollView.endUpdates()
    }
}

extension ViewController: ZKCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt index: Int) {
        print("selected index: \(index)")
        if cycleScrollView === colorCycleScrollView {
            cycleScrollView.scrollToItem(at: cycleScrollView.pageIndex + 1, animated: true)
        } else {
            let vc = SubViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView, progress: Double) {
        guard cycleScrollView === colorCycleScrollView else { return }
        pageControl.progress = progress
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didScrollFromIndex fromIndex: Int, toIndex: Int) {
        guard cycleScrollView === imageCycleScrollView else { return }
        print("from: \(fromIndex) to: \(toIndex)")
    }
}

extension ViewController: ZKCycleScrollViewDataSource {
    
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int {
        if cycleScrollView === textCycleScrollView {
            return textArray.count
        } else if cycleScrollView === imageCycleScrollView {
            return imageNamesArray.count
        } else {
            return 3
        }
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt index: Int) -> ZKCycleScrollViewCell {
        if cycleScrollView === textCycleScrollView {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: textCellId, for: index) as! TextCell
            cell.textLabel.text = textArray[index]
            return cell
        } else if cycleScrollView === imageCycleScrollView {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: imageCellId, for: index) as! ImageCell
            cell.imageView.image = UIImage(named: imageNamesArray[index])
            return cell
        } else {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: colorCellId, for: index)
            cell.contentView.backgroundColor = UIColor.random()
            return cell
        }
    }
}

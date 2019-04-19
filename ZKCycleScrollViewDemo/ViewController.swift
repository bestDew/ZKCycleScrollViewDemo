//
//  ViewController.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/8.
//  Copyright © 2019 bestdew. All rights reserved.
//

import UIKit
import CHIPageControl

let kScreenWidth: CGFloat = UIScreen.main.bounds.width
let kFitWidth: (CGFloat) -> CGFloat = { width in
    return width * kScreenWidth / 375.0
}

class ViewController: UIViewController {
    
    let localCellId = "LocalImageCell"
    let remoteCellId = "RemoteImageCell"
    let textCellId = "TextCell"
    
    var localPathGroup = [String]()
    var remotePathGroup = [String]()
    var textGroup = [String]()

    let scrollView = UIScrollView()
    
    let cycleScrollView1 = ZKCycleScrollView()
    let cycleScrollView2 = ZKCycleScrollView()
    let cycleScrollView3 = ZKCycleScrollView()
    let cycleScrollView4 = ZKCycleScrollView()
    let cycleScrollView5 = ZKCycleScrollView()
    
    let pageControlJaloro = CHIPageControlJaloro()
    let pageControlPuya = CHIPageControlPuya()
    let pageControlChimayo = CHIPageControlChimayo()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 1...12 {
            localPathGroup.append("\(index)")
        }
        
        remotePathGroup = ["http://static1.pezy.cn/img/2019-02-01/5932241902444072231.jpg",
                           "http://static1.pezy.cn/img/2019-03-01/1206059142424414231.jpg"]
        
        textGroup = ["~如果有一天~", "~我回到从前~", "~我会带着笑脸~", "~和你说再见~"]
        
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 750.0)
        view.addSubview(scrollView)
        
        addCycleScrollView1()
        addCycleScrollView2()
        addCycleScrollView3()
        addCycleScrollView4()
        addCycleScrollView5()
    }
    
    /// 默认就是这种效果
    func addCycleScrollView1() {
        cycleScrollView1.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: kFitWidth(65.0))
        cycleScrollView1.delegate = self
        cycleScrollView1.dataSource = self
        cycleScrollView1.register(RemoteImageCell.self, forCellWithReuseIdentifier: remoteCellId)
        scrollView.addSubview(cycleScrollView1)
    }
    
    /// 如果内置的 pageControl 不能满足需求，你可以隐藏默认的 pageControl，然后通过 -addSubview: 的方式添加你自定义的 pageControl，并在相应的代理方法中将 pageControl 进行联动，这种方式应该更显灵活些。。。
    /// 这里推荐一个很好很强大的自定义的 PageControl 轮子：https://github.com/ChiliLabs/CHIPageControl
    /// 本 Demo 中用的就是这个，但遗憾的是貌似目前只有 Swift 版本。。。
    
    /// 实现这种效果的关键是：itemSize.width = cycleScrollView.bounds.size.width - itemSpacing * 2
    func addCycleScrollView2() {
        cycleScrollView2.frame = CGRect(x: 0.0, y: cycleScrollView1.frame.maxY + 20.0, width: view.bounds.width, height: kFitWidth(150.0))
        cycleScrollView2.delegate = self
        cycleScrollView2.dataSource = self
        cycleScrollView2.hidesPageControl = true
        cycleScrollView2.itemSpacing = 12.0
        cycleScrollView2.itemSize = CGSize(width: view.bounds.width - 24.0, height: cycleScrollView2.bounds.height)
        cycleScrollView2.register(UINib(nibName: "LocalImageCell", bundle: nil), forCellWithReuseIdentifier: localCellId)
        scrollView.addSubview(cycleScrollView2)
        
        pageControlJaloro.frame = CGRect(x: 0.0, y: cycleScrollView2.bounds.height - 15.0, width: cycleScrollView2.bounds.width, height: 15.0)
        pageControlJaloro.radius = 3.0
        pageControlJaloro.padding = 8.0
        pageControlJaloro.inactiveTransparency = 0.8
        pageControlJaloro.tintColor = UIColor.purple
        pageControlJaloro.currentPageTintColor = UIColor.blue
        pageControlJaloro.numberOfPages = localPathGroup.count
        pageControlJaloro.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cycleScrollView2.addSubview(pageControlJaloro)
    }
    
    /// 前后两个 cell 暴露出来的部分之和 + itemSpacing * 2 = cycleScrollView.bounds.size.width
    func addCycleScrollView3() {
        cycleScrollView3.frame = CGRect(x: 0.0, y: cycleScrollView2.frame.maxY + 20.0, width: view.bounds.width, height: kFitWidth(150.0))
        cycleScrollView3.delegate = self
        cycleScrollView3.dataSource = self
        cycleScrollView3.hidesPageControl = true
        cycleScrollView3.itemSpacing = 12.0
        cycleScrollView3.itemSize = CGSize(width: view.bounds.width - 50.0, height: cycleScrollView3.bounds.height)
        cycleScrollView3.register(UINib(nibName: "LocalImageCell", bundle: nil), forCellWithReuseIdentifier: localCellId)
        scrollView.addSubview(cycleScrollView3)
        
        pageControlPuya.frame = CGRect(x: 0.0, y: cycleScrollView3.bounds.height - 15.0, width: cycleScrollView3.bounds.width, height: 15.0)
        pageControlPuya.padding = 8.0
        pageControlPuya.inactiveTransparency = 0.8
        pageControlPuya.tintColor = UIColor.purple
        pageControlPuya.currentPageTintColor = UIColor.blue
        pageControlPuya.numberOfPages = localPathGroup.count
        pageControlPuya.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cycleScrollView3.addSubview(pageControlPuya)
    }
    
    /// 实现这种效果的关键是：itemZoomFactor，默认是 0.f，没有缩放效果，这个值越大缩放效果越明显，0.001已经很大了。。。
    func addCycleScrollView4() {
        cycleScrollView4.frame = CGRect(x: 0.0, y: cycleScrollView3.frame.maxY + 20.0, width: view.bounds.width, height: kFitWidth(150.0))
        cycleScrollView4.delegate = self
        cycleScrollView4.dataSource = self
        cycleScrollView4.hidesPageControl = true
        cycleScrollView4.itemSpacing = -18.0
        cycleScrollView4.itemZoomFactor = 0.001
        cycleScrollView4.itemSize = CGSize(width: view.bounds.width - 80.0, height: cycleScrollView4.bounds.height)
        cycleScrollView4.register(UINib(nibName: "LocalImageCell", bundle: nil), forCellWithReuseIdentifier: localCellId)
        scrollView.addSubview(cycleScrollView4)
        
        pageControlChimayo.frame = CGRect(x: 0.0, y: cycleScrollView4.bounds.height - 15.0, width: cycleScrollView4.bounds.width, height: 15.0)
        pageControlChimayo.padding = 8.0
        pageControlChimayo.tintColor = UIColor.blue
        pageControlChimayo.numberOfPages = localPathGroup.count
        pageControlChimayo.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cycleScrollView4.addSubview(pageControlChimayo)
    }
    
    func addCycleScrollView5() {
        cycleScrollView5.frame = CGRect(x: 0.0, y: cycleScrollView4.frame.maxY + 20.0, width: view.bounds.width, height: 30.0)
        cycleScrollView5.delegate = self
        cycleScrollView5.dataSource = self
        cycleScrollView5.hidesPageControl = true
        cycleScrollView5.allowsDragging = false
        cycleScrollView5.scrollDirection = .vertical
        cycleScrollView5.register(TextCell.self, forCellWithReuseIdentifier: textCellId)
        scrollView.addSubview(cycleScrollView5)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cycleScrollView1.adjustWhenViewWillAppear()
        cycleScrollView2.adjustWhenViewWillAppear()
        cycleScrollView3.adjustWhenViewWillAppear()
        cycleScrollView4.adjustWhenViewWillAppear()
        cycleScrollView5.adjustWhenViewWillAppear()
    }
}

extension ViewController: ZKCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt index: Int) {
        print("selected index: \(index)")
    }
    
    func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView, progress: Double) {
        if cycleScrollView === cycleScrollView1 {
            print("content offset-x: \(cycleScrollView.contentOffset.x)")
        } else if cycleScrollView === cycleScrollView2 {
            pageControlJaloro.progress = progress
        } else if cycleScrollView === cycleScrollView3 {
            pageControlPuya.progress = progress
        } else if cycleScrollView === cycleScrollView4 {
            pageControlChimayo.progress = progress
        }
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didScrollFromIndex fromIndex: Int, toIndex: Int) {
        guard cycleScrollView === cycleScrollView2 else { return }
        print("from: \(fromIndex) to: \(toIndex)")
    }
}

extension ViewController: ZKCycleScrollViewDataSource {
    
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int {
        if cycleScrollView === cycleScrollView1 {
            return remotePathGroup.count
        } else if cycleScrollView === cycleScrollView5 {
            return textGroup.count
        } else {
            return localPathGroup.count
        }
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt index: Int) -> ZKCycleScrollViewCell {
        if cycleScrollView === cycleScrollView1 {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: remoteCellId, for: index) as! RemoteImageCell
            cell.imageUrl = remotePathGroup[index]
            return cell
        } else if cycleScrollView === cycleScrollView5 {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: textCellId, for: index) as! TextCell
            cell.textLabel.text = textGroup[index]
            return cell
        } else {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: localCellId, for: index) as! LocalImageCell
            cell.imageView.image = UIImage(named: localPathGroup[index])
            return cell
        }
    }
}


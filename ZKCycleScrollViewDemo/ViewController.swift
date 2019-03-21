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
    
    var loaclPathGroup = [String]()
    var remotePathGroup = [String]()
    var textGroup = [String]()

    let pageControl = CHIPageControlJaloro()
    let localBannerView = ZKCycleScrollView()
    let remoteBannerView = ZKCycleScrollView()
    let textBannerView = ZKCycleScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 本地图片轮播
        for index in 1...12 {
            loaclPathGroup.append("\(index)")
        }
        
        localBannerView.frame = CGRect(x: 0.0, y: 60.0, width: kScreenWidth, height: kFitWidth(200.0))
        localBannerView.delegate = self
        localBannerView.dataSource = self;
        localBannerView.pageControl.isHidden = true
        localBannerView.register(UINib(nibName: "LocalImageCell", bundle: nil), forCellWithReuseIdentifier: localCellId)
        view.addSubview(localBannerView)
        
        pageControl.frame = CGRect(x: 0.0, y: localBannerView.bounds.height - 15.0, width: kScreenWidth, height: 15.0)
        pageControl.radius = 3.0
        pageControl.padding = 8.0
        pageControl.tintColor = UIColor.gray
        pageControl.currentPageTintColor = UIColor.orange
        pageControl.numberOfPages = loaclPathGroup.count
        pageControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        localBannerView.addSubview(pageControl)
        
        /// 网络图片图片轮播
        remotePathGroup = ["http://static1.pezy.cn/img/2019-02-01/5932241902444072231.jpg",
            "http://static1.pezy.cn/img/2019-03-01/1206059142424414231.jpg"]
        remoteBannerView.frame = CGRect(x: 0.0, y: localBannerView.frame.maxY + 60.0, width: kScreenWidth, height: kFitWidth(65.0))
        remoteBannerView.delegate = self
        remoteBannerView.dataSource = self;
        remoteBannerView.autoScrollInterval = 4.0
        remoteBannerView.register(RemoteImageCell.self, forCellWithReuseIdentifier: remoteCellId)
        view.addSubview(remoteBannerView)
        
        /// 文字轮播
        textGroup = ["~如果有一天~", "~我回到从前~", "~我会带着笑脸~", "~和你说再见~"]
        textBannerView.frame = CGRect(x: 0, y: remoteBannerView.frame.maxY + 60.0, width: kScreenWidth, height: 30.0)
        textBannerView.delegate = self
        textBannerView.dataSource = self
        textBannerView.isScrollEnabled = false
        textBannerView.pageControl.isHidden = true
        textBannerView.backgroundColor = .white
        textBannerView.scrollDirection = .vertical
        textBannerView.register(TextCell.self, forCellWithReuseIdentifier: textCellId)
        view.addSubview(textBannerView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        localBannerView.adjustWhenViewWillAppear()
        remoteBannerView.adjustWhenViewWillAppear()
        textBannerView.adjustWhenViewWillAppear()
    }
}

extension ViewController: ZKCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt index: Int) {
        print("selected index: \(index)")
    }
    
    func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView, progress: Double) {
        guard cycleScrollView === localBannerView else { return }
        pageControl.progress = progress
        print("progress: \(progress)")
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didScrollFromIndex fromIndex: Int, toIndex: Int) {
        guard cycleScrollView === localBannerView else { return }
        print("from: \(fromIndex) to: \(toIndex)")
    }
}

extension ViewController: ZKCycleScrollViewDataSource {
    
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int {
        if cycleScrollView === localBannerView {
            return loaclPathGroup.count
        } else if cycleScrollView === remoteBannerView {
            return remotePathGroup.count
        } else {
            return textGroup.count
        }
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt index: Int) -> ZKCycleScrollViewCell {
        if cycleScrollView === localBannerView {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: localCellId, for: index) as! LocalImageCell
            cell.imageView.image = UIImage(named: loaclPathGroup[index])
            return cell
        } else if cycleScrollView === remoteBannerView {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: remoteCellId, for: index) as! RemoteImageCell
            cell.imageUrl = remotePathGroup[index]
            return cell
        } else {
            let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: textCellId, for: index) as! TextCell
            cell.textLabel.text = textGroup[index]
            return cell
        }
    }
}


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
    
    var loaclPathGroup = [String]()
    var remotePathGroup = [String]()
    var textGroup = [String]()
    
    lazy var localBannerView: ZKCycleScrollView = {
        let localBannerView = ZKCycleScrollView(frame: CGRect(x: 0.0, y: 100.0, width: view.bounds.width, height: kFitWidth(200.0)))
        localBannerView.delegate = self
        localBannerView.dataSource = self
        localBannerView.backgroundColor = .white
        localBannerView.customPageControl = pageControl
        localBannerView.register(cellClass: LocalImageCell.self)
        localBannerView.pageControlTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return localBannerView
    }()
    
    lazy var remoteBannerView: ZKCycleScrollView = {
        let remoteBannerView = ZKCycleScrollView(frame: CGRect(x: 0, y: 350.0, width: kScreenWidth, height: kFitWidth(80)))
        remoteBannerView.delegate = self
        remoteBannerView.dataSource = self
        remoteBannerView.backgroundColor = .white
        remoteBannerView.autoScrollDuration = 5.0
        remoteBannerView.register(cellClass: RemoteImageCell.self)
        return remoteBannerView
    }()
    
    lazy var textBannerView: ZKCycleScrollView = {
        let textBannerView = ZKCycleScrollView(frame: CGRect(x: 0, y: 480.0, width: kScreenWidth, height: 30.0))
        textBannerView.delegate = self
        textBannerView.dataSource = self
        textBannerView.isScrollEnabled = false
        textBannerView.showsPageControl = false
        textBannerView.backgroundColor = .white
        textBannerView.scrollDirection = .vertical
        textBannerView.register(cellClass: TextCell.self)
        return textBannerView
    }()
    
    lazy var pageControl: CHIPageControlJaloro = {
        let pageControl = CHIPageControlJaloro()
        pageControl.radius = 3.0
        pageControl.padding = 8.0
        pageControl.tintColor = UIColor(hexString: "#E8E8EA")!
        pageControl.currentPageTintColor = UIColor(hexString: "#EF8833")!
        pageControl.numberOfPages = loaclPathGroup.count
        pageControl.isHidden = true
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 1...6 {
            loaclPathGroup.append("ad_\(index)")
        }
        view.addSubview(localBannerView)
        
        remotePathGroup = ["http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20171101181927887.jpg", "http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20171114171645011.jpg", "http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20171114172009707.png"]
        view.addSubview(remoteBannerView)
        
        textGroup = ["~如果有一天~", "~我回到从前~", "~我会带着笑脸~", "~和你说再见~"]
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
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt indexPath: IndexPath) {
        print("点击了：\(indexPath.item)")
    }
    
    func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView) {
        
        guard cycleScrollView === localBannerView else { return }
        
        let total = CGFloat(loaclPathGroup.count - 1) * cycleScrollView.bounds.width
        let offset = cycleScrollView.contentOffset.x.truncatingRemainder(dividingBy:(cycleScrollView.bounds.width * CGFloat(loaclPathGroup.count)))
        let percent = Double(offset / total)
        let progress = percent * Double(loaclPathGroup.count - 1)
        pageControl.progress = progress
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
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt indexPath: IndexPath) -> ZKCycleScrollViewCell {
        if cycleScrollView === localBannerView {
            let cell = cycleScrollView.dequeueReusableCell(for: indexPath) as! LocalImageCell
            cell.imageView.image = UIImage(named: loaclPathGroup[indexPath.item])
            return cell
        } else if cycleScrollView === remoteBannerView {
            let cell = cycleScrollView.dequeueReusableCell(for: indexPath) as! RemoteImageCell
            cell.imageUrl = remotePathGroup[indexPath.item]
            return cell
        } else {
            let cell = cycleScrollView.dequeueReusableCell(for: indexPath) as! TextCell
            cell.textLabel.text = textGroup[indexPath.item]
            return cell
        }
    }
}


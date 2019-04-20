# ZKCycleScrollView

一款简单实用的轮播图控件，更优雅的实现，更友好的API。支持 Objective-C 和 Swift。

## 效果图

![image](https://github.com/bestDew/ZKCycleScrollViewDemo/blob/master/ZKCycleScrollViewDemo/Untitled.gif)

## 特性

-   支持横向和竖向滚动
-   支持 cell 和 pageControl 自定制
-   支持 xib 和 storyBoard

## 使用

```swift

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cycleScrollView = ZKCycleScrollView(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 65.0))
        cycleScrollView.delegate = self
        cycleScrollView.dataSource = self
        cycleScrollView.register(CustomCell.self, forCellWithReuseIdentifier: "cellReuseId")
        view.addSubview(cycleScrollView)
    }
}

extension ViewController: ZKCycleScrollViewDataSource {
    
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int {
        return 5
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt index: Int) -> ZKCycleScrollViewCell {
        let cell = cycleScrollView.dequeueReusableCell(withReuseIdentifier: "cellReuseId", for: index) as! CustomCell
        // TODO...
        return cell
    }
}

extension ViewController: ZKCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt index: Int) {
        // TODO...
    }
}

```

## 链接

-   [English document](./README.md)
-   [Objective-C 版本](https://github.com/bestDew/ZKCycleScrollViewDemo-OC)

## 感谢

如果对你有帮助, 赏颗星吧😘。

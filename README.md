# ZKCycleScrollView

ZKCycleScrollView是的一个功能强大的轮播视图。支持 [Objective-C](https://github.com/bestDew/ZKCycleScrollViewDemo-OC) 和 [Swift](https://github.com/bestDew/ZKCycleScrollViewDemo)。

### 提示：下载完 Demo 后，需执行下 ```pod install```才能运行。

## 特性

-   高度可定制化
-   支持 Xib 方式创建
-   支持 CocoaPods 方式导入

## 演示效果图

![image](https://github.com/bestDew/ZKCycleScrollViewDemo/blob/master/ZKCycleScrollViewDemo/Untitled.gif)

## 用法示例

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
        // TODO:
        return cell
    }
}

extension ViewController: ZKCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt index: Int) {
        // TODO:
    }
}

```

## 更新记录

### Version 2.0.1（2019/11/11）：

1.支持 CococaPods 导入：
  ```swift
  pod 'ZKCycleScrollView-Swift'
  ```
2.支持取消无限轮播：
  ```swift
  // 通过Xib 方式创建的，可直接在属性面板中直接设置 infiniteLoop 为 off
  // 通过纯代码方式创建的，需要设置 infiniteLoop 参数为 false
  public init(frame: CGRect, shouldInfiniteLoop infiniteLoop: Bool? = nil)
  ```
3.支持设置默认显示页：
  ```swift
  // 设置默认从第三页开始显示
  ccleScrollView.loadCompletion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cycleScrollView.scrollToItem(at: 3, animated: false)
        }
  ```
 4.修复界面跳转时 cell 自动偏移的 bug；<br/>
 
 5.修复在加载时就回调代理方法的 bug；<br/>
 
 6.移除 -adjustWhenViewWillAppear 方法；<br/>
 
 7.新增 -beginUpdates、-endUpdates、-scrollToIndex:animated:、-cellForItemAtIndex: 等方法，具体使用见Demo；<br/>
 
 8.优化性能。

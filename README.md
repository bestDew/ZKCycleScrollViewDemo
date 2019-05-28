# ZKCycleScrollViewDemo

A simple and useful automatic infinite scroll view, more elegant implementation and more friendly API. Support for Objective-C and Swift.

## ScreenShot

![image](https://github.com/bestDew/ZKCycleScrollViewDemo/blob/master/ZKCycleScrollViewDemo/Untitled.gif)

## Features

-   Horizontal and vertical scrolling
-   Cell and PageControl customization
-   Interface Builder

## Usage

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

## Links

-   [中文文档](./README_CN.md)
-   [Objective-C version](https://github.com/bestDew/ZKCycleScrollViewDemo-OC)

## Thanks

If possible, please give me a star😘.

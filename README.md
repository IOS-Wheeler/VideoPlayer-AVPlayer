# VideoPlayer-AVPlayer
## 介绍 ##
本项目是采用swift3.0编写的，基于AVPlyaer封装的简单播放器。本项目一步一步教你如何基于AVPlyaer定制自己的个性化视频播放器。

## 编写时环境 ##
* iOS 8 +
* Xcode 8.3.3
* Swift 3.1


## 第一部分：让视频展示并播放 ##
### Step.1：添加AVPlayer ###
1. 首先，继承UIView，设计一个播放器类，暂且取名：SPPlayer1
2. 然后，设计2个属性：player和playerLayer（解释一下，player是播放器AVPlyaer类的实例，playerLayer是AVPlayerLayer的实例）
3. 最后，SPPlayer提供外部访问的接口

废话少说，先上代码
<pre><code>
import UIKit
import AVFoundation


// MARK: - Player 定义
class SPPlayer1: UIView {
    fileprivate lazy var player = AVPlayer.init()
    fileprivate lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer.init(player: self.player)
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(playerLayer)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
        playerLayer.backgroundColor = UIColor.black.cgColor
    }
}


// MARK: - 对外提供接口
extension SPPlayer1 {
    func configure(url: URL, playImmediately: Bool) {
        player.replaceCurrentItem(with: AVPlayerItem.init(url: url))
        if playImmediately {
            player.play()
        }
    }
    func play() {
        player.play()
    }
    func pause() {
        player.pause()
    }
}

</code></pre>

然后我们接着说，<br />
对于上面的代码，对必要的代码解释几句

* 对于外部不需要用到的属性，不应该暴露出来，所以应该采用private或者fileprivate权限。在这里采用fileprivate权限，因为我比较喜欢采用extension将类的不同功能的代码进行分离，代码相对来说会简洁一些，阅读起来会很直观。
* UI会采取自动布局的方式，所以，重写layoutSubviews方法，对playerLayer的frame进行，确保playerLayer的frame与管理类（SPPlayer1）的bounds一致，这样，不管SPPlayer1实例的大小怎么变化（无论简单的改变大小，还是横纵屏切换），playerLayer始终跟着变化。
* 扩展SPPlayer1类，提供3个方法给外部调用。由于AVPlayer的currentItem属性是只读权限，所以不能给currentItem赋值，不过提供了另外一个API，即replaceCurrentItem(item:)方法，我们可以用它来更换新的视频资源。所以，我们设计方法configure(url:, playImmediately:)提供给外部调用，外部可直接指定需要播放的URL，不管这个URL是远程的还是本地的，都支持，另外还提供一个playImmediately参数，控制是否立即播放。另外两个我就不解释了。


### Step.2：显示SPPlayer1 ###
到这里了就很简单，

1. 准备资源URL
2. 创建一个SPPlayer1播放器实例添加到控制器的view上，并且指定自动播放，就OK了

不说了，上代码
<pre><code>
import UIKit
import SnapKit
import AVFoundation

class SPViewController1: UIViewController {
    fileprivate lazy var player: SPPlayer1 = SPPlayer1()
    deinit {
        print("SPViewController1 deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        player.configure(url: URL.init(string: "https://dn-iyongzai.qbox.me/video/sdyjq7.mp4")!, playImmediately: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SPViewController1: UICodingStyle {
    func adjustUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "No.1 添加播放器"
    }
    func addSubviews() {
        self.view.addSubview(player)
    }
    func addConstraints() {
        player.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(player.snp.width).dividedBy(16.0/9.0)
        }
    }
}
</code></pre>

先来

火眼金睛的你可能注意到了扩展那里有个UICodingStyle，什么东西？？？</br>
解释一下，这是我个人编码习惯，我喜欢使用extension，上面我说过了，我这里的UICodingStyle是一个协议，这里，对我们的测试视频播放没有任何关联，**不感兴趣的童鞋可直接去掉“: UICodingStyle”，在viewDidLoad方法中执行如下关键代码即可：**

	self.view.addSubview(player)
	player.configure(url: URL.init(string: "https://dn-iyongzai.qbox.me/video/sdyjq7.mp4")!, playImmediately: true)
	//添加约束
	player.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(player.snp.width).dividedBy(16.0/9.0)
        }
**好奇的童鞋可以看看这个UICodingStyle协议，不感冒的可直接跳过下面代码块和相关的解释**
<pre><code>
import Foundation


// MARK: - 定义UICodingStyle协议,定义几个方法（UICodingStyle的设计只是为了让代码看起来更加美观，优雅）
protocol UICodingStyle {
    /// 用于调整UI的接口
    func adjustUI()
    </br>
    /// UI添加事件
    func addEvents()
    </br>
    /// 用来添加子视图的接口
    func addSubviews()
    </br>
    /// 用来给子视图添加约束的接口
    func addConstraints()
    </br>
    /// 设置数据源
    func configure<T>(model: T)
}


// MARK: - 默认实现
extension UICodingStyle {
    /// 用于调整UI的接口
    func adjustUI(){}
    </br>
    /// UI添加事件
    func addEvents(){}
    </br>
    /// 用来添加子视图的接口
    func addSubviews(){}
    </br>
    /// 用来给子视图添加约束的接口
    func addConstraints(){}
    </br>
    /// 设置数据源
    func configure<T>(model: T) {}
}

</code></pre>
**对UICodingStyle不感兴趣的可跳过下面的解释：**<br/>
在协议中我定义了5个方法，并且扩展了UICodingStyle协议，都给出了默认实现，因为设计UICodingStyle协议的初衷是只是为了让遵循者的代码看起来更加美观，优雅，并且提供统一的方法名，可读性非常好，可能这里没有什么体现，后面的播放器会有所体现。<br />
**设计UICodingStyle的背景**：真实的一个项目下来，会有很多的自定义UIView，或者UIViewController，在这些UIResponder的子类中，添加子视图是再正常不过的了，我们的通常做法是直接在构造函数中编写一段代码，或者单独写个方法把这些代码封装起来，在UIViewController中可能会在loadview或者viewdidload方法中编写这些添加子视图的代码，这本身没有什么问题，再正常不过了，不过一个项目下来，发现很多代码非常相似，但是这些代码却编写在不同的的方法中，方法名五花八门，当有需要找某个subview的时候，不一定能确定在哪个方法，需要浏览方法列表，或者search一下，这样虽然能够找到，但是相对来说效率并不高。对于这样的代码，可读性不强，也不易于维护，这样的代码必须要改，必须要设计一种可读性更强，也已于维护的编码风格方案，于是UICodingStyle就诞生了。<br />

**UICodingStyle几个方法的解释**

* addSubviews：用来 添加子视图的，所有添加子视图的代码都应该在这个方法中编写（动态（需要依赖数据才能添加的一些视图）的那些除外）
* addConstraints：用来 给子视图添加约束，适用于自动布局，如果非自动布局，那么设置子视图的相关操作也可在此编写
* addEvents：有些子视图需要添加监听事件，这个方法把所有设置监听的代码编写于此
* adjustUI：有时需要调整一些UI，我们就可以在这里编写
* configure：这个是设置数据源的

关于UICodingStyle的好处，后面会有所体现，这里先不说，有点偏题了，我们回到播放器的主题上，Sorry！


<br />
## 第二部分：在播放器上添加基本交互UI ##
为了一步一步描述怎么来编写，我们copy上面的SPPlayer1中所有代码，更名SPPlayer2，然后添加交互UI。<br />
**分析：**那么我们需要添加什么交互UI呢，播放暂停按钮肯定是要的（一般都是加载播放器中间），另外，缓存进度UI，播放进度UI，视频总时长UI，当前播放时长UI，横纵屏切换按钮，这些基本的交互控件肯定是少不了，而且这一般都是在一个bar上，bar一般出现在播放器底部；有些播放器还需要显示标题，横屏的话，还需要退出横屏，有的需求返回上一级页面，所有返回按钮也是需要的，而标题和返回键通常在同一个bar上，而且出现在播放器顶部。<br />
于是我们可以：

* 设计底部操作栏SPBottomBar
* 顶部标题栏SPTopBar
* 播放器中间添加播放暂停按钮

### SPBottomBar： ###
先上代码

<pre><code>
import Foundation
import UIKit
import SnapKit

/// 定制底部操作栏
// MARK: - 定义SPBottomBar
class SPBottomBar: UIView {
    
    /// ios8之后可以添加UIVisualEffectView（毛玻璃效果） 作为播放器操作栏的背景
    fileprivate lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        effectView.alpha = 1
        return effectView
    }()
    
    /// 已播放的进度（时间）
    fileprivate(set) lazy var playedTimeLabel: UILabel = {
        let playedTimeLabel = UILabel()
        playedTimeLabel.text = "00:00"
        playedTimeLabel.textColor = UIColor.theme
        playedTimeLabel.textAlignment = .right
        playedTimeLabel.font = UIFont.systemFont(ofSize: 10)
        return playedTimeLabel
    }()
    
    /// 视频的总时间
    fileprivate(set) lazy var totalTimeLabel: UILabel = {
        let totalTimeLabel = UILabel()
        totalTimeLabel.text = "计算中..."
        totalTimeLabel.textColor = UIColor.theme
        totalTimeLabel.textAlignment = .left
        totalTimeLabel.font = UIFont.systemFont(ofSize: 10)
        return totalTimeLabel
    }()
    
    /// 横纵屏切换按钮
    fileprivate(set) lazy var orientationButton: UIButton = {
        let orientationButton = UIButton.init(type: .custom)
        orientationButton.tintColor = UIColor.theme
        orientationButton.setImage(UIImage.init(named: "go_landscape")?.from(tintColor: UIColor.theme), for: .normal)
        orientationButton.setImage(UIImage.init(named: "go_portrait")?.from(tintColor: UIColor.theme), for: .selected)
        return orientationButton
    }()
    
    
    /// 视频加载的进度条
    fileprivate(set) lazy var progress: UIProgressView = {
        let progress = UIProgressView.init(frame: CGRect.zero)
        progress.tintColor = UIColor.theme
        return progress
    }()
    
    /// 滑块-视频播放的进度
    fileprivate(set) lazy var slider: UISlider = {
        let slider = UISlider.init(frame: CGRect.zero)
        slider.tintColor = UIColor.theme
        slider.thumbTintColor = UIColor.theme
        return slider
    }()
    var sliding = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        self.addEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



// MARK: - 添加子视图
extension SPBottomBar: UICodingStyle {
    func addSubviews() {
        effectView.addSubview(playedTimeLabel)
        effectView.addSubview(orientationButton)
        effectView.addSubview(totalTimeLabel)
        effectView.addSubview(progress)
        effectView.addSubview(slider)
        
        self.addSubview(effectView)
    }
    func addConstraints() {
        playedTimeLabel.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(0)
            make.width.equalTo(35)
        }
        orientationButton.snp.makeConstraints { (make) in
            make.top.bottom.right.equalTo(0)
            make.width.equalTo(44)
        }
        totalTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.right.equalTo(orientationButton.snp.left)
            make.width.equalTo(35)
        }
        progress.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(totalTimeLabel.snp.left).offset(-4)
            make.centerY.equalTo(effectView)
            make.height.equalTo(3)
        }
        slider.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(progress.snp.left)
            make.right.equalTo(progress.snp.right)
        }
        
        effectView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    func adjustUI() {
        if (UIDevice.current.systemVersion as NSString).floatValue < 8.3 {
            if let image = slider.currentThumbImage {
                let img = image.from(tintColor: UIColor.theme)
                slider.setThumbImage(img, for: .normal)
                slider.setThumbImage(img, for: .selected)
                slider.setThumbImage(img, for: .highlighted)
            }
        }
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 1, height: 1), false, 0)
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        slider.setMinimumTrackImage(transparentImage, for: .normal)
        slider.setMaximumTrackImage(transparentImage, for: .normal)
    }
    func addEvents() {
        
    }
}
</code></pre>

上面的代码没有多少东西说，简单提一下，各种子视图的访问权限根据需要设置，这里的子视图都不宜设置外部写权限，最多可读，另外设计了一个sliding属性，标记滑块是否处在滑动拖拽状态，这个主要是为了后续监听的播放过程中更新播放进度时滑块是否更新作为判断依据的。<br />
另外，**对UICodingStyle不感兴趣的，可去掉代码“: UICodingStyle”，而感兴趣的可以浏览一下UICodingStyle协议所带来的好处：代码相当简洁，可读性是不是很好呢**<br />
你也许会问，我去掉代码“: UICodingStyle”就可以了，干嘛一定非要遵循UICodingStyle协议，我自己写一个同名的方法名不就行了么，这里再解释一下，因为遵循UICodingStyle协议后，如果我想写addSubviews方法，我只需要敲self.add 然后编译器的联想功能就会显示出来，我只要回车就好，而且我能保证方法名一样，手动编写，不一定能保证方法名一样，有时会敲错。

### SPTopBar： ###
SPTopBar和SPBottomBar类似，不过交互的UI少一些，不BB了，上代码：
<pre><code>
import UIKit

// MARK: - 定义 SPTopBar，显示标题和返回键
class SPTopBar: UIView {
    /// 毛玻璃作为背景
    fileprivate lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        effectView.alpha = 1
        return effectView
    }()
    /// 顶部导航栏返回键
    fileprivate(set) lazy var backButton: UIButton = {
        let backButton = UIButton.init(type: .system)
        backButton.setImage(UIImage.init(named: "nav_back"), for: .normal)
        backButton.tintColor = UIColor.theme
        return backButton
    }()
    /// 标题
    fileprivate(set) lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "这是标题"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.theme
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        return titleLabel
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.addConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 添加子视图
extension SPTopBar: UICodingStyle {
    func addSubviews() {
        effectView.addSubview(backButton)
        effectView.addSubview(titleLabel)
        self.addSubview(effectView)
    }
    func addConstraints() {
        backButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(0)
            make.width.equalTo(45)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(45)
            make.right.equalTo(-45)
            make.top.bottom.equalTo(0)
        }
        effectView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
}

</code></pre>

没有什么特别的，不需要说什么。
### SPTopBar： ###
好了，顶部的和顶部的bar都已经定义好了，现在就差播放和按钮了，播放和暂停按钮用同一个，而且用原生的UIButton就可以了。下面就就来编写播放器SPPlayer2，什么都不说了，先上代码：<br />
<pre><code>
import UIKit
import AVFoundation


// MARK: - Player 定义
class SPPlayer2: UIView {
    fileprivate(set) lazy var player = AVPlayer.init()
    fileprivate lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer.init(player: self.player)
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    /// 底部操作栏
    fileprivate lazy var bottomBar = SPBottomBar.init(frame: CGRect.zero)
    fileprivate lazy var topNavBar = SPTopBar.init(frame: CGRect.zero)
    fileprivate lazy var playButton: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setImage(UIImage.init(named: "play_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setImage(UIImage.init(named: "pause_icon")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btn.tintColor = UIColor.clear
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(playerLayer)
        self.addSubviews()
        self.addConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
        playerLayer.backgroundColor = UIColor.black.cgColor
    }
}

extension SPPlayer2: UICodingStyle {
    func addSubviews() {
        self.addSubview(bottomBar)
        self.addSubview(topNavBar)
        self.addSubview(playButton)
    }
    func addConstraints() {
        bottomBar.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(44)
        }
        topNavBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(playButton.currentImage!.size)
        }
    }
}


// MARK: - 对外提供接口
extension SPPlayer2 {
    func configure(url: URL, playImmediately: Bool) {
        player.replaceCurrentItem(with: AVPlayerItem.init(url: url))
        if playImmediately {
            player.play()
        }
    }
    func play() {
        player.play()
    }
    func pause() {
        player.pause()
    }
}

</code></pre>
可能你会发现，相对于SPPlayer1而言，就多了30+行代码，而且增加的代码也很直观，一部分是定义懒加载控件，一部分是在遵循UICodingStyle协议的扩展中。<br />
到这里为止，我们的基本的一些交互UI都已经加载上去了，第二大部分已经完成（当然还有一个加载指示器忘记加上去了，后面会加上去）。
## 第三部分：完整的播放器---监听播放器 ##
上面我们在第二部分中，我们虽然添加了一些交互的UI，但是当视频播放的时候，它们并没有任何的变化，因为，我们没有编写更新的代码。<br />
我们先来理一理思路：

* 播放与暂停
* 我们需要显示正确的当前播放的时间点，需要显示视频总时长，这个我们可以从播放的item中获取，由于当前播放的时间点不断地变化，所以我们需要一个定时器；
* 我们需要显示缓冲的进度，所以必须要进行相关的监听，监听什么呢，监听currentItem的loadedTimeRanges属性的变化
* 可拖拽的滑块也要跟着当前播放时间点变化
* 拖拽滑块放手后播放应该跳转到拖拽后的时间点
* 播放状态的可能变化，当处于播放的时候，可能网速慢，缓存跟不上，这个时候需要显示加载指示器，友好的通知用户，视频正在缓冲。所以还需要监听播放的状态，需要监听currentItem的status属性的变化
* 实现横纵品切换

所以，经过分析后，需要1个定时器，实时刷新播放的进度，需要监听currentItem的2个属性值变化，需要实现拖拽滑块功能来实现快进后退的跳转，需要实现横纵屏功能。
### 定时器：CADisplayLink ###
我们并没有采用NSTime来实现刷新，而是CADisplayLink，这是因为CADisplayLink有一定的优势（请查阅其他资料，这里不细说）。但是CADisplayLink会有一个问题，那就是很容易造成循环引用的问题，这个问题网上也有解决方案，有一个解决方式是设计一个代理类，遵循NSProxy，具体的请查阅其他资料，，，，，，利用代理类来打断循环引用。<br />
但是这个方案是基于OC，我最初想翻译一下OC的代码，但是发现有问题，不能写构造方法，写构造方法就编译报错，提示没有调用父类构造方法，问题是父类并没有看到构造方法，我不明白为什么swift不行，有人说swift中类不能继承NSProxy，网上找了很久，目前没有看到有swift版的代码。<br />
但是我仍然想使用，其实有一种方案：利用OC桥接，当然，这并没有说明问题，可是我想要使用swift编写。**难道swift就解决不了了么？？？？？？也不尽然，有办法：** 参考OC中的用法，还是设计代理类WeakProxy，我虽然不能继承NSProxy，但是我可以继承NSObject，NSObject是继承NSProxy的，这样一来，我就可以编写构造方法，然后重写forwardingTarget方法，，，这样就OK啦！ 上代码：
<pre><code>
/// 创建代理类，避免循环引用
    class WeakProxy: NSObject {
        weak var target: AnyObject?
        init(target: AnyObject?) {
            self.target = target
            super.init()
        }
        init(_ target: AnyObject?) {
            self.target = target
            super.init()
        }
        deinit {
            print("WeakProxy deinit")
        }
        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            return target
        }
    }
</code></pre>
创建CADisplayLink：

	link = CADisplayLink.init(target: WeakProxy.init(self), selector: #selector(updateTime))
	link?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
	playButton.addTarget(self, action: #selector(playButtonClicked(_:)), for: .touchUpInside)


### 监听缓冲进度和播放状态：###
监听代码也很简单：

	currentItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
	currentItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)

但是编写KeyPath的过程中，有时容易写错，这里我们可以设计一个结构体，结构体设计一个属性保留这个KeyPath的值，看代码更直观
<pre><code>
struct ObserverKey {
    private(set) var rawValue: String
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
extension ObserverKey {
    static let status = ObserverKey.init(rawValue: "status")
    static let loadedTimeRanges = ObserverKey.init(rawValue: "loadedTimeRanges")
}
</code></pre>
监听代码更改为

	currentItem.addObserver(self, forKeyPath: ObserverKey.status.rawValue, options: .new, context: nil)
    currentItem.addObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue, options: .new, context: nil)

当监听的属性值有变化时，会调用

	func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)

所以，我们还需要重写这个方法，在方法内实时更新交互的UI，上了这段代码：
<pre><code>
// MARK: - 监听
extension SPPlayer {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playItem = object as? AVPlayerItem, playItem == player.currentItem else {
            return
        }
        if keyPath == ObserverKey.status.rawValue {
            switch playItem.status {
            case .readyToPlay:
                activityIndicatorView.stopAnimating()
                if playButton.isSelected {
                    player.play()
                }
            case .failed:
                activityIndicatorView.stopAnimating()
            case .unknown:
                if playButton.isSelected {
                    activityIndicatorView.startAnimating()
                }
            }
        }else if keyPath == ObserverKey.loadedTimeRanges.rawValue {
            // 监听 key: "loadedTimeRanges"， 获取视频的进度缓冲
            let loadedTime = self.avalableDuration(playerItem: playItem)
            let totalTime = CMTimeGetSeconds(playItem.duration)
            let progress = loadedTime/totalTime
            // 改变进度条
            self.bottomBar.progress.progress = Float(progress)
        }
    }
}

</code></pre>
完整的代码，等下后面附上，我们继续讲关键性的代码

### 滑块滑动事件：###
滑块需要监听多个事件，但是我们可以归为2类：按下去 和 失去焦点
<pre><code>
		//slider几个需要监听的事件
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchUpOutside)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchUpInside)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchCancel)
</code></pre>
按下去只需要标记一下：

	@objc fileprivate func sliderTouchDown(_ sender: UISlider) {
        bottomBar.sliding = true
    }
滑块失去焦点后，应该跳转到指定的时间点，跳转关键语句：
	
	func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Swift.Void)
	
### 横纵屏切换：###
设置横屏：

	UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
	
设置纵屏：

	UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

在横纵屏切换后，有些交互的UI需要重更新，所以，必须要设计一个切换后调用的方法，提供给外部调用，当ViewController监听到变化时，调用这个设计的方法实现更新交互UI。

	/// 横纵屏变化
    ///
    /// - Parameters:
    ///   - size: 即将要变换的size
    ///   - coordinator: 即将要变化的coordinator
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let portrait = size.width == min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        bottomBar.orientationButton.isSelected = !portrait
    }
### 播放与暂停：###
这个是最基本，也是必要的功能，只需要对播放按钮监听一下就OK了，然后调用播放器的play与pause方法，当然，有一些细节需要处理。
### 其他一些设计：###
设计一些外部可能需要用到的API

* 是否隐藏顶部标题栏
* 设置标题
* 是否隐藏顶部返回按钮
* 标题栏返回按钮事件
* 是否隐藏底部操作栏

### 附上第三部分SPPlayer的代码：###

<pre><code>

import UIKit
import AVFoundation


struct ObserverKey {
    private(set) var rawValue: String
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
extension ObserverKey {
    static let status = ObserverKey.init(rawValue: "status")
    static let loadedTimeRanges = ObserverKey.init(rawValue: "loadedTimeRanges")
}

// MARK: - Player 定义
class SPPlayer: UIView {
    
    fileprivate(set) lazy var player = AVPlayer.init()
    fileprivate lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer.init(player: self.player)
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    
    /// 大部分UI添加到contentOverlayView上
    fileprivate lazy var contentOverlayView: UIView = {
        let contentOverlayView = UIView()
        contentOverlayView.backgroundColor = UIColor.clear
        contentOverlayView.isUserInteractionEnabled = true
        return contentOverlayView
    }()
    
    /// 底部操作栏
    fileprivate lazy var bottomBar = SPBottomBar.init(frame: CGRect.zero)
    fileprivate lazy var topNavBar = SPTopBar.init(frame: CGRect.zero)
    fileprivate lazy var playButton: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setImage(UIImage.init(named: "play_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setImage(UIImage.init(named: "pause_icon")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btn.tintColor = UIColor.clear
        return btn
    }()
    
    
    /// 加载指示器
    fileprivate var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.isHidden = true
        activityIndicatorView.color = UIColor.theme
        activityIndicatorView.isUserInteractionEnabled = false
        return activityIndicatorView
    }()
    
    fileprivate var link: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(playerLayer)
        
        self.addSubviews()
        self.addConstraints()
        self.addEvents()
        self.adjustUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
        playerLayer.backgroundColor = UIColor.black.cgColor
    }
    
    deinit {
        print("SPPlayer deinit")
        if let currentItem = player.currentItem {
            currentItem.removeObserver(self, forKeyPath: ObserverKey.status.rawValue, context: nil)
            currentItem.removeObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue, context: nil)
        }
        link?.invalidate()
        self.link = nil
    }
    
    
    /// 创建代理类，避免循环引用
    class WeakProxy: NSObject {
        weak var target: AnyObject?
        init(target: AnyObject?) {
            self.target = target
            super.init()
        }
        init(_ target: AnyObject?) {
            self.target = target
            super.init()
        }
        deinit {
            print("WeakProxy deinit")
        }
        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            return target
        }
    }

}


// MARK: - 实现UI协议
extension SPPlayer: UICodingStyle {
    func adjustUI() {
        //横纵屏
        bottomBar.orientationButton.isSelected = !(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height)
    }
    func addSubviews() {
        self.addSubview(contentOverlayView)
        contentOverlayView.addSubview(bottomBar)
        contentOverlayView.addSubview(topNavBar)
        contentOverlayView.addSubview(playButton)
        contentOverlayView.addSubview(activityIndicatorView)
    }
    func addConstraints() {
        contentOverlayView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        bottomBar.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(44)
        }
        topNavBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(contentOverlayView)
            make.size.equalTo(playButton.currentImage!.size)
        }
        activityIndicatorView.snp.makeConstraints { (make) in
            make.center.equalTo(contentOverlayView)
        }
    }
    func addEvents() {
        link = CADisplayLink.init(target: WeakProxy.init(self), selector: #selector(updateTime))
        link?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        playButton.addTarget(self, action: #selector(playButtonClicked(_:)), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenContentOverlayView))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
        //slider几个需要监听的事件
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchUpOutside)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchUpInside)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchCancel)
        
        //横纵屏
        bottomBar.orientationButton.addTarget(self, action: #selector(orientationButtonClicked(_:)), for: .touchUpInside)
    }
}


// MARK: - 监听
extension SPPlayer {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playItem = object as? AVPlayerItem, playItem == player.currentItem else {
            return
        }
        if keyPath == ObserverKey.status.rawValue {
            switch playItem.status {
            case .readyToPlay:
                activityIndicatorView.stopAnimating()
                if playButton.isSelected {
                    player.play()
                }
            case .failed:
                activityIndicatorView.stopAnimating()
            case .unknown:
                if playButton.isSelected {
                    activityIndicatorView.startAnimating()
                }
            }
        }else if keyPath == ObserverKey.loadedTimeRanges.rawValue {
            // 监听 key: "loadedTimeRanges"， 获取视频的进度缓冲
            let loadedTime = self.avalableDuration(playerItem: playItem)
            let totalTime = CMTimeGetSeconds(playItem.duration)
            let progress = loadedTime/totalTime
            // 改变进度条
            self.bottomBar.progress.progress = Float(progress)
        }
    }
}


// MARK: - Helper
extension SPPlayer {
    fileprivate func avalableDuration(playerItem: AVPlayerItem) -> TimeInterval {
        guard let first = playerItem.loadedTimeRanges.first else {
            fatalError()
        }
        let timeRange = first.timeRangeValue
        let start = CMTimeGetSeconds(timeRange.start)
        let end = CMTimeGetSeconds(timeRange.duration)
        let result = start + end
        return result
    }
    func resetAllUI() {
        activityIndicatorView.stopAnimating()
        playButton.isSelected = false
//        bottomBar.playedTimeLabel.text = "00:00"
//        bottomBar.progress.progress = 0
//        bottomBar.slider.setValue(0, animated: true)
//        bottomBar.totalTimeLabel.text =
    }
}

// MARK: - Actions
extension SPPlayer {
    @objc fileprivate func updateTime() {
        // 当前播放时间
        let currentTime = TimeInterval(CMTimeGetSeconds(player.currentTime()))
        // 视频总时长(解释：timescale: 压缩比例)
        let totalTime   = TimeInterval(player.currentItem?.duration.value ?? 0)  / TimeInterval(player.currentItem?.duration.timescale ?? 1)
        // 更新UI
        bottomBar.playedTimeLabel.text = formatPlayTime(secounds: currentTime)
        bottomBar.totalTimeLabel.text = formatPlayTime(secounds: totalTime)
        
        //播放进度
        if !bottomBar.sliding {
            bottomBar.slider.setValue(Float(currentTime/totalTime), animated: true)
        }
    }
    fileprivate func formatPlayTime(secounds: TimeInterval) -> String{
        if secounds.isNaN{
            return "00:00"
        }
        let min = Int(secounds / 60)
        let sec = Int(secounds) % 60
        return String(format: "%02d:%02d", min, sec)
    }

    @objc fileprivate func playButtonClicked(_ sender: UIButton) {
        let playing = sender.isSelected
        sender.isSelected = !sender.isSelected
        if playing {//正在播放
            player.pause()
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { 
                self.contentOverlayView.alpha = 1
            }, completion: nil)
        }else {
            player.play()
            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: { 
                if self.playButton.isSelected, !self.bottomBar.sliding, self.contentOverlayView.alpha == 1 {
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { 
                        self.contentOverlayView.alpha = 0
                    }, completion: nil)
                }
            })
        }
        
    }
    @objc fileprivate func hiddenContentOverlayView() {
        print("hiddenContentOverlayView")
        guard playButton.isSelected else {
            print("处于暂停状态，不能隐藏contentOverlayView")
            return
        }
        
        if self.contentOverlayView.alpha == 1 {//正显示
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.contentOverlayView.alpha = 0
            }, completion: nil)
        }else{//正隐藏状态
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { 
                self.contentOverlayView.alpha = 1
            }, completion: { (finished: Bool) in
                DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: { 
                    if self.playButton.isSelected, !self.bottomBar.sliding, self.contentOverlayView.alpha == 1 {
                        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                            self.contentOverlayView.alpha = 0
                        }, completion: nil)
                    }
                })
            })
        }
    }
    
    
    /// 滑块滑动事件
    ///
    /// - Parameter sender: slider
    @objc fileprivate func sliderTouchDown(_ sender: UISlider) {
        bottomBar.sliding = true
    }
    
    /// 滑块滑动事件
    ///
    /// - Parameter sender: slider
    @objc fileprivate func sliderTouchUpOut(_ sender: UISlider) {
        /// 需要保证readyToPlay的状态，不然拖拽没有任何意义
        switch player.status {
        case .readyToPlay:
            //获取即将跳转的位置
            let nextTime = bottomBar.slider.value * Float(CMTimeGetSeconds(player.currentItem!.duration))
            let seekTime = CMTimeMake(Int64(nextTime), 1)
            //跳转到指定时间节点
            player.seek(to: seekTime, completionHandler: { (finished : Bool) in
                //更新滑块的状态
                self.bottomBar.sliding = false
            })
        default:
            bottomBar.sliding = false
        }
        
        /// 3秒后隐藏
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            if self.playButton.isSelected, !self.bottomBar.sliding, self.contentOverlayView.alpha == 1 {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.contentOverlayView.alpha = 0
                }, completion: nil)
            }
        })
    }
    
    /// 横纵屏切换
    ///
    /// - Parameter sender: 切换按钮
    func orientationButtonClicked(_ sender: UIButton) {
        if sender.isSelected {//需要退出全屏
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }else{//需要全屏
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        }
    }
    
}


// MARK: - 对外提供接口
extension SPPlayer {
    
    /// 设置视频URL
    ///
    /// - Parameters:
    ///   - url: 视频URL
    ///   - playImmediately: 是否立即播放
    func configure(url: URL, playImmediately: Bool) {
        if let currentItem = player.currentItem {
            currentItem.removeObserver(self, forKeyPath: ObserverKey.status.rawValue, context: nil)
            currentItem.removeObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue, context: nil)
        }
        let currentItem = AVPlayerItem.init(url: url)
        currentItem.addObserver(self, forKeyPath: ObserverKey.status.rawValue, options: .new, context: nil)
        currentItem.addObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue, options: .new, context: nil)
        player.replaceCurrentItem(with: currentItem)
        self.resetAllUI()
        if playImmediately {
            activityIndicatorView.startAnimating()
            self.play()
        }
    }
    
    /// 是否隐藏顶部标题栏
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenTopNavBar(_ hidden: Bool) {
        topNavBar.isHidden = hidden
    }
    /// 设置标题
    ///
    /// - Parameter title: 标题
    func setNavTitle(_ title: String?) {
        topNavBar.titleLabel.text = title
    }
    /// 是否隐藏顶部返回按钮
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenBackButton(_ hidden: Bool) {
        topNavBar.backButton.isHidden = hidden
    }
    /// 标题栏返回按钮事件
    ///
    /// - Parameters:
    ///   - target: 响应的target
    ///   - action: 执行的Selector
    ///   - controlEvents: 事件类型
    func backAction(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        topNavBar.backButton.addTarget(target, action: action, for: controlEvents)
    }
    
    /// 是否隐藏底部操作栏
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenBottomBar(_ hidden: Bool) {
        bottomBar.isHidden = hidden
    }
    
    
    
    /// 播放
    func play() {
        if playButton.isSelected {
            return
        }
        self.playButtonClicked(playButton)
    }
    
    /// 暂停
    func pause() {
        if !playButton.isSelected {
            return
        }
        self.playButtonClicked(playButton)
    }
    
    
    /// 横纵屏变化
    ///
    /// - Parameters:
    ///   - size: 即将要变换的size
    ///   - coordinator: 即将要变化的coordinator
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let portrait = size.width == min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        bottomBar.orientationButton.isSelected = !portrait
    }
}
</code></pre>

### SPViewController：###
控制器中相较于之前而言，只需要实现横纵屏切换方法
<pre><code>
// MARK: - 横纵屏
extension SPViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        player.viewWillTransition(to: size, with: coordinator)
        let portrait = size.width == min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        self.navigationController?.navigationBar.isHidden = !portrait
    }
}
</code></pre>

SPViewController的完整代码：
<pre><code>
import UIKit
import SnapKit
import AVFoundation

class SPViewController: UIViewController {
    fileprivate lazy var player: SPPlayer = SPPlayer()
	deinit {
        print("SPViewController deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        player.configure(url: URL.init(string: "https://dn-iyongzai.qbox.me/video/sdyjq7.mp4")!, playImmediately: true)
        player.setNavTitle("速度与激情7")
        player.backAction(self.navigationController, action: #selector(UINavigationController.popViewController(animated:)), for: .touchUpInside)
        self.navigationController?.navigationBar.isHidden = !(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK: - 实现UI协议方法
extension SPViewController: UICodingStyle {
    func adjustUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "No.3 完整版"
    }
    func addSubviews() {
        self.view.addSubview(player)
    }
    func addConstraints() {
        player.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(player.snp.width).dividedBy(16.0/9.0)
        }
    }
}

// MARK: - 横纵屏
extension SPViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        player.viewWillTransition(to: size, with: coordinator)
        let portrait = size.width == min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        self.navigationController?.navigationBar.isHidden = !portrait
    }
}

</code></pre>

到此为止，整个Demo的编写基本已经完成，不过呢，还有一个收尾工作可做可不做，请看最后一部分 <br />
## 第四部分：暴露API ##


如果我们要直接使用封装好的播放器SPPlayer，可是有时我们并不想去繁杂的代码文件中寻找暴露的API，所以我们设计的时候，尽量把需要暴露的东西放在一起，比比如说，所有需要暴露的方法全部编写到一个扩展类中，不要设置私有的访问权限就好了。那么需要暴露一些属性给外部用呢，怎么办，可不可以把属性写到扩展中呢？答案是否定的，扩展中是不允许定义储存属性的，但是可以提供计算属性，所以，如果非要在扩展中暴露属性，那么需要提供计算属性，然后再计算属性里面操作对应的的储存属性。这种把需要暴露的属性或者方法归类在一起，通常这个扩展跟定义都在一个文件中，虽然方便了许多，但是要是同事用，或者工作交接，或者别人用你的播放器的时候，其实并不想过多的了解你的内部代码，人家更想知道，你已经暴露出来的API，虽然有一个扩展把这些API暴露出来，但是也是需要找到具体位置，如果写在文件末尾或许还好，要是在中间，人家不一定发现得了，那么怎么解决这个问题呢？我的方案是：新建文件，然后定义一个协议，通过协议定义方法和属性，扩展一个SPPlayer继承协议，但是在该扩展中，不需要编写任何代码。因为我们需要暴露的代码在SPPlayer定义的那个文件中已经有了一个扩展类，在那个扩展类中已经实现了原有的暴露需要，同时它也实现了所以协议的方法和属性。<br />
上代码：<br />
<pre><code>
import UIKit

protocol PlayerAPI {
    /// 设置视频URL
    ///
    /// - Parameters:
    ///   - url: 视频URL
    ///   - playImmediately: 是否立即播放
    func configure(url: URL, playImmediately: Bool)
    /// 是否隐藏顶部标题栏
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenTopNavBar(_ hidden: Bool)
    /// 设置标题
    ///
    /// - Parameter title: 标题
    func setNavTitle(_ title: String?)
    /// 是否隐藏顶部返回按钮
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenBackButton(_ hidden: Bool)
    /// 标题栏返回按钮事件
    ///
    /// - Parameters:
    ///   - target: 响应的target
    ///   - action: 执行的Selector
    ///   - controlEvents: 事件类型
    func backAction(_ target: Any?, action: Selector, for controlEvents: UIControlEvents)
    /// 是否隐藏底部操作栏
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenBottomBar(_ hidden: Bool)
    /// 播放
    func play()
    /// 暂停
    func pause() 
    /// 横纵屏变化
    ///
    /// - Parameters:
    ///   - size: 即将要变换的size
    ///   - coordinator: 即将要变化的coordinator
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

// MARK: - 通过PlayerProtocol对外提供接口，不暴露内部实现
extension SPPlayer: PlayerAPI {
    
}
</code></pre>

最后，文章写到这里也就结束了，感谢您的阅览，<br />
顺便附上三张截图：

![第一张效果图](https://github.com/IOS-Wheeler/Pics/blob/master/VideoPlayer-AVPlayer-001.jpg?raw=true)
![第二张效果图](https://github.com/IOS-Wheeler/Pics/blob/master/VideoPlayer-AVPlayer-002.jpg?raw=true)
![第三张效果图](https://github.com/IOS-Wheeler/Pics/blob/master/VideoPlayer-AVPlayer-003.jpg?raw=true)
//
//  SPPlayer.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/26.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

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
        
        //静音状态下播放声音
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
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


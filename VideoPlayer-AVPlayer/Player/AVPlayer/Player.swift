//
//  Player.swift
//  FashionMix
//
//  Created by KuaiMeiZhuang on 2017/6/15.
//  Copyright © 2017年 ayong. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher
import SnapKit

fileprivate let kLoadedTimeRanges = "loadedTimeRanges"
fileprivate let kStatus = "status"

// MARK: - Player定义
class Player: UIView {
    fileprivate lazy var player = AVQueuePlayer.init()//播放器
    
    fileprivate lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer.init(player: self.player)
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    fileprivate lazy var contentOverlayView: UIView = {
        let contentOverlayView = UIView()
        contentOverlayView.backgroundColor = UIColor.clear
        return contentOverlayView
    }()
    fileprivate lazy var topNavBar = PlayerTopNavBar.init(frame: CGRect.zero)
    fileprivate lazy var bottomBar = PlayerBottomBar.init(frame: CGRect.zero)
    fileprivate lazy var likeView = PlayerLikeView.init(frame: CGRect.zero)
    fileprivate(set) lazy var preView: UIImageView = {
        let preView = UIImageView()
        preView.contentMode = .scaleAspectFill
        return preView
    }()
    fileprivate lazy var playOrPauseButton: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setImage(UIImage.init(named: "play_play_icon".appending("_").appending(Target.appkey.lowercased()))?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setImage(UIImage.init(named: "play_pause_icon".appending("_").appending(Target.appkey.lowercased()))?.withRenderingMode(.alwaysOriginal), for: .selected)
        btn.tintColor = UIColor.clear
        return btn
    }()
    
    fileprivate var link: CADisplayLink!
    
    fileprivate var videoUrls: [URL] = []
    fileprivate var videoPreViewUrl: URL?
    fileprivate var items: [AVPlayerItem] = []
    fileprivate(set) var playingOpt: Bool?
    fileprivate var navTitle = "" {
        didSet {
            self.topNavBar.titleLabel.text = navTitle
        }
    }
    
    fileprivate var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.isUserInteractionEnabled = true
        activityIndicatorView.color = UIColor.theme
        activityIndicatorView.isHidden = true
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    fileprivate var loadVideoErrorView: UIView = {
        let loadVideoErrorView = UIView()
        loadVideoErrorView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        loadVideoErrorView.isHidden = true
        
        let retryButton = UIButton()
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        retryButton.setTitle("视频加载失败，请点击重试", for: .normal)
        retryButton.setTitleColor(UIColor.white, for: .normal)
        loadVideoErrorView.addSubview(retryButton)
        
        return loadVideoErrorView
    }()
    fileprivate weak var retryTarget: UIResponder?
    fileprivate var retryAction: Selector?
    
    deinit {
        print("Player deinit")
        self.removeItemsObserver()
        items.removeAll()
    }
    
    convenience init(frame: CGRect, videoUrls: [URL], videoPreViewUrl: URL?) {
        self.init(frame: frame)
        self.videoUrls = videoUrls
        self.videoPreViewUrl = videoPreViewUrl
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(playerLayer, at: 0)
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        self.addEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
    }
}

// MARK: - extension Player: UI Protocol
extension Player: UI {
    func addSubviews() {
        self.addSubview(contentOverlayView)
        contentOverlayView.addSubview(preView)
        contentOverlayView.addSubview(playOrPauseButton)
        contentOverlayView.addSubview(topNavBar)
        contentOverlayView.addSubview(bottomBar)
        contentOverlayView.addSubview(likeView)
        contentOverlayView.addSubview(activityIndicatorView)
        contentOverlayView.addSubview(loadVideoErrorView)
    }
    func addConstraints() {
        contentOverlayView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        preView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        playOrPauseButton.snp.makeConstraints { (make) in
            make.center.equalTo(contentOverlayView)
            make.size.equalTo(playOrPauseButton.currentImage?.size ?? CGSize.init(width: 50, height: 50))
        }
        topNavBar.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(44*screenWidth/375)
        }
        bottomBar.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(44*screenWidth/375)
        }
        likeView.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.bottom.equalTo(bottomBar.snp.top).offset(0)
            make.size.equalTo(CGSize.init(width: 55, height: 55))
        }
        activityIndicatorView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        loadVideoErrorView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        loadVideoErrorView.subviews[0].snp.makeConstraints { (make) in
            make.center.equalTo(loadVideoErrorView)
            make.size.equalTo(CGSize.init(width: 200, height: 60))
        }
    }
    func adjustUI() {
        
    }
    func addEvents() {
        playOrPauseButton.addTarget(self, action: #selector(playOrPause(_:)), for: .touchUpInside)
        
        //定时器更新播放时间
        link = CADisplayLink.init(target: WeakProxy.init(target: self), selector: #selector(updateTime))
        link.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapContentOverlayViewAction(_:)))
        contentOverlayView.addGestureRecognizer(tap)
        contentOverlayView.isUserInteractionEnabled = true
        
        //底部slider事件
        // 按下的时候
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        // 弹起的时候
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchUpOutside)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchUpInside)
        bottomBar.slider.addTarget(self, action: #selector(sliderTouchUpOut(_:)), for: .touchCancel)
        
        bottomBar.fullScreenButton.addTarget(self, action: #selector(fullScreenButtonClicked(_:)), for: .touchUpInside)
        (loadVideoErrorView.subviews.first as? UIButton)?.addTarget(self, action: #selector(updateVideo(_:)), for: .touchUpInside)

    }
    func configure(model: Video) {
        videoPreViewUrl = URL.init(string: model.imageUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        preView.kf.setImage(with: videoPreViewUrl)
                
        videoUrls.removeAll()
        self.removeItemsObserver()
        items.removeAll()
        player.removeAllItems()
        model.videoUrls.forEach { (urlString: String) in
            if let url = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "") {
                self.videoUrls.append(url)
                
                let newItem = AVPlayerItem.init(asset: AVURLAsset.init(url: url))
                if player.canInsert(newItem, after: nil) {
                    player.insert(newItem, after: nil)
                }
            }
        }
        items = player.items()
        self.addItemsObserver()
    }
}

// MARK: - extension Player - Helper
extension Player {
    fileprivate func addItemsObserver() {
        items.forEach { (item: AVPlayerItem) in
            // 监听缓冲进度改变
            item.addObserver(self, forKeyPath: kLoadedTimeRanges, options: .new, context: nil)
            // 监听状态改变
            item.addObserver(self, forKeyPath: kStatus, options: .new, context: nil)
        }
    }
    fileprivate func removeItemsObserver() {
        items.forEach { (item: AVPlayerItem) in
            item.removeObserver(self, forKeyPath: kLoadedTimeRanges)
            item.removeObserver(self, forKeyPath: kStatus)
        }
    }
    
    
    fileprivate func avalableDurationWithplayerItem() -> TimeInterval {
        guard let loadedTimeRanges = player.currentItem?.loadedTimeRanges, let first = loadedTimeRanges.first else {
            fatalError()
        }
        let timeRange = first.timeRangeValue
        let start = CMTimeGetSeconds(timeRange.start)
        let end = CMTimeGetSeconds(timeRange.duration)
        let result = start + end
        return result
    }
}

// MARK: - extension Player - Action
extension Player {
    @objc fileprivate func playOrPause(_ sender: UIButton) {
        if !sender.isSelected {//处于暂停或者停止状态，接下来需要播放
            if !self.play() {
                return
            }
        }else{//处于播放状态，接下来需要暂停
            self.pause()
        }
    }
    
    @objc fileprivate func updateTime() {
        // 当前播放到的时间
        let currentTime = TimeInterval(CMTimeGetSeconds(player.currentTime()))
        // 总时间
        let totalTime   = TimeInterval(player.currentItem?.duration.value ?? 0)  / TimeInterval(player.currentItem?.duration.timescale ?? 1)
        // timescale 这里表示压缩比例
        // 赋值
        bottomBar.leftTimeLabel.text = formatPlayTime(secounds: currentTime)
        bottomBar.rightTimeLabel.text = formatPlayTime(secounds: totalTime)
        
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
    
    @objc fileprivate func tapContentOverlayViewAction(_ sender: UITapGestureRecognizer) {
        print("tapContentOverlayViewAction")
        if self.bottomBar.alpha == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.bottomBar.alpha = 1
                self.topNavBar.alpha = 1
                self.playOrPauseButton.alpha = 1
            }) { (stop: Bool) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
                    if self.bottomBar.alpha == 1 && !self.bottomBar.sliding {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.bottomBar.alpha = 0
                            self.topNavBar.alpha = 0
                            if self.playingOpt != nil, self.playingOpt! {
                                self.playOrPauseButton.alpha = 0
                            }
                        })
                    }
                })
            }
        }
    }
    @objc fileprivate func sliderTouchDown(_ sender: UISlider) {
        bottomBar.sliding = true
    }
    @objc fileprivate func sliderTouchUpOut(_ sender: UISlider) {
        if player.status == .readyToPlay {
            let duration = bottomBar.slider.value * Float(CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(0, 1)))
            let seekTime = CMTimeMake(Int64(duration), 1)
            // 指定视频位置
            player.seek(to: seekTime, completionHandler: { (b: Bool) in
                // 别忘记改状态
                self.bottomBar.sliding = false
            })
        }else{
            self.bottomBar.sliding = false
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
            if self.bottomBar.alpha == 1 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.bottomBar.alpha = 0
                    self.topNavBar.alpha = 0
                    if self.playingOpt != nil, self.playingOpt! {
                        self.playOrPauseButton.alpha = 0
                    }
                })
            }
        })
    }
    
    func fullScreenButtonClicked(_ sender: UIButton) {
        if sender.isSelected {//需要退出全屏
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }else{//需要全屏
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        }        
//        sender.isSelected = !sender.isSelected;
    }
}


// MARK: - extension Player - 监听视频播放
extension Player {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("keyPath: \(keyPath ?? "nil")")
        guard let playerItem = object as? AVPlayerItem else { return  }
        print("视频地址：\((playerItem.asset as? AVURLAsset)?.url.absoluteString ?? "未知的视频地址")")
        guard playerItem === player.currentItem else {
            return
        }
        if keyPath == kLoadedTimeRanges {
            //监听"loadedTimeRanges"，获取当前视频的进度缓冲
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let progress = loadedTime/totalTime
            // 改变进度条
            self.bottomBar.progress.progress = Float(progress)
        }else if keyPath == kStatus{
            // 监听状态改变
            print("status: \(playerItem.status.rawValue)")
            switch playerItem.status {
            case .readyToPlay:
                activityIndicatorView.stopAnimating()
                // 只有在这个状态下才能播放
                if let playing = playingOpt, playing == true {
                    self.readyPlay()
                }
                loadVideoErrorView.isHidden = true
            case .unknown:
                if let playing = playingOpt, playing == true {
                    activityIndicatorView.isHidden = false
                    activityIndicatorView.startAnimating()
                }
                loadVideoErrorView.isHidden = true
            case .failed:
                activityIndicatorView.stopAnimating()
                loadVideoErrorView.isHidden = false
            }
        }
    }
}

// MARK: - extension Player - 真正有条件可以播放
extension Player {
    // MARK: - readyPlay()
    fileprivate func readyPlay() {
        guard player.status == .readyToPlay else {
            return
        }
        player.play()
        if !preView.isHidden {
            preView.isHidden = true
        }
        if bottomBar.alpha != 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.bottomBar.alpha = 0
                    self.topNavBar.alpha = 0
                    self.playOrPauseButton.alpha = 0
                })
            })
        }
        //播放按钮需要单独设置，因为有可能bottomBar和topNavBar隐藏了，但是playOrPauseButton需要显示，所以当再次点击播放的时候，就不符合上面的条件，所以单独设置
        if self.playOrPauseButton.alpha != 0 {
            self.playOrPauseButton.alpha = 0
        }
    }
}


// MARK: - 加载视频失败
extension Player {
    @objc fileprivate func updateVideo(_ sender: UIButton) {
        print("updateVideo")
        guard retryTarget != nil, retryAction != nil else {
            return
        }
        loadVideoErrorView.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        retryTarget?.performSelector(onMainThread: retryAction!, with: sender, waitUntilDone: true)
    }
}



// MARK: - extension Player: PlayerAPI 提供给外部调用
extension Player {
    
    /// 标题
    var title: String {
        get {
            return navTitle
        }
        set {
            navTitle = newValue
        }
    }
    
    var fullScreenButton: UIButton {
        get {
            return bottomBar.fullScreenButton
        }
    }
    
    /// 播放
    ///
    /// - Returns: 如果处于播放的前提下返回true，否则false
    func play() -> Bool {
        if player.currentItem == nil {
            return false
        }
        playingOpt = true
        switch player.currentItem!.status {
        case .readyToPlay:
            self.readyPlay()
            playOrPauseButton.isSelected = true
            preView.isHidden = true
            
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
            loadVideoErrorView.isHidden = true
        case .unknown:
            playOrPauseButton.isSelected = true
            
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            loadVideoErrorView.isHidden = true
        case .failed:
            playOrPauseButton.isSelected = false
            
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
            loadVideoErrorView.isHidden = false
        }
        
        return playOrPauseButton.isSelected
    }
    
    /// 暂停播放
    func pause() {
        playingOpt = false
        player.pause()
        playOrPauseButton.isSelected = false
    }
    
    func showTitleBar(_ show: Bool) {
        topNavBar.isHidden = show
    }
    
    func backButtonBind(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        topNavBar.backButton.addTarget(target, action: action, for: controlEvents)
    }
    func likeButtonBindingTouchUpInside(_ target: UIResponder, action: Selector) {
        likeView.likeButtonBindingTouchUpInside(target, action: action)
    }
    var likeCount: String {
        get {
            return likeView.likeCountLabel.text ?? ""
        }
        set {
            likeView.likeCountLabel.text = newValue
        }
    }
    
    func retryButtonBindingTouchUpInside(_ target: UIResponder, action: Selector) {
        retryTarget = target
        retryAction = action
    }
    func retryFailed() {
        loadVideoErrorView.isHidden = false
        activityIndicatorView.stopAnimating()
    }

}



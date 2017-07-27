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
    
    fileprivate var link: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(playerLayer)
        
        self.addSubviews()
        self.addConstraints()
        self.addEvents()
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

extension SPPlayer: UI {
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
    func addEvents() {
        link = CADisplayLink.init(target: WeakProxy.init(self), selector: #selector(updateTime))
        link?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
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
                break
            case .failed:
                break
            case .unknown:
                break
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

}


// MARK: - 对外提供接口
extension SPPlayer {
    
    func configure(url: URL, playImmediately: Bool) {
        if let currentItem = player.currentItem {
            currentItem.removeObserver(self, forKeyPath: ObserverKey.status.rawValue, context: nil)
            currentItem.removeObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue, context: nil)
        }
        let currentItem = AVPlayerItem.init(url: url)
        currentItem.addObserver(self, forKeyPath: ObserverKey.status.rawValue, options: .new, context: nil)
        currentItem.addObserver(self, forKeyPath: ObserverKey.loadedTimeRanges.rawValue, options: .new, context: nil)
        player.replaceCurrentItem(with: currentItem)
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


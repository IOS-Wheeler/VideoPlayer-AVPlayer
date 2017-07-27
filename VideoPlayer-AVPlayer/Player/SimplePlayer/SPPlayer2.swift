//
//  SPPlayer2.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/27.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

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

extension SPPlayer2: UI {
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

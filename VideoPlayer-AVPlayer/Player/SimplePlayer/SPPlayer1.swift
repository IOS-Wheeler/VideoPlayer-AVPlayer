//
//  SPPlayer1.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/27.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit
import AVFoundation


// MARK: - Player 定义
class SPPlayer1: UIView {
    
    fileprivate lazy var player = AVPlayer.init()
    fileprivate lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer.init(player: self.player)
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
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

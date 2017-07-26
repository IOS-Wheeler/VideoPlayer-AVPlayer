//
//  SPPlayer.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/26.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit
import AVFoundation


// MARK: - Player 定义
class SPPlayer: UIView {
    
    lazy var player = AVPlayer.init()
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
        playerLayer.backgroundColor = UIColor.red.cgColor
    }
}

extension SPPlayer {
    func play() {
        player.play()
    }
    func pause() {
        player.pause()
    }
}

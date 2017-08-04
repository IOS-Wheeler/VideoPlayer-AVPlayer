//
//  WPPlayer.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/8/3.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Player 定义
class WPPlayer: SPPlayer {
    
    /// 顶部关闭按钮
    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton.init(type: .system)
        closeButton.setImage(UIImage.init(named: "cancel"), for: .normal)
        closeButton.tintColor = UIColor.white
        return closeButton
    }()
    
    
    /// 播放按钮
    fileprivate lazy var playButton: UIButton = {
        let btn = UIButton.init(type: .system)
        btn.setImage(UIImage.init(named: "play_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        //btn.setImage(UIImage.init(named: "pause_icon")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btn.tintColor = UIColor.clear
        return btn
    }()
    
    fileprivate lazy var preview: UIImageView = {
        let preview = UIImageView()
        preview.layer.masksToBounds = true
        preview.contentMode = .scaleAspectFill
        preview.isUserInteractionEnabled = true
        return preview
    }()
    
    fileprivate var playActionHandle: (() -> Void)?
    fileprivate var closeActionHandle: (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        self.addSubviews()
        self.addConstraints()
        self.addEvents()
        self.adjustUI()

        self.hiddenAllControl(true)
        self.updating { (currentTime: TimeInterval, duration: TimeInterval, status: AVPlayerItemStatus) in
            print("currentTime:\(currentTime)")
            print("duration:\(duration)")
            print("status:\(status)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension WPPlayer {
    override func addSubviews() {
        super.addSubviews()
        preview.addSubview(playButton)
        self.addSubview(preview)
        self.addSubview(closeButton)
    }
    override func addConstraints() {
        super.addConstraints()
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(playButton.superview!)
            make.size.equalTo(playButton.currentImage!.size)
        }
        preview.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        closeButton.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
    }
    override func addEvents() {
        playButton.addTarget(self, action: #selector(playAction(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showUIs))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    override func adjustUI() {
        super.adjustUI()
        closeButton.isHidden = true
    }
}


// MARK: - Action
extension WPPlayer {
    @objc fileprivate func playAction(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        self.play()
        preview.isHidden = true
        
        if playActionHandle != nil {
            playActionHandle!()
        }
        
        sender.isUserInteractionEnabled = true
    }
    @objc fileprivate func closeAction(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        
        self.pause()
        closeButton.isHidden = true
        preview.isHidden = false
        
        if closeActionHandle != nil {
            closeActionHandle!()
        }
        
        sender.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func showUIs() {
        closeButton.isHidden = !closeButton.isHidden
        
    }
}

// MARK: - 对外提供接口
extension WPPlayer {
    func setPlayAction(_ handle: (() -> Void)?) {
        self.playActionHandle = handle
    }
    func setCloseAction(_ handle: (() -> Void)?) {
        self.closeActionHandle = handle
    }
}


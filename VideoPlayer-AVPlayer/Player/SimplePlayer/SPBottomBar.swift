//
//  SPBottomBar.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/27.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

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


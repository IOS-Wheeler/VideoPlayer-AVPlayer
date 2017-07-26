//
//  PlayerBottomBar.swift
//  FashionMix
//
//  Created by KuaiMeiZhuang on 2017/6/21.
//  Copyright © 2017年 ayong. All rights reserved.
//

import UIKit

// MARK: - 定义BottomBar（播放器底部操作UI）
class PlayerBottomBar: UIView {
    fileprivate lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        effectView.alpha = 1
        
        return effectView
    }()
    /// 时间
    fileprivate(set) lazy var leftTimeLabel: UILabel = {
        let leftTimeLabel = UILabel()
        leftTimeLabel.font = UIFont.systemFont(ofSize: 10)
        leftTimeLabel.textColor = UIColor.theme
        leftTimeLabel.text = "00:00"
        leftTimeLabel.textAlignment = .right
        
        return leftTimeLabel
    }()
    /// 全屏按钮
    fileprivate(set) lazy var fullScreenButton: UIButton = {
        let fullScreenButton = UIButton.init(type: .custom)
        fullScreenButton.tintColor = UIColor.theme
        fullScreenButton.setImage(UIImage.init(named: "go_big_video")?.tintColor(UIColor.theme), for: .normal)
        fullScreenButton.setImage(UIImage.init(named: "go_small_video")?.tintColor(UIColor.theme), for: .selected)
        return fullScreenButton
    }()
    /// 总时间
    fileprivate(set) lazy var rightTimeLabel: UILabel = {
        let rightTimeLabel = UILabel()
        rightTimeLabel.text = "计算中..."
        rightTimeLabel.textColor = UIColor.theme
        rightTimeLabel.textAlignment = .left
        rightTimeLabel.font = UIFont.systemFont(ofSize: 10)
        return rightTimeLabel
    }()
    
    /// 进度
    fileprivate(set) lazy var progress: UIProgressView = {
        let progress = UIProgressView.init(frame: CGRect.zero)
        progress.tintColor = UIColor.theme
        return progress
    }()
    
    /// 滑块
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

// MARK: - extension BottomBar: UI Protocol
extension PlayerBottomBar: UI {
    func addSubviews() {
        effectView.addSubview(leftTimeLabel)
        effectView.addSubview(fullScreenButton)
        effectView.addSubview(rightTimeLabel)
        effectView.addSubview(progress)
        effectView.addSubview(slider)
        
        self.addSubview(effectView)
    }
    func addConstraints() {
        leftTimeLabel.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(0)
            make.width.equalTo(35)
        }
        fullScreenButton.snp.makeConstraints { (make) in
            make.top.bottom.right.equalTo(0)
            make.width.equalTo(44)
        }
        rightTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.right.equalTo(fullScreenButton.snp.left)
            make.width.equalTo(35)
        }
        progress.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(rightTimeLabel.snp.left).offset(-4)
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
                let img = image.tintColor(UIColor.theme)
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

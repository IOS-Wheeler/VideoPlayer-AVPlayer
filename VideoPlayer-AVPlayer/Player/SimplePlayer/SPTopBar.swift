//
//  SPTopBar.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/27.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

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

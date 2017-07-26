//
//  PlayerTopNavBar.swift
//  FashionMix
//
//  Created by KuaiMeiZhuang on 2017/6/21.
//  Copyright © 2017年 ayong. All rights reserved.
//

import UIKit

// MARK: - 定义 TopNavBar （播放器顶部操作UI）
class PlayerTopNavBar: UIView {
    fileprivate lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        effectView.alpha = 1
        
        return effectView
    }()
    
    fileprivate(set) lazy var backButton: UIButton = {
        let backButton = UIButton.init(type: .system)
        backButton.tintColor = UIColor.theme
        backButton.setImage(UIImage.init(named: "nav_back"), for: .normal)
        //        backButton.isHidden = true
        return backButton
    }()
    //    [backButton addTarget:self action:@selector(existFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    fileprivate(set) lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.theme
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

// MARK: - extension TopNavBar: UI Protocol
extension PlayerTopNavBar: UI {
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

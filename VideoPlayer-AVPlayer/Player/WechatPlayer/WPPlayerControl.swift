//
//  WPPlayerControl.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/8/3.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit

class WPPlayerControl: UIView {
    
    /// 顶部关闭按钮
    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton.init(type: .system)
        closeButton.setImage(UIImage.init(named: "cancel"), for: .normal)
        closeButton.tintColor = UIColor.theme
        return closeButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.theme
        
        self.addSubviews()
        self.addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension WPPlayerControl: UICodingStyle {
    func addSubviews() {
        self.addSubview(closeButton)
    }
    func addConstraints() {
        closeButton.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
    }
}

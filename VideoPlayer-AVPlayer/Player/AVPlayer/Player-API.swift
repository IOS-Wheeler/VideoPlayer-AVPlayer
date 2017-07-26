//
//  Player-API.swift
//  FashionMix
//
//  Created by KuaiMeiZhuang on 2017/6/20.
//  Copyright © 2017年 ayong. All rights reserved.
//

import UIKit

protocol PlayerAPI {
    /// 标题
    var title: String { get set }
    /// 全屏播放
    var fullScreenButton: UIButton { get }
    
    /// 播放
    ///
    /// - Returns: 如果处于播放的前提下返回true，否则false
    func play() -> Bool
    
    /// 暂停播放
    func pause()
    
    /// 是否显示标题栏
    func showTitleBar(_ show: Bool)
    
    /// 标题栏返回按钮添加事件
    func backButtonBind(_ target: Any?, action: Selector, for controlEvents: UIControlEvents)
    
    /// 点赞
    func likeButtonBindingTouchUpInside(_ target: UIResponder, action: Selector)
    /// 点赞数
    var likeCount: String { get set }
    
    /// 重试操作
    func retryButtonBindingTouchUpInside(_ target: UIResponder, action: Selector)
    func retryFailed()
    
}

// MARK: - 通过PlayerProtocol对外提供接口，不暴露内部实现
extension Player: PlayerAPI {
    
}

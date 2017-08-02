//
//  SPPlayer-API.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/28.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit

protocol PlayerAPI {
    
    /// 设置视频URL
    ///
    /// - Parameters:
    ///   - url: 视频URL
    ///   - playImmediately: 是否立即播放
    ///   - preViewURL: 预览图
    func configure(url: URL, playImmediately: Bool, preViewURL: URL?)
    
    /// 是否隐藏顶部标题栏
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenTopNavBar(_ hidden: Bool)
    
    /// 设置标题
    ///
    /// - Parameter title: 标题
    func setNavTitle(_ title: String?)
    
    /// 是否隐藏顶部返回按钮
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenBackButton(_ hidden: Bool)
    
    /// 标题栏返回按钮事件
    ///
    /// - Parameters:
    ///   - target: 响应的target
    ///   - action: 执行的Selector
    ///   - controlEvents: 事件类型
    func backAction(_ target: Any?, action: Selector, for controlEvents: UIControlEvents)
    
    
    /// 是否隐藏底部操作栏
    ///
    /// - Parameter hidden: 是否隐藏
    func hiddenBottomBar(_ hidden: Bool)
    
    
    /// 播放
    func play()
    
    /// 暂停
    func pause() 
    
    /// 横纵屏变化
    ///
    /// - Parameters:
    ///   - size: 即将要变换的size
    ///   - coordinator: 即将要变化的coordinator
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

// MARK: - 通过PlayerProtocol对外提供接口，不暴露内部实现
extension SPPlayer: PlayerAPI {
    
}


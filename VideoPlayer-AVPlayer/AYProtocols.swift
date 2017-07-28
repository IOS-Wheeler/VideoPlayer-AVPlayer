//
//  AYProtocols.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/26.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import Foundation


// MARK: - 定义UICodingStyle协议,定义几个方法（UICodingStyle的设计只是为了让代码看起来更加美观，优雅）
protocol UICodingStyle {
    /// 用于调整UI的接口
    func adjustUI()
    
    /// UI添加事件
    func addEvents()
    
    /// 用来添加子视图的接口
    func addSubviews()
    
    /// 用来给子视图添加约束的接口
    func addConstraints()
    
    /// 设置数据源
    func configure<T>(model: T)
}


// MARK: - 默认实现
extension UICodingStyle {
    /// 用于调整UI的接口
    func adjustUI(){}
    
    /// UI添加事件
    func addEvents(){}
    
    /// 用来添加子视图的接口
    func addSubviews(){}
    
    /// 用来给子视图添加约束的接口
    func addConstraints(){}
    
    /// 设置数据源
    func configure<T>(model: T) {}
}

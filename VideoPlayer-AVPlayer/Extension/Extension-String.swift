//
//  Extension-String.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/26.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import Foundation
/// 获取运行时的CFBundleExecutable
let executable = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
// MARK: - 在调用NSClassFromString方法的时候，swift跟OC的差别还是蛮大的，由字符串转为类型的时候  如果类型是自定义的 需要在类型字符串前边加上你的项目的名字！
extension String {
    var execClassName: String {
        if self.hasPrefix("\(executable + ".")") {
            return self
        }
        return executable + "." + self
    }
    
    var nsClass: Swift.AnyClass? {
        if let aClass = NSClassFromString(self) {
            return aClass
        }
        if let aClass = NSClassFromString(self.execClassName) {
            return aClass
        }
        
        return nil
    }
}


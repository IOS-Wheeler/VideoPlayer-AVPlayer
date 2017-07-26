//
//  NetWorkCheck.swift
//  FashionMix
//
//  Created by Tyler.Yin on 2017/6/20.
//  Copyright © 2017年 ayong. All rights reserved.
//

import UIKit

enum NetWorkStates: Int {
    case none       = 0
    case wwan2G     = 1
    case wwan3G     = 2
    case wwan4G     = 3
    //case wwan5G     = 4
    case wifi       = 5
    
    
    func description() -> String {
        switch self {
        case .none:
            return "无网络"
        case .wifi:
            return "Wifi"
        case .wwan2G:
            return "2G"
        case .wwan3G:
            return "3G"
        case .wwan4G:
            return "4G"
        }
    }
}

func getNetWorkStates() -> NetWorkStates {
    let app = UIApplication.shared
    var netType = 0
    if let children = ((app.value(forKeyPath: "statusBar") as? NSObject)?.value(forKeyPath: "foregroundView") as? UIView)?.subviews {
        for child in children {
            if child.isKind(of: NSClassFromString("UIStatusBarDataNetworkItemView")!) {
                //获取到状态栏
                netType = child.value(forKeyPath: "dataNetworkType") as! Int
            }
        }
    }
    return NetWorkStates.init(rawValue: netType)!
}

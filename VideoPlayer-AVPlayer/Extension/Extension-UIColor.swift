//
//  Extension-UIColor.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/27.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import Foundation
import UIKit


//MARK: 第一种方式是给String添加扩展
extension String {
    /// 将十六进制颜色转换为UIColor
    func uiColor() -> UIColor {
        
        var hexColorString = self
        
        if hexColorString.contains("#") {
            hexColorString = hexColorString[1..<7]
        }
        
        // 存储转换后的数值
        var red:UInt32 = 0, green:UInt32 = 0, blue:UInt32 = 0
        
        // 分别转换进行转换
        Scanner(string: hexColorString[0..<2]).scanHexInt32(&red)
        
        Scanner(string: hexColorString[2..<4]).scanHexInt32(&green)
        
        Scanner(string: hexColorString[4..<6]).scanHexInt32(&blue)
        
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
}


//MARK: 第二种方式是给UIColor添加扩展
extension UIColor {
    
    /// 用十六进制颜色创建UIColor
    ///
    /// - Parameter hexColor: 十六进制颜色 (0F0F0F)
    convenience init(hexColor: String) {
        
        var hexColorString = hexColor
        
        if hexColorString.contains("#") {
            hexColorString = hexColorString[1..<7]
        }
        
        // 存储转换后的数值
        var red:UInt32 = 0, green:UInt32 = 0, blue:UInt32 = 0
        
        // 分别转换进行转换
        Scanner(string: hexColorString[0..<2]).scanHexInt32(&red)
        
        Scanner(string: hexColorString[2..<4]).scanHexInt32(&green)
        
        Scanner(string: hexColorString[4..<6]).scanHexInt32(&blue)
        
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
}

//MARK: 两种方式都需要用到的扩展

extension String {
    
    /// String使用下标截取字符串
    /// 例: "示例字符串"[0..<2] 结果是 "示例"
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            
            return self[startIndex..<endIndex]
        }
    }
}



// MARK: 随机颜色
extension UIColor {
    class func randColor() -> UIColor {
        return UIColor.init(red: CGFloat(arc4random()%(256-124)+124)/255.0, green: CGFloat(arc4random()%(256-124)+124)/255.0, blue: CGFloat(arc4random()%(256-124)+124)/255.0, alpha: 1)
    }
}



// MARK: - 扩展几个常用的颜色
extension UIColor {
    fileprivate static var lightRedColor = UIColor.init(hexColor: "#ea4a43")
    static var lightRed: UIColor {
        get{
            return lightRedColor
        }
    }
    
    static var theme: UIColor {
        get{
            return lightRedColor
        }
    }
    
}

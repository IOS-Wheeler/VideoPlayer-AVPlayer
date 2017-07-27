//
//  Extension-UIImage.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/27.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func from(tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        tintColor.setFill()
        let bounds = CGRect.init(origin: CGPoint.zero, size: self.size)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
}

//
//  SPViewController.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/26.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class SPViewController: UIViewController {
    
    fileprivate lazy var player: SPPlayer = SPPlayer()
    
    
    
    deinit {
        print("SPViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        
        let videoURLString = "https://dn-iyongzai.qbox.me/video/sdyjq7.mp4"
        let previewURLString = "https://github.com/IOS-Wheeler/Pics/blob/master/VideoPlayer-AVPlayer-pre.jpg?raw=true"
        player.configure(url: URL.init(string: videoURLString)!, playImmediately: false, preViewURL: URL.init(string: previewURLString)!)
        player.setNavTitle("速度与激情7")
        player.backAction(self.navigationController, action: #selector(UINavigationController.popViewController(animated:)), for: .touchUpInside)
        self.navigationController?.navigationBar.isHidden = !(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK: - 实现UI协议方法
extension SPViewController: UICodingStyle {
    func adjustUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "No.3 完整版"
    }
    func addSubviews() {
        self.view.addSubview(player)
    }
    func addConstraints() {
        player.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(player.snp.width).dividedBy(16.0/9.0)
        }
    }
}

// MARK: - 横纵屏
extension SPViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        player.viewWillTransition(to: size, with: coordinator)
        let portrait = size.width == min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        self.navigationController?.navigationBar.isHidden = !portrait
    }
}

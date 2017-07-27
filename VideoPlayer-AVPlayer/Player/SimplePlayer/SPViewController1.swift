//
//  SPViewController1.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/27.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class SPViewController1: UIViewController {
    
    fileprivate lazy var player: SPPlayer1 = SPPlayer1()
    
    
    
    deinit {
        print("SPViewController1 deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        
        player.configure(url: URL.init(string: "https://dn-iyongzai.qbox.me/video/sdyjq7.mp4")!, playImmediately: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SPViewController1: UI {
    func adjustUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "No.1 添加播放器"
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

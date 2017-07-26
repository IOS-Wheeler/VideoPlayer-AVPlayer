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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if player.player.currentItem == nil {
//            player.player.replaceCurrentItem(with: AVPlayerItem.init(url: URL.init(string: "http://otp24ch3j.bkt.clouddn.com/video/mp4/sdyjq7.mp4")!))
            player.player.replaceCurrentItem(with: AVPlayerItem.init(url: URL.init(string: "http://qnugc.kuaimeizhuang.com/20193374-2126949E-B137-4A78-A873-E53EE9DDCED0.mp4")!))
//            DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
                self.player.play()
//            })
        }
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

extension SPViewController: UI {
    func adjustUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
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

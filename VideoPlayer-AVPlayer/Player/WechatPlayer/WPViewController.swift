//
////  WPViewController.swift
////  VideoPlayer-AVPlayer
////
////  Created by ayong on 2017/8/3.
////  Copyright © 2017年 IOS-Wheeler. All rights reserved.
////
//
//import UIKit
//import SnapKit
//import AVFoundation
//
//class WPViewController: UIViewController {
//    
//    fileprivate lazy var player: WPPlayer = WPPlayer()
//    //fileprivate lazy var playerControl: WPPlayerControl = WPPlayerControl.init(frame: CGRect.zero)
//    
//    
//    
//    deinit {
//        print("SPViewController1 deinit")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.addSubviews()
//        self.addConstraints()
//        self.addEvents()
//        self.adjustUI()
//        
//        let videoURLString = "https://dn-iyongzai.qbox.me/video/sdyjq7.mp4"
//        let previewURLString = "https://github.com/IOS-Wheeler/Pics/blob/master/VideoPlayer-AVPlayer-pre.jpg?raw=true"
//        player.configure(url: URL.init(string: videoURLString)!, playImmediately: false, previewURL: URL.init(string: previewURLString)!)
//        //player.backAction(self.navigationController, action: #selector(UINavigationController.popViewController(animated:)), for: .touchUpInside)
//        self.navigationController?.navigationBar.isHidden = !(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    /*
//     // MARK: - Navigation
//     
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//    
//}
//
//extension WPViewController: UICodingStyle {
//    func adjustUI() {
//        self.view.backgroundColor = UIColor.white
//        self.navigationController?.navigationBar.isTranslucent = false
//        
//    }
//    func addSubviews() {
//        self.view.addSubview(player)
//    }
//    func addConstraints() {
//        player.snp.makeConstraints { (make) in
//            make.top.left.right.equalTo(0)
//            make.height.equalTo(player.snp.width).dividedBy(16.0/9.0)
//        }
//    }
//    func addEvents() {
//        player.setPlayAction {
//            DispatchQueue.main.async(execute: {
//                self.navigationController?.view.addSubview(self.player)
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.player.snp.remakeConstraints({ (make) in
//                        make.edges.equalTo(UIEdgeInsets.zero)
//                    })
//                    self.player.layoutIfNeeded()
//                }, completion: { (finished: Bool) in
//                    
//                })
//            })
//        }
//        
//        player.setCloseAction {
//            DispatchQueue.main.async(execute: { 
//                self.view.addSubview(self.player)
//                self.player.snp.makeConstraints { (make) in
//                    make.top.left.right.equalTo(0)
//                    make.height.equalTo(self.player.snp.width).dividedBy(16.0/9.0)
//                }
//            })
//        }
//    }
//}


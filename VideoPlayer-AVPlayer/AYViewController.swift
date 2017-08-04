//
//  AYViewController.swift
//  VideoPlayer-AVPlayer
//
//  Created by ayong on 2017/7/26.
//  Copyright © 2017年 IOS-Wheeler. All rights reserved.
//

import UIKit

class AYViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: self.view.bounds, style: .plain)
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    fileprivate var data = [("AVPlayer的简单使用",[("No.1 添加播放器", "SPViewController1"), ("No.2 添加UI", "SPViewController2"), ("No.3 完整版", "SPViewController")]),
                            ("仿微信播放器",[("仿微信播放", "WPViewController")])]
//    fileprivate var data = [("AVPlayer的简单使用",[("No.1 添加播放器", "SPViewController1"), ("No.2 添加UI", "SPViewController2"), ("No.3 完整版", "SPViewController")])]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension AYViewController: UICodingStyle {
    func adjustUI() {
        
    }
    func addSubviews() {
        self.view.addSubview(tableView)
    }
    func addConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

extension AYViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cs = data[indexPath.section].1[indexPath.row].1.nsClass as? UIViewController.Type {
            let vc = cs.init()
            self.show(vc, sender: self)
        }
        
    }
}

extension AYViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].1.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.textLabel?.text = data[indexPath.section].1[indexPath.row].0
        
        return cell!
    }
}





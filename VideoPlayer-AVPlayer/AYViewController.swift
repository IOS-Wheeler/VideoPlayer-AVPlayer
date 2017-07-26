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
    
    fileprivate var data = [("简单例子", "SPViewController")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubviews()
        self.addConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension AYViewController: UI {
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
        if let cs = data[indexPath.row].1.nsClass as? UIViewController.Type {
            let vc = cs.init()
            self.show(vc, sender: self)
        }
        
    }
}

extension AYViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = data[indexPath.row].0
        
        return cell!
    }
}





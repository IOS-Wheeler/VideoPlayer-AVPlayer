//
//  PlayerLikeView.swift
//  FashionMix
//
//  Created by KuaiMeiZhuang on 2017/6/21.
//  Copyright © 2017年 ayong. All rights reserved.
//

import UIKit

// MARK: - 定义 LikeView（点赞按钮）
class PlayerLikeView: UIView {
    fileprivate(set) lazy var likeCountLabel: UILabel = {
        let likeCountLabel = UILabel()
        likeCountLabel.font = UIFont.systemFont(ofSize: 10)
        likeCountLabel.text = "0"
        likeCountLabel.textColor = UIColor.white
        likeCountLabel.textAlignment = .center
        
        return likeCountLabel
    }()
    fileprivate lazy var countBackImageView: UIImageView = {
        let countBackImageView = UIImageView()
        countBackImageView.contentMode = .center
        countBackImageView.image = UIImage.init(named: "likeVideo_count_bg_pink")?.tintColor(UIColor.theme)
        return countBackImageView
    }()
    fileprivate lazy var likeButton: UIButton = {
        let likeButton = UIButton.init(type: .custom)
        let appIdentifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        switch appIdentifier {
        case "com.media8s.Beauty":
            likeButton.setImage(UIImage.init(named: "likeVideo_before"), for: .normal)
        case "com.kuaimeizhuang.jbeauty":
            likeButton.setImage(UIImage.init(named: "likeVideo_before"), for: .normal)
        case "com.kuaimeizhuang.mika":
            likeButton.setImage(UIImage.init(named: "likeVideo_mika_before"), for: .normal)
        case "com.kuaimeizhuang.fashionmix":
            likeButton.setImage(UIImage.init(named: "likeVideo_fashionmix_before"), for: .normal)
        case "com.kuaimeizhuang.cradle":
            likeButton.setImage(UIImage.init(named: "likeVideo_cradle_before"), for: .normal)
        default:
            break
        }
        likeButton.setImage(UIImage.init(named: "likeVideo_after")?.tintColor(UIColor.theme), for: .selected)
        likeButton.imageEdgeInsets = UIEdgeInsets.init(top: -8, left: 0, bottom: 8, right: 0)

        return likeButton
    }()
    fileprivate weak var likeActionTarget: UIResponder?
    fileprivate var likeActionSelector: Selector?
    fileprivate var likeVideoAnimationImage: UIImage? {
        return UIImage.init(named: "likeVideo_after")?.tintColor(UIColor.theme)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.addConstraints()
        self.adjustUI()
        self.addEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - extension LikeView: UI Protocol
extension PlayerLikeView: UI {
    func addSubviews() {
        self.addSubview(likeButton)
        self.addSubview(countBackImageView)
        self.addSubview(likeCountLabel)
    }
    func addConstraints() {
        likeButton.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        countBackImageView.snp.makeConstraints { (make) in
            make.top.equalTo(likeButton.snp.centerY)
            make.left.bottom.right.equalTo(self)
        }
        likeCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(countBackImageView.snp.top)
            make.left.equalTo(countBackImageView.snp.left)
            make.bottom.equalTo(countBackImageView.snp.bottom)
            make.right.equalTo(countBackImageView.snp.right)
        }
    }
    func addEvents() {
        likeButton.addTarget(self, action: #selector(likeItAction(_:)), for: .touchUpInside)
    }
}

// MARK: - Action
extension PlayerLikeView {
    @objc fileprivate func likeItAction(_ sender: UIButton) {
        print("likeItAction")
        if !sender.isSelected, likeActionTarget != nil, likeActionSelector != nil {
            likeActionTarget!.performSelector(onMainThread: likeActionSelector!, with: sender, waitUntilDone: true)
        }
        sender.isSelected = true
        self.animation(startPosition: CGPoint.init(x: sender.center.x, y: sender.center.y+sender.imageEdgeInsets.top))
    }
    func animation(startPosition: CGPoint) {
        var n = 3
        while n > 0 {
            n -= 1
            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: likeVideoAnimationImage?.size.width ?? 0, height: likeVideoAnimationImage?.size.height ?? 0))
            imageView.center = startPosition
            imageView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            imageView.alpha = 0
            imageView.image = likeVideoAnimationImage
            self.addSubview(imageView)
            
            UIView.animate(withDuration: 0.1, animations: { 
                imageView.alpha = 1
                imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 3, animations: { 
                    //移动到具体的位置
                    let tmpNumber = arc4random_uniform(131)
                    let d = CGFloat(tmpNumber)
                    let x = startPosition.x-d
                    let h = sqrt(Double(130*130-d*d))
                    let y = startPosition.y+CGFloat(h)*CGFloat(tmpNumber%2 == 1 ? 1 : -1)
                    
                    imageView.alpha = 0
                    imageView.center = CGPoint.init(x: x, y: y)
                    imageView.transform = CGAffineTransform.init(rotationAngle: 0.5*CGFloat.pi*CGFloat(tmpNumber%5))
                }, completion: { (finished: Bool) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: { 
                        imageView.removeFromSuperview()
                    })
                })
            })
        }
    }
}


// MARK: - extension PlayerLikeView - 外部调用
extension PlayerLikeView {
    func likeButtonBindingTouchUpInside(_ target: UIResponder?, action: Selector?) {
        likeActionTarget = target
        likeActionSelector = action
    }
}

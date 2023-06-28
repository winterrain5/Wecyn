//
//  RefreshAnimationHeader.swift
//  FutureCity_Swift
//
//  Created by Derrick on 2018/9/4.
//  Copyright © 2018年 bike. All rights reserved.
//

import UIKit
import MJRefresh
enum RefreshColorStyle {
    case white,gray
}
class RefreshAnimationHeader: MJRefreshHeader {
    
    lazy private var activity:UIActivityIndicatorView = UIActivityIndicatorView.init(style: .medium)
    lazy private var messageLabel:UILabel = UILabel()
    var colorStyle:RefreshColorStyle = .gray {
        didSet {
            if colorStyle == .gray {
                messageLabel.textColor = .darkGray
                
            }else {
                messageLabel.textColor = .white
            }
        }
    }
    override func prepare() {
        super.prepare()
        self.backgroundColor = .clear
        self.mj_h = iPhoneX() ? 80 : 60
        
        activity = UIActivityIndicatorView.init(style: .medium)
        activity.isHidden = true
        activity.hidesWhenStopped = true
        addSubview(activity)

        messageLabel = UILabel.init()
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = UIColor.darkGray
        messageLabel.textAlignment = .center
        addSubview(messageLabel)
        
        
    }
    
    override func placeSubviews() {
         super.placeSubviews()
        activity.frame = CGRect.init(x: (self.frame.size.width - 50) * 0.5, y: iPhoneX() ? 30 : 10, width: 50, height: 40)
        messageLabel.frame = CGRect.init(x: (self.frame.size.width - 120) * 0.5, y: iPhoneX() ? 30 : 10, width: 120, height: 40)
    }
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                activity.stopAnimating()
                messageLabel.isHidden = false
                messageLabel.text = "下拉刷新"
                break
            case .pulling:
                activity.stopAnimating()
                Haptico.selection()
                messageLabel.isHidden = false
                messageLabel.text = "松手刷新"
                break
            case .refreshing:
                activity.startAnimating()
                messageLabel.isHidden = true
                break
            default:
                break
            }
        }
    }

}

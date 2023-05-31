//
//  RefreshAnimationFooter.swift
//  FutureCity_Swift
//
//  Created by Derrick on 2018/9/4.
//  Copyright © 2018年 bike. All rights reserved.
//

import UIKit
import MJRefresh
class RefreshAnimationFooter: MJRefreshAutoFooter {

    private var activity:UIActivityIndicatorView?
    private var messageLabel:UILabel?
    override func prepare() {
        super.prepare()
        self.mj_h = 60
        activity = UIActivityIndicatorView.init(style: .gray)
        activity?.isHidden = true
        activity?.hidesWhenStopped = true
        addSubview(activity!)
        
        messageLabel = UILabel.init()
        messageLabel?.font = UIFont.systemFont(ofSize: 14)
        messageLabel?.textColor = UIColor.darkGray
        messageLabel?.textAlignment = .center
        addSubview(messageLabel!)
        
        triggerAutomaticallyRefreshPercent = -1
        
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        activity?.frame = CGRect.init(x: (self.frame.size.width - 50) * 0.5, y: 10, width: 50, height: 50)
        messageLabel?.frame = CGRect.init(x: (self.frame.size.width - 120) * 0.5, y: 10, width: 120, height: 50)
    }
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                activity?.stopAnimating()
                messageLabel?.isHidden = false
                messageLabel?.text = "上拉加载"
                break
            case .pulling:
                activity?.stopAnimating()
                messageLabel?.isHidden = false
                messageLabel?.text = "松手刷新"
                break
            case .refreshing:
                activity?.startAnimating()
                messageLabel?.isHidden = true
                break
           
            default:
                break
            }
        }
    }

}

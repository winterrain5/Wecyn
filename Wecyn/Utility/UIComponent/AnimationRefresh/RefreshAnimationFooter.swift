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
        activity = UIActivityIndicatorView.init(style: .medium)
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
        activity?.frame = CGRect.init(x: 0, y: 10, width: 50, height: 50)
        activity?.center.x = self.center.x
        messageLabel?.frame = CGRect.init(x: 0, y: 10, width: 300, height: 50)
        messageLabel?.center.x = self.center.x
    }
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                activity?.stopAnimating()
                messageLabel?.isHidden = false
                messageLabel?.text = Localizer.shared.localized("pull_up_to_refresh")
                break
            case .pulling:
                activity?.stopAnimating()
                messageLabel?.isHidden = false
                messageLabel?.text = Localizer.shared.localized("release_refresh")
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

//
//  RefreshAnimationHeader.swift
//  FutureCity_Swift
//
//  Created by Derrick on 2018/9/4.
//  Copyright © 2018年 bike. All rights reserved.
//

import UIKit
import MJRefresh
import RxLocalizer
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
        self.mj_h = UIDevice.isiPhoneX ? 80 : 60
        
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
        activity.frame = CGRect.init(x: 0, y: UIDevice.isiPhoneX ? 30 : 10, width: 50, height: 40)
        activity.center.x = self.center.x
        
        messageLabel.frame = CGRect.init(x: 0, y: UIDevice.isiPhoneX ? 30 : 10, width: 300, height: 40)
        messageLabel.center.x = self.center.x
    }
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                activity.stopAnimating()
                messageLabel.isHidden = false
                messageLabel.text = Localizer.shared.localized("pull_down_to_refresh")
                break
            case .pulling:
                activity.stopAnimating()
                Haptico.selection()
                messageLabel.isHidden = false
                messageLabel.text = Localizer.shared.localized("release_refresh")
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

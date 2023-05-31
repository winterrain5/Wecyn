//
//  Toast.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/8/10.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
import SVProgressHUD
class Toast {

    static func showLoading() {
        defaultStyle()
        SVProgressHUD.show()
    }
    static func showLoading(after:TimeInterval, _ complete:@escaping ()->()) {
        defaultStyle()
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            complete()
        }
    }
    static func showLoading(withStatus message:String) {
        defaultStyle()
        SVProgressHUD.show(withStatus: message)
    }
    
    static func showMessage(_ message:String, after:TimeInterval, _ complete:@escaping ()->()) {
        self.showMessage(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            complete()
        }
    }
    
    static func showMessage(_ message:String) {
        defaultStyle()
        SVProgressHUD.showInfo(withStatus: message)
    }
    
    
    static func showError(withStatus message: String) {
        defaultStyle()
        SVProgressHUD.showError(withStatus: message)
    }
    
    static func showSuccess(withStatus message: String) {
        defaultStyle()
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    static func showWarning(withStatus message: String) {
        defaultStyle()
        SVProgressHUD.showInfo(withStatus: message)
    }
    
    static func showMessage(message:String,imageName:String,shouldDismiss:Bool = true) {
        defaultStyle()
        if !shouldDismiss {
            SVProgressHUD.setMaximumDismissTimeInterval(Double.infinity)
            SVProgressHUD.setMinimumDismissTimeInterval(Double.infinity)
        }
        SVProgressHUD.setImageViewSize(CGSize(width: 50, height: 47))
        SVProgressHUD.setInfoImage(UIImage(named: imageName)!)
        SVProgressHUD.setFont(UIFont(PingFangSCMedium: 12))
        SVProgressHUD.setMinimumSize(CGSize(width: 190, height: 130))
        SVProgressHUD.showInfo(withStatus: message)
        
    }
    static func showProgress(_ progress:Float,_ status:String = "") {
        defaultStyle()
        SVProgressHUD.showProgress(progress,status: status)
    }
    
    static func defaultStyle() {
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setMaximumDismissTimeInterval(3)
        SVProgressHUD.setBackgroundColor(UIColor.black.withAlphaComponent(0.6))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setCornerRadius(10)
        SVProgressHUD.setMinimumSize(CGSize(width: 80, height: 40))
    }
    static func dismiss() {
        SVProgressHUD.dismiss()
        SVProgressHUD.setDefaultMaskType(.none)
    }
    
    static func dismiss(_ completion:@escaping ()->()) {
        SVProgressHUD.dismiss {
            completion()
        }
        SVProgressHUD.setDefaultMaskType(.none)
    }
}

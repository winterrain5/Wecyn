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
    
    static func showMessage(_ message:String) {
        SPIndicatorView(title: message, message: nil).present()
    }
    
    
    static func showError(_ message: String) {
        SPIndicator.present(title: message, preset: .error)
    }
    
    static func showSuccess(_ message: String) {
        SPIndicator.present(title: message, preset: .done)
    }
    
    
    static func showWarning(_ message: String) {
        SPIndicatorView(title: message, preset: .custom(UIImage(.exclamationmark.triangleFill).tintImage(.yellow))).present()
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

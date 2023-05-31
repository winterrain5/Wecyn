//
//  UIFont+PingFang.swift
//  VictorCRM
//
//  Created by liyuzhu on 2021/7/7.
//  Copyright © 2021 Victor. All rights reserved.
//

import UIKit

extension UIFont {
    @objc public convenience init(PingFangSCLight size: CGFloat)  {
        self.init(name: "PingFangSC-Light", size: size)!
    
    }
    @objc public convenience init(PingFangSCMedium size: CGFloat)  {
        self.init(name: "PingFangSC-Medium", size: size)!
    }
    @objc public convenience init(PingFangSCRegular size: CGFloat)  {
        self.init(name: "PingFangSC-Regular", size: size)!
    }
    @objc public convenience init(PingFangSCBold size: CGFloat)  {
        self.init(name: "PingFangSC-Semibold", size: size)!
    }
    @objc public convenience init(PingFangSCThin size: CGFloat)  {
        self.init(name: "PingFangSC-Thin", size: size)!
    }
    @objc public convenience init(PingFangSCUltralight size: CGFloat)  {
        self.init(name: "PingFangSC-Ultralight", size: size)!
    }
    
    @objc public convenience init(CorsivaHebrewBold size: CGFloat)  {
        self.init(name: "CorsivaHebrew-Bold", size: size)!
    }
    
    @objc public convenience init(CorsivaHebrewRegular size: CGFloat)  {
        self.init(name: "CorsivaHebrew", size: size)!
    }
    

}

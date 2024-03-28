//
//  UIImage_IM_Extension.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/27.
//

import Foundation
extension UIImage {
    public convenience init?(nameInBundle: String) {
        self.init(named: nameInBundle, in: BundleUtil.getResourceBundle(), compatibleWith: nil)
    }

    public convenience init?(nameInEmoji: String) {
        self.init(named: nameInEmoji, in: BundleUtil.getEmojiBundle(), compatibleWith: nil)
    }
    
    public convenience init?(path: String?) {
        if let path = path {
            self.init(contentsOfFile: path)
        } else {
            return nil
        }
    }
}

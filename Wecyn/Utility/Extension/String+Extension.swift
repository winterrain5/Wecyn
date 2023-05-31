//
//  String+Extension.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/15.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
/// 脱敏类型
enum DesensitizationType {
    case phone
    case idCard
    case bank
}
extension String {
    /// 分割url字符串
    func formatUrlString() -> String {
        if self.contains("|") {
            return String(self.split(separator: "|").first ?? "")
        }
        return self
    }
    
    
    /// 手机号或者身份证脱敏
    /// - Parameter type: 类型
    /// - Returns: 脱敏后的字符串
    func desensitization(type:DesensitizationType) -> String {
        let str = self
        switch type {
        case .phone:
            if str.count < 11 {
                return str
            }
            let startIndex = str.index(str.startIndex, offsetBy: 3)
            let endIndex = str.index(str.startIndex, offsetBy: 7)
            return str.replacingCharacters(in: startIndex..<endIndex, with: String(repeating: "*", count: 4))
        case .idCard:
            if str.count < 15 {
                return str
            }
            let startIndex = str.index(str.startIndex, offsetBy: 4)
            let endIndex = str.index(str.startIndex, offsetBy: 14)
            return str.replacingCharacters(in: startIndex..<endIndex, with: String(repeating: "*", count: 10))
        case .bank:
            let startIndex = str.index(str.startIndex, offsetBy: 4)
            let endIndex = str.index(str.startIndex, offsetBy: 12)
            return str.replacingCharacters(in: startIndex..<endIndex, with: String(repeating: "*", count: 8))
        }
    }
    
    func validatePhone() -> Bool {
        return self.first == "1" && self.count == 11
    }
    
    func validateIdCard() -> Bool{
        return self.count >= 15
    }
}

extension String {
    /// 将输入的数字转成以分为单位的价格
    var oneTenth:Int {
        ((self.float() ?? 0) * 100).int
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
        
    }
    func widthWithConstrainedWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.width
        
    }
}

extension String {
 /// 替换手机号中间四位
    ///
    /// - Returns: 替换后的值
    func replacePhone() -> String {
        let start = self.index(self.startIndex, offsetBy: 3)
        let end = self.index(self.startIndex, offsetBy: 7)
        let range = Range(uncheckedBounds: (lower: start, upper: end))
        return self.replacingCharacters(in: range, with: "****")
    }
}

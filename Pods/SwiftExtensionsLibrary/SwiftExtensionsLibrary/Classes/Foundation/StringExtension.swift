//
//  StringExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/7.
//

import Foundation
extension String: ExtensionCompatible {}

public extension ExtensionBase where Base: ExpressibleByStringLiteral {
    // MARK: 4.1、字符串 转 CGFloat
    /// 字符串 转 Float
    /// - Returns: CGFloat
    func toCGFloat() -> CGFloat? {
        if let doubleValue = Double(base as! String) {
            return CGFloat(doubleValue)
        }
        return nil
    }
    
    // MARK: 4.2、字符串转 Bool
    /// 字符串转 Bool
    /// - Returns: Bool
    func toBool() -> Bool? {
        switch (base as! String).lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
    
    
    // MARK: 4.4、字符串转 Double
    /// 字符串转 Double
    /// - Returns: Double
    func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: base as! String) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    // MARK: 4.5、字符串转 Float
    /// 字符串转 Float
    /// - Returns: Float
    func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: base as! String) {
            return num.floatValue
        } else {
            return nil
        }
    }
}


public extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading,.usesDeviceMetrics], attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
        
    }
    func widthWithConstrainedWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options:[.usesLineFragmentOrigin, .usesFontLeading,.usesDeviceMetrics], attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
        
    }
}

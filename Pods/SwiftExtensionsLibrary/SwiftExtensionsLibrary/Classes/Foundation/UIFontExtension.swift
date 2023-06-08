//
//  UIFontExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/7.
//

import Foundation
// MARK: - 二、PingFangSC-字体使用
fileprivate enum UIFontWeight: String {
    /// 常规
    case Regular = "Regular"
    /// 中等的字体(介于Regular和Semibold之间)
    case Medium = "Medium"
    /// 纤细的字体
    case Thin = "Thin"
    /// 亮字体
    case Light = "Light"
    /// 超细的字体
    case Ultralight = "Ultralight"
    /// 半粗体的字体
    case Semibold = "Semibold"
}

public extension ExtensionBase where Base: UIFont {
    
    // MARK: 2.1、常规字体
    /// 常规字体
    /// - Parameter ofSize: 字体大小
    /// - Returns: 字体
    static func pingFangRegular(_ ofSize: CGFloat) -> UIFont {
        return pingFangText(ofSize, W: .Regular)
    }
    
    // MARK: 2.2、中等的字体(介于Regular和Semibold之间)
    /// 中等的字体(介于Regular和Semibold之间)
    /// - Parameter ofSize: 字体大小
    /// - Returns: 字体
    static func pingFangMedium(_ ofSize: CGFloat) -> UIFont {
        return pingFangText(ofSize, W: .Medium)
    }
    
    // MARK: 2.3、纤细的字体
    /// 纤细的字体
    /// - Parameter ofSize: 字体大小
    /// - Returns: 字体
    static func pingFangThin(_ ofSize: CGFloat) -> UIFont {
        return pingFangText(ofSize, W: .Thin)
    }
    
    // MARK: 2.4、亮字体
    /// 亮字体
    /// - Parameter ofSize: 字体大小
    /// - Returns: 字体
    static func pingFangLight(_ ofSize: CGFloat) -> UIFont {
        return pingFangText(ofSize, W: .Light)
    }
    
    // MARK: 2.5、超细的字体
    /// 超细的字体
    /// - Parameter ofSize: 字体大小
    /// - Returns: 字体
    static func pingFangUltralight(_ ofSize: CGFloat) -> UIFont {
        return pingFangText(ofSize, W: .Ultralight)
    }
    
    // MARK: 2.6、半粗体的字体
    /// 半粗体的字体
    /// - Parameter ofSize: 字体大小
    /// - Returns: 字体
    static func pingFangSemibold(_ ofSize: CGFloat) -> UIFont {
        return pingFangText(ofSize, W: .Semibold)
    }
    
    /// 文字字体
    private static func pingFangText(_ ofSize: CGFloat, W Weight: UIFontWeight) -> UIFont {
        let fontName = "PingFangSC-" + Weight.rawValue
        return appCustomFont(fontName: fontName, ofSize: ofSize)
    }
    
    
    /// 自定义的字体
    /// - Parameters:
    ///   - fontName: 字体的名字
    ///   - ofSize: 字体大小
    /// - Returns: 对应的字体
    private static func appCustomFont(fontName: String, ofSize: CGFloat) -> UIFont {
        if let font = UIFont(name: fontName, size: ofSize) {
            return font
        } else {
            return UIFont.systemFont(ofSize: ofSize)
        }
    }
}

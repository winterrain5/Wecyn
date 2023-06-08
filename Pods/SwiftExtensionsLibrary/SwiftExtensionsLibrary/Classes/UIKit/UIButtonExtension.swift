//
//  UIButtonExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/7.
//

import Foundation

// MARK: - 二、链式调用
public extension UIButton {
    
    // MARK: 2.1、设置title
    /// 设置title
    /// - Parameters:
    ///   - text: 文字
    ///   - state: 状态
    /// - Returns: 返回自身
    @discardableResult
    func title(_ text: String, _ state: UIControl.State = .normal) -> Self {
        setTitle(text, for: state)
        return self
    }
    
    // MARK: 2.2、设置文字颜色
    /// 设置文字颜色
    /// - Parameters:
    ///   - color: 文字颜色
    ///   - state: 状态
    /// - Returns: 返回自身
    @discardableResult
    func textColor(_ color: UIColor, _ state: UIControl.State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    
    // MARK: 2.3、设置字体大小(UIFont)
    /// 设置字体大小
    /// - Parameter font: 字体 UIFont
    /// - Returns: 返回自身
    @discardableResult
    func font(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
    
    // MARK: 2.4、设置字体大小(CGFloat)
    /// 设置字体大小(CGFloat)
    /// - Parameter fontSize: 字体的大小
    /// - Returns: 返回自身
    @discardableResult
    func font(_ fontSize: CGFloat) -> Self {
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        return self
    }
    
    // MARK: 2.5、设置字体粗体
    /// 设置粗体
    /// - Parameter fontSize: 设置字体粗体
    /// - Returns: 返回自身
    @discardableResult
    func boldFont(_ fontSize: CGFloat) -> Self {
        titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        return self
    }
    
    // MARK: 2.6、设置图片
    /// 设置图片
    /// - Parameters:
    ///   - image: 图片
    ///   - state: 状态
    /// - Returns: 返回自身
    @discardableResult
    func image(_ image: UIImage?, _ state: UIControl.State = .normal) -> Self {
        setImage(image, for: state)
        return self
    }
    
    
    // MARK: 2.10、设置背景图片
    /// 设置背景图片
    /// - Parameters:
    ///   - image: 图片
    ///   - state: 状态
    /// - Returns: 返回自身
    @discardableResult
    func backgroundImage(_ image: UIImage?, _ state: UIControl.State = .normal) -> Self {
        setBackgroundImage(image, for: state)
        return self
    }
    

}
// MARK: - 三、UIButton 图片 与 title 位置关系
/// UIButton 图片与title位置关系 https://www.jianshu.com/p/0f34c1b52604
public extension ExtensionBase where Base: UIButton {
    
    /// 图片 和 title 的布局样式
    enum ImageTitleLayout {
        case imgTop
        case imgBottom
        case imgLeft
        case imgRight
    }
    
    // MARK: 3.1、设置图片和 title 的位置关系(提示：title和image要在设置布局关系之前设置)
    /// 设置图片和 title 的位置关系(提示：title和image要在设置布局关系之前设置)
    /// - Parameters:
    ///   - layout: 布局
    ///   - spacing: 间距
    /// - Returns: 返回自身
    @discardableResult
    func setImageTitleLayout(_ layout: ImageTitleLayout, spacing: CGFloat = 0) -> UIButton {
        switch layout {
        case .imgLeft:
            alignHorizontal(spacing: spacing, imageFirst: true)
        case .imgRight:
            alignHorizontal(spacing: spacing, imageFirst: false)
        case .imgTop:
            alignVertical(spacing: spacing, imageTop: true)
        case .imgBottom:
            alignVertical(spacing: spacing, imageTop: false)
        }
        return self.base
    }
    
    /// 水平方向
    /// - Parameters:
    ///   - spacing: 间距
    ///   - imageFirst: 图片是否优先
    private func alignHorizontal(spacing: CGFloat, imageFirst: Bool) {
        let edgeOffset = spacing / 2
        base.imageEdgeInsets = UIEdgeInsets(top: 0, left: -edgeOffset,
                                            bottom: 0,right: edgeOffset)
        base.titleEdgeInsets = UIEdgeInsets(top: 0, left: edgeOffset,
                                            bottom: 0, right: -edgeOffset)
        if !imageFirst {
            base.transform = CGAffineTransform(scaleX: -1, y: 1)
            base.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            base.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        base.contentEdgeInsets = UIEdgeInsets(top: 0, left: edgeOffset, bottom: 0, right: edgeOffset)
    }
    
    /// 垂直方向
    /// - Parameters:
    ///   - spacing: 间距
    ///   - imageTop: 图片是不是在顶部
    private func alignVertical(spacing: CGFloat, imageTop: Bool) {
        guard let imageSize = self.base.imageView?.image?.size,
              let text = self.base.titleLabel?.text,
              let font = self.base.titleLabel?.font
        else {
            return
        }
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: font])
        
        let imageVerticalOffset = (titleSize.height + spacing) / 2
        let titleVerticalOffset = (imageSize.height + spacing) / 2
        let imageHorizontalOffset = (titleSize.width) / 2
        let titleHorizontalOffset = (imageSize.width) / 2
        let sign: CGFloat = imageTop ? 1 : -1
        
        base.imageEdgeInsets = UIEdgeInsets(top: -imageVerticalOffset * sign,
                                            left: imageHorizontalOffset,
                                            bottom: imageVerticalOffset * sign,
                                            right: -imageHorizontalOffset)
        base.titleEdgeInsets = UIEdgeInsets(top: titleVerticalOffset * sign,
                                            left: -titleHorizontalOffset,
                                            bottom: -titleVerticalOffset * sign,
                                            right: titleHorizontalOffset)
        // increase content height to avoid clipping
        let edgeOffset = (min(imageSize.height, titleSize.height) + spacing) / 2
        base.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0, bottom: edgeOffset, right: 0)
    }
}

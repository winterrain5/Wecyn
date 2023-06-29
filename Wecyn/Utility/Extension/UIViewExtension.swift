//
//  UIViewExtension.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import Foundation

extension UIView {
    /// 添加阴影
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角大小
    ///   - color: 阴影颜色
    ///   - offset: 阴影偏移量
    ///   - radius: 阴影扩散范围
    ///   - opacity: 阴影的透明度
    func shadow(cornerRadius: CGFloat, color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
      self.layer.cornerRadius = cornerRadius
      self.layer.masksToBounds = true
      self.layer.shadowColor = color.cgColor
      self.layer.shadowOffset = offset
      self.layer.shadowRadius = radius
      self.layer.shadowOpacity = opacity
      self.layer.masksToBounds = false
      self.layer.rasterizationScale = UIScreen.main.scale
      self.layer.shouldRasterize = true
    }
    
    /// 添加部分圆角
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
      let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
      let maskLayer = CAShapeLayer()
      maskLayer.frame = self.bounds
      maskLayer.path = maskPath.cgPath
      self.layer.mask = maskLayer
    }
    
    func addShadow(cornerRadius:CGFloat) {
      let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.2)
      self.shadow(cornerRadius: cornerRadius, color: light, offset: CGSize(width: 0, height: 3), radius: 4, opacity: 1)
    }
}


public extension UILabel {
    @IBInspectable var lineHeight: CGFloat {
        get {
            11
        }
        set {
          guard let text = self.text else {
            return
          }
          let attributedString = NSMutableAttributedString(string: text)

          let paragraphStyle = NSMutableParagraphStyle()
          paragraphStyle.minimumLineHeight = newValue

          attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

          self.attributedText = attributedString
        }
    }
}

import UIKit

public extension UILabel {
    // MARK: - Custom Flags

    private struct AssociatedKeys {
        static var isCopyingEnabled: UInt8 = 0
        static var shouldUseLongPressGestureRecognizer: UInt8 = 1
        static var longPressGestureRecognizer: UInt8 = 2
    }

    /// Set this property to `true` in order to enable the copy feature. Defaults to `false`.
    @objc
    @IBInspectable var isCopyingEnabled: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isCopyingEnabled, newValue, .OBJC_ASSOCIATION_ASSIGN)
            setupGestureRecognizers()
        }
        get {
            let value = objc_getAssociatedObject(self, &AssociatedKeys.isCopyingEnabled)
            return (value as? Bool) ?? false
        }
    }


    /// Used to enable/disable the internal long press gesture recognizer. Defaults to `true`.
    @IBInspectable var shouldUseLongPressGestureRecognizer: Bool {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldUseLongPressGestureRecognizer, newValue, .OBJC_ASSOCIATION_ASSIGN)
            setupGestureRecognizers()
        }
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.shouldUseLongPressGestureRecognizer) as? Bool) ?? true
        }
    }

    @objc
    var longPressGestureRecognizer: UILongPressGestureRecognizer? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.longPressGestureRecognizer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.longPressGestureRecognizer) as? UILongPressGestureRecognizer
        }
    }
    
    // MARK: - UIResponder

    @objc
    override var canBecomeFirstResponder: Bool {
        return isCopyingEnabled
    }

    @objc
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Only return `true` when it's the copy: action AND the `copyingEnabled` property is `true`.
        return (action == #selector(self.copy(_:)) && isCopyingEnabled)
    }

    @objc
    override func copy(_ sender: Any?) {
        if isCopyingEnabled {
            // Copy the label text
            let pasteboard = UIPasteboard.general
            pasteboard.string = text
        }
    }

    // MARK: - UI Actions

    @objc internal func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer === longPressGestureRecognizer && gestureRecognizer.state == .began {
            becomeFirstResponder()

            let copyMenu = UIMenuController.shared
            copyMenu.arrowDirection = .default
            if #available(iOS 13.0, *) {
                copyMenu.showMenu(from: self, rect: bounds)
            } else {
                // Fallback on earlier versions
                copyMenu.setTargetRect(bounds, in: self)
                copyMenu.setMenuVisible(true, animated: true)
            }
        }
    }

    // MARK: - Private Helpers

    fileprivate func setupGestureRecognizers() {
        // Remove gesture recognizer
        if let longPressGR = longPressGestureRecognizer {
            removeGestureRecognizer(longPressGR)
            longPressGestureRecognizer = nil
        }

        if shouldUseLongPressGestureRecognizer && isCopyingEnabled {
            isUserInteractionEnabled = true
            // Enable gesture recognizer
            let longPressGR = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(longPressGestureRecognized(gestureRecognizer:)))
            longPressGestureRecognizer = longPressGR
            addGestureRecognizer(longPressGR)
        }
    }
}

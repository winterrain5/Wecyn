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

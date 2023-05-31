//
//  UIView+loadFromNib.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/6.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
// MARK:-Nibloadable
extension UIView {
    static var NibName: String {
        return String(self.className)
    }
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
    }
}

// MARK: - snapshot
extension UIView {
    func snapshotImage() -> UIImage? {
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let rect = bounds
        drawHierarchy(in: rect, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
}

// MARK:- shadow
extension UIView {
    /// 添加阴影和圆角
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角大小
    ///   - color: 阴影颜色
    ///   - offset: 阴影偏移量
    ///   - radius: 阴影扩散范围
    ///   - opacity: 阴影的透明度
    func addShadow(corner: CGFloat,
                   color: UIColor = .lightGray,
                   offset: CGSize = .zero,
                   radius: CGFloat = 6,
                   opacity: Float = 1) {
        self.layer.cornerRadius = corner
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
    
}

public struct UIRectSide : OptionSet {
    
    public let rawValue: Int
    
    public static let left = UIRectSide(rawValue: 1 << 0)
    public static let top = UIRectSide(rawValue: 1 << 1)
    public static let right = UIRectSide(rawValue: 1 << 2)
    public static let bottom = UIRectSide(rawValue: 1 << 3)
    public static let all: UIRectSide = [.top, .right, .left, .bottom]
    
    public init(rawValue: Int) {
        
        self.rawValue = rawValue;
        
    }
    
}

extension UIView{
    
    
    
    ///画虚线边框
    
    func drawDashLine(strokeColor: UIColor, lineWidth: CGFloat = 1, lineLength: Int = 10, lineSpacing: Int = 5, corners: UIRectSide) {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        
        //每一段虚线长度 和 每两段虚线之间的间隔
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = CGMutablePath()
        if corners.contains(.left) {
            path.move(to: CGPoint(x: 0, y: self.layer.bounds.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        if corners.contains(.top){
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: self.layer.bounds.width, y: 0))
        }
        
        if corners.contains(.right){
            path.move(to: CGPoint(x: self.layer.bounds.width, y: 0))
            path.addLine(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
        }
        
        if corners.contains(.bottom){
            path.move(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
            path.addLine(to: CGPoint(x: 0, y: self.layer.bounds.height))
        }
        
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
        
    }
    
    ///画实线边框
    
    func drawLine(strokeColor: UIColor, lineWidth: CGFloat = 1, corners: UIRectSide) {
        
        if corners == UIRectSide.all {
            self.layer.borderWidth = lineWidth
            self.layer.borderColor = strokeColor.cgColor
        }else{
            let shapeLayer = CAShapeLayer()
            shapeLayer.bounds = self.bounds
            shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
            shapeLayer.fillColor = UIColor.blue.cgColor
            shapeLayer.strokeColor = strokeColor.cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.lineJoin = CAShapeLayerLineJoin.round
            
            let path = CGMutablePath()
            
            if corners.contains(.left) {
                path.move(to: CGPoint(x: 0, y: self.layer.bounds.height))
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            
            if corners.contains(.top){
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: self.layer.bounds.width, y: 0))
            }
            
            if corners.contains(.right){
                path.move(to: CGPoint(x: self.layer.bounds.width, y: 0))
                path.addLine(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
            }
            
            if corners.contains(.bottom){
                path.move(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
                path.addLine(to: CGPoint(x: 0, y: self.layer.bounds.height))
            }
            
            shapeLayer.path = path
            self.layer.addSublayer(shapeLayer)
            
        }
        
    }
    
}

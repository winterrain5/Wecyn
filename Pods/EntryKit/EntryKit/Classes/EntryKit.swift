//
//  CKEntryKit.swift
//  ClassRoomKit
//
//  Created by VICTOR03 on 2021/5/9.
//
import UIKit
import Foundation

private let kScreenHeight:CGFloat = UIScreen.main.bounds.size.height

public enum EntryStyle {
    case sheet
    case alert
}

open class EntryKit:UIView {
    private static let animateDuration:TimeInterval = 0.5
    private static let animateDamping:CGFloat = 0.9
    private static let animateVelocity:CGFloat = 2
    private static var style:EntryStyle = .alert
    private static var touchDismiss:Bool = true
    private static var childView: UIView!
    
    public static func display(view:UIView,
                               size:CGSize,
                               style:EntryStyle,
                               backgroundColor:UIColor,
                               touchDismiss:Bool) {
        innerDisplay(view: view, size: size, style: style, backgroundColor:backgroundColor,touchDismiss: touchDismiss)
    }
    
    public static func display(view:UIView,
                               size:CGSize,
                               style:EntryStyle,
                               touchDismiss:Bool) {
        innerDisplay(view: view, size: size, style: style, backgroundColor: UIColor.black.withAlphaComponent(0.5),touchDismiss: touchDismiss)
    }
    
    public static func display(view:UIView,
                               size:CGSize,
                               style:EntryStyle) {
        innerDisplay(view: view, size: size, style: style, backgroundColor: UIColor.black.withAlphaComponent(0.5),touchDismiss: true)
        
    }
    
    private static func innerDisplay(view:UIView,
                               size:CGSize,
                               style:EntryStyle,
                               backgroundColor:UIColor,
                               touchDismiss:Bool) {
        let superView = UIApplication.shared.keyWindow
        if (superView?.subviews.last?.isKind(of: EntryKit.self) ?? false) {
            return
        }
        
        EntryKit.style = style
        EntryKit.childView = view
        EntryKit.touchDismiss = touchDismiss
        
        let container = EntryKit()
        container.frame = UIScreen.main.bounds
        container.backgroundColor = backgroundColor
        superView?.addSubview(container)
        
        container.addSubview(view)
        view.frame.size = size
        
        if style == .alert {
            alertDisplay(view: view, size: size)
        }else {
            sheetDisplay(view: view, size: size)
        }
    }
    
    public static func dismiss() {
        let superView = UIApplication.shared.keyWindow?.subviews.last
        if !(superView?.isKind(of: EntryKit.self) ?? false) {
            return
        }
        let subView = EntryKit.childView
        if EntryKit.style == .alert {
            UIView.animate(withDuration: EntryKit.animateDuration,
                           delay: 0.1,
                           usingSpringWithDamping: EntryKit.animateDamping,
                           initialSpringVelocity: EntryKit.animateVelocity,
                           options: .curveEaseOut) {
                superView?.backgroundColor = .clear
                subView?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
                subView?.alpha = 0
            } completion: { (flag) in
                superView?.removeFromSuperview()
                subView?.removeFromSuperview()
            }
        }else {
            UIView.animate(withDuration: EntryKit.animateDuration,
                           delay: 0.1,
                           usingSpringWithDamping: EntryKit.animateDamping,
                           initialSpringVelocity: EntryKit.animateVelocity,
                           options: .curveEaseOut) {
                superView?.backgroundColor = .clear
                subView?.frame.origin = CGPoint(x: 0, y: kScreenHeight)
            } completion: { (flag) in
                superView?.removeFromSuperview()
                subView?.removeFromSuperview()
            }
        }
    }
    
    private static func alertDisplay(view:UIView,size:CGSize) {
        view.center = view.superview?.center ?? .zero
        view.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: EntryKit.animateDuration,
                       delay: 0,
                       usingSpringWithDamping: EntryKit.animateDamping,
                       initialSpringVelocity: EntryKit.animateVelocity,
                       options: .curveEaseIn,
                       animations: {
            view.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private static func sheetDisplay(view:UIView,size:CGSize) {
        view.frame.origin = CGPoint(x: 0, y: kScreenHeight)
        UIView.animate(withDuration: EntryKit.animateDuration,
                       delay: 0,
                       usingSpringWithDamping: EntryKit.animateDamping,
                       initialSpringVelocity: EntryKit.animateVelocity,
                       options: .curveEaseIn,
                       animations: {
            view.frame.origin = CGPoint(x: 0, y: kScreenHeight - size.height)
        }, completion: nil)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self) ?? .zero
        if EntryKit.touchDismiss {
            if !EntryKit.childView.frame.contains(point) {
                EntryKit.dismiss()
            }
        }
    }
    
}

//
//  EmptyDataDelegate.swift
//  EmptViewDemo
//
//  Created by Derrick on 2020/1/16.
//  Copyright © 2020 winter. All rights reserved.
//

import Foundation
import UIKit


private var kEmptyDataView =             "emptyDataView"
private var kConfigureEmptyDataView =    "configureEmptyDataView"

extension UIView {
    
    private var configureEmptyDataView: ((DKEmptyDataView) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &kConfigureEmptyDataView) as? (DKEmptyDataView) -> Void
        }
        set {
            objc_setAssociatedObject(self, &kConfigureEmptyDataView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    public var isEmptyDataVisible: Bool {
        if let view = objc_getAssociatedObject(self, &kEmptyDataView) as? DKEmptyDataView {
            return !view.isHidden
        }
        return false
    }
    
    //MARK: - privateProperty
    public func emptyDataView(_ closure: @escaping (DKEmptyDataView) -> Void) {
        configureEmptyDataView = closure
    }
    
    private var emptyDataView: DKEmptyDataView? {
        get {
            if let view = objc_getAssociatedObject(self, &kEmptyDataView) as? DKEmptyDataView {
                return view
            } else {
                let view = DKEmptyDataView.init(frame: frame)
                view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                view.isHidden = true
                objc_setAssociatedObject(self, &kEmptyDataView, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return view
            }
        }
        set {
            objc_setAssociatedObject(self, &kEmptyDataView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    
    
    //MARK: - Reload APIs (Public)
    public func reloadEmptyDataView() {
        guard (configureEmptyDataView != nil) else {
            return
        }
        
        if let view = emptyDataView {
            
            if view.superview == nil {
                // Send the view all the way to the back, in case a header and/or footer is present, as well as for sectionHeaders or any other content
                if self is UIScrollView {
                    insertSubview(view, at: 0)
                } else {
                    addSubview(view)
                }
            }
            
            // Removing view resetting the view and its constraints it very important to guarantee a good state
            // If a non-nil custom view is available, let's configure it instead
            view.prepareForReuse()
            
            
            if let config = configureEmptyDataView {
                config(view)
            }
            
            view.setupConstraints()
            view.layoutIfNeeded()
        }else if isEmptyDataVisible {
            invalidate()
        }
    }
    
    private func invalidate() {
        
        if let view = emptyDataView {
            view.prepareForReuse()
            view.isHidden = true
        }
        
    }
}




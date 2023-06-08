//
//  NSObjectExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/8.
//

import Foundation

public extension ExtensionBase where Base: NSObject {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    static var className: String {
        return String(describing: self)
    }
}

//
//  ExtensionBase.swift
//  SwiftExtensionsLibrary_Example
//
//  Created by Derrick on 2023/6/2.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public struct ExtensionBase<Base> {
    let base:Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol ExtensionCompatible {}

public extension ExtensionCompatible {
    static var sk: ExtensionBase<Self>.Type {
        get { ExtensionBase<Self>.self }
        set {}
    }
    
    var sk: ExtensionBase<Self> {
        get { ExtensionBase(self) }
        set {}
    }
}

extension NSObject: ExtensionCompatible {}

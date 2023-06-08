//
//  BoolExtension.swift
//  SwiftExtensionsLibrary_Example
//
//  Created by Derrick on 2023/6/2.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

extension Bool: ExtensionCompatible {}

public extension ExtensionBase where Base == Bool {
    var toInt: Int { return self.base ? 1 : 0 }
}

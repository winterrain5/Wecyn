//
//  Haptico.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/8.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
class Haptico {
    
    public static func light() {
        TapticEngine.impact.feedback(.light)
    }

    public static func medium() {
        TapticEngine.impact.feedback(.medium)
    }

    public static func heavy() {
        TapticEngine.impact.feedback(.heavy)
    }

    public static func selection() {
        TapticEngine.selection.feedback()
    }

    public static func success() {
        TapticEngine.notification.feedback(.success)
    }

    public static func warning() {
        TapticEngine.notification.feedback(.warning)
    }

    public static func error() {
        TapticEngine.notification.feedback(.error)
    }
    
}

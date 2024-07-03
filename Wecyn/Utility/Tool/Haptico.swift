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
        if !isEnable() { return }
        TapticEngine.impact.feedback(.light)
    }

    public static func medium() {
        if !isEnable() { return }
        TapticEngine.impact.feedback(.medium)
    }

    public static func heavy() {
        if !isEnable() { return }
        TapticEngine.impact.feedback(.heavy)
    }

    public static func selection() {
        if !isEnable() { return }
        TapticEngine.selection.feedback()
    }

    public static func success() {
        if !isEnable() { return }
        TapticEngine.notification.feedback(.success)
    }

    public static func warning() {
        if !isEnable() { return }
        TapticEngine.notification.feedback(.warning)
    }

    public static func error() {
        if !isEnable() { return }
        TapticEngine.notification.feedback(.error)
    }
    
    static func isEnable() -> Bool {
        UserDefaults.sk.value(for: UserdefaultKeys.HapticoEnableKey) as? Bool ?? false
    }
}

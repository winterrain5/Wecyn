//
//  Localizer.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import Foundation

enum LocalizerKey:String {
    case view_namecard
    case view_calendar
    case add_new_section
    case Activity
    case Skills
    case Experience
    case Education
    case Interests
}

extension Localizer {
    static func localized(for key:LocalizerKey) -> String {
        Localizer.shared.localized(key.rawValue)
    }
}

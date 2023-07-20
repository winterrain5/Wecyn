//
//  RecurrenceFrequency.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/28.
//  Copyright © 2016年 Teambition. All rights reserved.
//

public enum RecurrenceFrequency {
    case yearly
    case monthly
    case weekly
    case daily
    case hourly
    case minutely
    case secondly

    internal func toString() -> String {
        switch self {
        case .secondly: return "SECONDLY"
        case .minutely: return "MINUTELY"
        case .hourly: return "HOURLY"
        case .daily: return "DAILY"
        case .weekly: return "WEEKLY"
        case .monthly: return "MONTHLY"
        case .yearly: return "YEARLY"
        }
    }
    
    internal func unitString() -> String {
        switch self {
        case .secondly: return "second"
        case .minutely: return "minute"
        case .hourly: return "hour"
        case .daily: return "day"
        case .weekly: return "week"
        case .monthly: return "month"
        case .yearly: return "year"
        }
    }

    static func frequency(from string: String) -> RecurrenceFrequency? {
        switch string {
        case "SECONDLY": return .secondly
        case "MINUTELY": return .minutely
        case "HOURLY": return .hourly
        case "DAILY": return .daily
        case "WEEKLY": return .weekly
        case "MONTHLY": return .monthly
        case "YEARLY": return .yearly
        default: return nil
        }
    }
    static func frequency(fromInt: Int) -> RecurrenceFrequency? {
        switch fromInt {
        case 6: return .secondly
        case 5: return .minutely
        case 4: return .hourly
        case 3: return .daily
        case 2: return .weekly
        case 1: return .monthly
        case 0: return .yearly
        default: return nil
        }
    }
}

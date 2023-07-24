//
//  Iterators.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/29.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import JavaScriptCore

public struct Iterator {
    public static let endlessRecurrenceCount = 500
    internal static let rruleContext: JSContext? = {
        guard let rrulejs = JavaScriptBridge.rrulejs() else {
            return nil
        }
        let context = JSContext()
        context?.exceptionHandler = { context, exception in
            print("[RRuleSwift] rrule.js error: \(String(describing: exception))")
        }
        let _ = context?.evaluateScript(rrulejs)
        return context
    }()
    
    internal static let bundleContext: JSContext? = {
        guard let rrulejs = JavaScriptBridge.bundlejs() else {
            return nil
        }
        let context = JSContext()
        context?.exceptionHandler = { context, exception in
            print("[RRuleSwift] bundle.js error: \(String(describing: exception))")
        }
        let _ = context?.evaluateScript(rrulejs)
        return context
    }()
}

public extension RecurrenceRule {
    func allOccurrences(endless endlessRecurrenceCount: Int = Iterator.endlessRecurrenceCount) -> [Date] {
        guard let _ = JavaScriptBridge.rrulejs() else {
            return []
        }

        let ruleJSONString = toJSONString(endless: endlessRecurrenceCount)
        let _ = Iterator.rruleContext?.evaluateScript("var rule = new RRule({ \(ruleJSONString) })")
        guard let allOccurrences = Iterator.rruleContext?.evaluateScript("rule.all()").toArray() as? [Date] else {
            return []
        }

        var occurrences = allOccurrences
        if let rdates = rdate?.dates {
            occurrences.append(contentsOf: rdates)
        }

        if let exdates = exdate?.dates, let component = exdate?.component {
            for occurrence in occurrences {
                for exdate in exdates {
                    if calendar.isDate(occurrence, equalTo: exdate, toGranularity: component) {
                        let index = occurrences.firstIndex(of: occurrence)!
                        occurrences.remove(at: index)
                        break
                    }
                }
            }
        }

        return occurrences.sorted { $0.isBeforeOrSame(with: $1) }
    }
    
    func lastOccurrence(before date: Date) -> Date? {
        guard let _ = JavaScriptBridge.rrulejs() else {
            return nil
        }
        
        let beforeDateJSON = RRule.ISO8601DateFormatter.string(from: date)
        
        let ruleJSONString = toJSONString(endless: 0)
        
        let _ = Iterator.rruleContext?.evaluateScript("var rule = new RRule({ \(ruleJSONString) })")
        guard let lastOccurrence = Iterator.rruleContext?.evaluateScript("rule.before(new Date('\(beforeDateJSON)'), true)").toDate() else {
            return nil
        }
        
        return lastOccurrence
        
    }
    
    func toText() -> String? {
        guard let _ = JavaScriptBridge.bundlejs() else {
            return nil
        }
        
        let ruleJSONString = toJSONString(endless: 0)
        
        let _ = Iterator.bundleContext?.evaluateScript("var {RRule} = require('rrule');var rule = new RRule({ \(ruleJSONString) })")
        guard let text = Iterator.bundleContext?.evaluateScript("rule.toText()").toString() else {
            return nil
        }
        return text
    }
    
    func toText(rrulestr:String) -> String? {
        guard let _ = JavaScriptBridge.bundlejs() else {
            return nil
        }
        
        let dtstart = rrulestr.split(separator: "\n").first ?? ""
        let rrule = rrulestr.split(separator: "\n").last ?? ""
        let _ = Iterator.bundleContext?.evaluateScript("var {RRule} = require('rrule')")
        let _ = Iterator.bundleContext?.evaluateScript("var rule = RRule.fromString('\(dtstart)\\n\(rrule)')")
        
        guard let text = Iterator.bundleContext?.evaluateScript("rule.toText()").toString() else {
            return nil
        }
        return text
    }
    
    func toString() ->  String? {
        guard let _ = JavaScriptBridge.bundlejs() else {
            return nil
        }
        
        let ruleJSONString = toJSONString(endless: 0)
        
        let _ = Iterator.bundleContext?.evaluateScript("var {RRule} = require('rrule');var rule = new RRule({ \(ruleJSONString) })")
        guard let text = Iterator.bundleContext?.evaluateScript("rule.toString()").toString() else {
            return nil
        }
        return text
    }
    
    static func toRRuleDictionary(_ rrulestr:String) -> Dictionary<String,Any>? {
        guard let _ = JavaScriptBridge.bundlejs() else {
            return nil
        }
        let dtstart = rrulestr.split(separator: "\n").first ?? ""
        let rrule = rrulestr.split(separator: "\n").last ?? ""
        let _ = Iterator.bundleContext?.evaluateScript("var {RRule} = require('rrule')")
        guard let dict = Iterator.bundleContext?.evaluateScript("RRule.fromString('\(dtstart)\\n\(rrule)')").toDictionary() else {
            return nil
        }
        let result = JSON.init(dict).rawValue as? [String:Any]
        return result
    }
    
    static func toRRuleOptions(_ rrulestr:String) -> Dictionary<String,Any>? {
        guard let rrule = toRRuleDictionary(rrulestr) else {
            return nil
        }
        
        guard let option = rrule["options"] as? [String:Any] else {
            return nil
        }
        print("toRRuleDictionary: \(String(describing: option))")
        return option
    }

    func occurrences(rrulestr:String, between date: Date, and otherDate: Date) -> [Date] {
        guard let _ = JavaScriptBridge.bundlejs() else {
            return []
        }
        let format = "yyyy-MM-dd HH:mm:ss 'UTC'"
        let beginDate = date.adding(.day, value: 1).string(format: format).date(withFormat: format)!
        let endDate = otherDate.adding(.day, value: 1).string(format: format).date(withFormat: format)!
 
        let dtstart = rrulestr.split(separator: "\n").first ?? ""
        let rrule = rrulestr.split(separator: "\n").last ?? ""

        let _ = Iterator.bundleContext?.evaluateScript("var {RRule,datetime} = require('rrule')")
        let _ = Iterator.bundleContext?.evaluateScript("var rule = RRule.fromString('\(dtstart)\\n\(rrule)')")
        guard let betweenOccurrences = Iterator.bundleContext?.evaluateScript("rule.between(datetime('\(beginDate.year)','\(beginDate.month)','\(beginDate.day)'), datetime('\(endDate.year)','\(endDate.month)','\(endDate.day)'))").toArray() as? [Date] else {
            return []
        }

        var occurrences = betweenOccurrences
        if let rdates = rdate?.dates {
            occurrences.append(contentsOf: rdates)
        }

        if let exdates = exdate?.dates, let component = exdate?.component {
            for occurrence in occurrences {
                for exdate in exdates {
                    if calendar.isDate(occurrence, equalTo: exdate, toGranularity: component) {
                        let index = occurrences.firstIndex(of: occurrence)!
                        occurrences.remove(at: index)
                        break
                    }
                }
            }
        }

        return occurrences.sorted { $0.isBeforeOrSame(with: $1) }
    }
}

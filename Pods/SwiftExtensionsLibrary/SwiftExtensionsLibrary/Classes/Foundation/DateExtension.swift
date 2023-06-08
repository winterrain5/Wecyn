//
//  DateExtension.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/2.
//

import Foundation
extension Date: ExtensionCompatible {}

public enum TimestampType {
    case second
    case millisecond
}

public let formatter = DateFormatter()

public extension ExtensionBase where Base == Date {
    // MARK: 1.1、获取当前 秒级 时间戳 - 10 位
    /// 获取当前 秒级 时间戳 - 10 位
    static var secondStamp: String {
        "\(Int(Base().timeIntervalSince1970))"
    }
    // MARK: 1.2、获取当前 毫秒级 时间戳 - 13 位
    /// 获取当前 毫秒级 时间戳 - 13 位
    static var milliStamp: String {
        let timeInterval: TimeInterval = Base().timeIntervalSince1970
        return "\(CLongLong(round(timeInterval*1000)))"
    }
    // MARK: 1.4、从 Date 获取年份
    /// 从 Date 获取年份
    var year: Int {
        return Calendar.current.component(Calendar.Component.year, from: self.base)
    }
    
    // MARK: 1.5、从 Date 获取月份
    /// 从 Date 获取年份
    var month: Int {
        return Calendar.current.component(Calendar.Component.month, from: self.base)
    }
    
    // MARK: 1.6、从 Date 获取 日
    /// 从 Date 获取 日
    var day: Int {
        return Calendar.current.component(.day, from: self.base)
    }
    
    // MARK: 1.7、从 Date 获取 小时
    /// 从 Date 获取 日
    var hour: Int {
        return Calendar.current.component(.hour, from: self.base)
    }
    
    // MARK: 1.8、从 Date 获取 分钟
    /// 从 Date 获取 分钟
    var minute: Int {
        return Calendar.current.component(.minute, from: self.base)
    }
    
    // MARK: 1.9、从 Date 获取 秒
    /// 从 Date 获取 秒
    var second: Int {
        return Calendar.current.component(.second, from: self.base)
    }
    
    // MARK: 1.10、从 Date 获取 毫秒
    /// 从 Date 获取 毫秒
    var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self.base)
    }
    // MARK: 1.11、从日期获取 星期(英文)
    /// 从日期获取 星期
    var weekday: String {
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self.base)
    }
    
    // MARK: 1.12、从日期获取 星期(中文)
    var weekdayStringFromDate: String {
        let weekdays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(identifier: "Asia/Shanghai")
        calendar.timeZone = timeZone!
        let theComponents = calendar.dateComponents([.weekday], from: self.base as Date)
        return  weekdays[theComponents.weekday! - 1]
    }
    
    // MARK: 1.13、从日期获取 月(英文)
    /// 从日期获取 月(英文)
    var monthString: String {
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self.base)
    }
}
//MARK: - 二、时间格式的转换
public enum TimeBarType {
    // 默认格式 如9秒：09  66秒： 01:06
    case normal
    case second
    case minute
    case hour
}

public extension ExtensionBase where Base == Date {
    // MARK: 秒转换成播放时间条的格式
    /// 秒转换成播放时间条的格式
    /// - Parameters:
    ///   - secounds: 秒数
    ///   - type: 格式类型
    /// - Returns: 返回时间条
    static func getFormatPlayTime(seconds: Int, type: TimeBarType = .normal) -> String {
        if seconds <= 0{
            return "00:00"
        }
        // 秒
        let second = seconds % 60
        if type == .second {
            return String(format: "%02d", seconds)
        }
        // 分钟
        var minute = Int(seconds / 60)
        if type == .minute {
            return String(format: "%02d:%02d", minute, second)
        }
        // 小时
        var hour = 0
        if minute >= 60 {
            hour = Int(minute / 60)
            minute = minute - hour * 60
        }
        if type == .hour {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        // normal 类型
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        if minute > 0 {
            return String(format: "%02d:%02d", minute, second)
        }
        return String(format: "%02d", second)
    }
}

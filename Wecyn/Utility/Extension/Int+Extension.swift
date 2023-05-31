//
//  Int+Extension.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/8/3.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation

/// 时间戳格式
enum DateFormater:String {
    
    case second = "yyyy-MM-dd HH:mm:ss"
    case minute = "yyyy-MM-dd HH:mm"
    case hour = "yyyy-MM-dd HH"
    case day = "yyyy-MM-dd"
    case month = "yyyy-MM"
    case year = "yyyy"
}

enum MoneyFormater {
    case yuan
    case wan
}

extension Int {
    func dateString(_ dateFormat:DateFormater = .minute) -> String {
        let date:NSDate = NSDate.init(timeIntervalSince1970: self.double)
        let formatter = DateFormatter.init()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = dateFormat.rawValue
        return formatter.string(from: date as Date)
    }
    
    func formatMoney(type:MoneyFormater) -> String {
        switch type {
        case .yuan:
            return String(format: "%.2f", self.double / 100)
        case .wan:
            return String(format: "%.2f", self.double / 1000000)
        }
    }
    
    var sheepPrefix:String {
        "￥" + self.formatMoney(type: .yuan)
    }
    var dolarPrefix:String {
        "$" + self.formatMoney(type: .yuan)
    }
}


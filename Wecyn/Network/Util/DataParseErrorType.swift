//
//  File.swift
//  VictorOnlineParent
//
//  Created by VICTOR03 on 2021/4/15.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation

enum DataParseErrorType {
    case notJson
    case unableHandyJsonNotObject
    case unableHandyJsonNotArray
    case notContainErrorCodeAndMessage
    case unableParse
}
extension DataParseErrorType:CustomStringConvertible {
    var description: String {
        switch self {
        case .notJson:
            return "JSON格式错误"
        case .unableHandyJsonNotObject:
            return "不是JSON对象"
        case .unableHandyJsonNotArray:
            return "不是JSON数组"
        case .notContainErrorCodeAndMessage:
            return "服务器返回不包含应有的错误信息"
        case .unableParse:
            return "无法解析"
        }
    }
}

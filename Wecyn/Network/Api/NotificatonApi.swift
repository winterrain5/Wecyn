//
//  NotificatonApi.swift
//  Wecyn
//
//  Created by Derrick on 2024/2/27.
//

import Foundation
import Moya
enum NotificatonApi {
    case NotificationList(_ type:Int = 0,_ lastId:Int?)
     case NotificationCount
}
extension NotificatonApi:TargetType {
    var path: String {
        switch self {
        case .NotificationList:
            return "/api/notification/searchList/"
        case .NotificationCount:
            return "/api/notification/count/"
        }
    }
    
    var method: Moya.Method {
//        switch self {
//        case .NotificationList:
//            return .get
//        }
        return .get
        
    }
    
    var task: Task {
        switch self {
        case .NotificationList(let type,let lastId):
            return requestParametersByGet(["type":type,"last_id":lastId])
        case .NotificationCount:
            return .requestPlain
        }
    }
}

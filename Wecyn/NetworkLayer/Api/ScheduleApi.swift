//
//  ScheduleApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/25.
//

import Foundation
import Moya
enum ScheduleApi {
    case addEvent(_ model:AddEventRequestModel)
    case eventInfo(_ id: Int)
    case eventList(_ keyword:String? = nil,_ startDate:String? = nil, _ endDate:String? = nil)
    case auditPrivitaEvent(_ id:Int,_ status:Int? = nil)
}

extension ScheduleApi: TargetType {
    var path: String {
        switch self {
        case .addEvent:
            return "/api/schedule/addEvent/"
        case .eventInfo:
            return "/api/schedule/eventInfo/"
        case .eventList:
            return "/api/schedule/searchList/"
        case .auditPrivitaEvent:
            return "/api/schedule/auditPrivateEvent/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addEvent, .auditPrivitaEvent:
            return Moya.Method.post
        default:
            return Moya.Method.get
        }
    }
    
    var task: Task {
        switch self {
        case .addEvent(let model):
            return requestToTask(model)
        case  .eventInfo(let id):
            return requestURLParameters(["id":id])
        case .eventList(let keyword, let startDate, let endDate):
            return requestURLParameters(["keyword":keyword,"start_date":startDate,"end_date":endDate])
        case .auditPrivitaEvent(let id,let status):
            return requestNoneNilParameters(["id":id,"status":status])
        }
    }
}



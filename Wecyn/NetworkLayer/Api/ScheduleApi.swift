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
    case updateEvent(_ model:AddEventRequestModel)
    case deleteEvent(_ id:Int)
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
        case .updateEvent:
            return "/api/schedule/updateEvent/"
        case .deleteEvent:
            return "/api/schedule/deleteEvent/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addEvent, .auditPrivitaEvent, .deleteEvent:
            return Moya.Method.post
        case .updateEvent:
            return Moya.Method.put
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
        case .updateEvent(let model):
            return requestToTask(model)
        case .deleteEvent(let id):
            return requestNoneNilParameters(["id":id])
        }
    }
}



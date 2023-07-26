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
    case eventInfo(_ id: Int,_ currentUserId:Int? =  nil)
    case eventList(_ model:EventListRequestModel)
    case auditPrivitaEvent(_ id:Int,_ status:Int? = nil,_ currentUserId:Int? =  nil)
    case updateEvent(_ model:AddEventRequestModel)
    case deleteEvent(_ id:Int,_ currentUserId:Int? =  nil,_ type:Int? = nil,_ exdate:String? = nil)
    case addAssistants(_ model:AddAssitantsRequestModel)
    case recieveAssistantsList
    case sendedAssistantsList
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
        case .addAssistants:
            return "/api/assistant/setAssistants/"
        case .recieveAssistantsList:
            return "/api/assistant/assistantReceiveList/"
        case .sendedAssistantsList:
            return "/api/assistant/assistantSendList/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addEvent, .auditPrivitaEvent, .deleteEvent, .addAssistants:
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
            return requestToTaskByPost(model)
        case  .eventInfo(let id,let currentUserId):
            return requestParametersByGet(["id":id,"current_user_id":currentUserId])
        case .eventList(let model):
            return requestToTaskByGet(model)
        case .auditPrivitaEvent(let id,let status,let currentUserId):
            return requestParametersByPost(["id":id,"status":status,"current_user_id":currentUserId])
        case .updateEvent(let model):
            return requestToTaskByPost(model)
        case .deleteEvent(let id,let currentUserId,let type,let exdate):
            return requestParametersByPost(["id":id,"current_user_id":currentUserId,"type":type,"exdate":exdate])
        case .addAssistants(let model):
            return requestToTaskByPost(model)
        case .recieveAssistantsList:
            return .requestPlain
        case .sendedAssistantsList:
            return .requestPlain
        }
    }
}



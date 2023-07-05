//
//  ScheduleService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/25.
//

import Foundation

class ScheduleService {
    
    /// 添加事件
    /// - Parameter model: AddEventRequestModel
    /// - Returns: ResponseStatus
    static func addEvent(_ model:AddEventRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(ScheduleApi.addEvent(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 修改事件
    /// - Parameter model: AddEventRequestModel
    /// - Returns: ResponseStatus
    static func updateEvent(_ model:AddEventRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(ScheduleApi.updateEvent(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }


    /// 事件详情
    /// - Parameters:
    ///   - id: 当前登录用户的ID
    ///   - currentUserId: 当前事件所属人的ID
    /// - Returns: ResponseStatus
    static func eventInfo(_ id: Int,currentUserId:Int? = nil) -> Observable<EventInfoModel> {
        let target = MultiTarget(ScheduleApi.eventInfo(id,currentUserId))
        return APIProvider.rx.request(target).asObservable().mapObject(EventInfoModel.self)
    }
    
    
    /// 事件列表
    /// - Parameters:
    ///   - model: EventListRequestModel
    /// - Returns: [EventListModel]
    static func eventList(model:EventListRequestModel) -> Observable<[EventListModel]> {
        let target = MultiTarget(ScheduleApi.eventList(model))
        return APIProvider.rx.request(target).asObservable().mapArray(EventListModel.self)
    }
    
    
    /// Private 事件审核
    /// - Parameters:
    ///   - id: 事件ID
    ///   - status: 是否接受邀请。默认0。0 待审核，1 同意，2 拒绝
    ///   - currentUserId: 当前事件所属人的ID
    /// - Returns: ResponseStatus
    static func auditPrivateEvent(id:Int,status:Int,currentUserId:Int? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(ScheduleApi.auditPrivitaEvent(id,status,currentUserId))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 删除事件
    /// - Parameters:
    ///   - id: id
    ///   - currentUserId: 当前事件所属人的ID
    /// - Returns: ResponseStatus
    static func deleteEvent(_ id: Int,currentUserId:Int? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(ScheduleApi.deleteEvent(id,currentUserId))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 添加助理
    /// - Parameter model:AddAssitantsRequestModel
    /// - Returns: ResponseStatus
    static func addAssistants(model:AddAssitantsRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(ScheduleApi.addAssistants(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 收到的助理列表
    /// - Returns: [AssistantInfo]
    static func recieveAssistantList() -> Observable<[AssistantInfo]> {
        let target = MultiTarget(ScheduleApi.recieveAssistantsList)
        return APIProvider.rx.request(target).asObservable().mapArray(AssistantInfo.self)
    }
    
    /// 发送的助理列表
    /// - Returns: [AssistantInfo]
    static func sendedAssistantList() -> Observable<[AssistantInfo]> {
        let target = MultiTarget(ScheduleApi.sendedAssistantsList)
        return APIProvider.rx.request(target).asObservable().mapArray(AssistantInfo.self)
    }
}

class EventInfoModel: BaseModel {
    /*
     "id": int # event_id
     "creator_id": int # 创建者的user_id
     "title": string # 标题
     "start_time": "%Y-%m-%d %H:%M:%S" # 开始时间
     "end_time": "%Y-%m-%d %H:%M:%S" # 结束时间
     "desc": string # 即description
     "is_online": int # 0 非线上事件（线下事件），1 线上事件
     "location": string # 位置
     "url": string # 链接
     "is_public": int # 0 Private，1 Public
     "attendees": string # 对应is_public=0。参与者。格式：[{"id": user_id, "status": status, "name": name}, ...]
     注：name即first_name + last_name
     "attendance_limit": int # 对应is_public=1。限制参与者人数（大于等于1的整数）
     "remarks": string # 仅创建者可见
     "attendance_count": int # 仅当is_public=1时存在。参与者人数
     "attendees_public": string # 仅当is_public=1时存在。参与者基本信息。格式：[{"id": user_id, "name": name, "avatar": avatar}, ...]
     */
    
    var id: Int = 0
    var is_public: Int = 0
    var attendees: [Attendees] = []
    var url: String = ""
    var start_time: String = ""
    var desc: String = ""
    var title: String = ""
    var is_online: Int = 0
    var location: String = ""
    var creator_id: Int = 0
    var end_time: String = ""
    var attendance_limit: String = ""
    
    var attendance_count = 0
    var attendees_public = ""
    var remarks = ""
    
    
    var calendar_belong_id:Int = 0
    var calendar_belong_name:String = ""
    
}
class Attendees: BaseModel {
    var id: Int = 0
    var status: Int = 0
    var name: String = ""
}

class EventListModel: BaseModel {
    /*
     "id": int # event_id
     "title": string # 标题
     "start_time": "%Y-%m-%d %H:%M:%S" # 开始时间
     "end_time": "%Y-%m-%d %H:%M:%S" # 结束时间
     "is_public": int # 0 Private，1 Public
     "status": int # 是否接受邀请。0 待审核，1 同意，2 拒绝
     "is_creator": int # 是否为创建者。0 否，1 是
     */
    var id: Int = 0
    var title = ""
    var start_time = ""
    var end_time = ""
    var is_public = 0
    var status = 0
    var is_creator = 0
    var creator_id = 0
    
    var creator_name = ""
    var creator_avatar = ""
    
    var calendar_belong_id:Int = 0
    var calendar_belong_name:String = ""
}

class AssistantInfo: BaseModel {
    var id: Int = 0
    var name: String = ""
    var avatar: String = ""
}

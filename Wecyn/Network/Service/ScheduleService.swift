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
        return APIProvider.rx.request(target).asObservable().mapObjectArray(EventListModel.self)
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
    ///   - type: 删除事件类型 1 此事件 2 此事件及后续 nil 所有事件
    ///   - exdate: 当前事件的时间
    /// - Returns: ResponseStatus
    static func deleteEvent(_ id: Int,currentUserId:Int? = nil,type:Int? = nil, exdate:String? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(ScheduleApi.deleteEvent(id,currentUserId,type,exdate))
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
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AssistantInfo.self)
    }
    
    /// 发送的助理列表
    /// - Returns: [AssistantInfo]
    static func sendedAssistantList() -> Observable<[AssistantInfo]> {
        let target = MultiTarget(ScheduleApi.sendedAssistantsList)
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AssistantInfo.self)
    }
    
    
    /// 会议房间列表
    /// - Parameter id: id
    /// - Returns: MeetingRoom
    static func meetingRoomList(id: Int) -> Observable<[MeetingRoom]> {
        let target = MultiTarget(ScheduleApi.meetingRoom(id))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(MeetingRoom.self)
    }
    
    
    /// 解析ics文件
    /// - Parameter icsStr: ics
    /// - Returns: iCSFileParsedModel
    static func parseics(icsStr:String) -> Observable<iCSFileParsedModel> {
        let target = MultiTarget(ScheduleApi.parseics(icsStr))
        return APIProvider.rx.request(target).asObservable().mapObject(iCSFileParsedModel.self)
    }
}

class iCSFileParsedModel: BaseModel {
    /*
     title (string)
     事件标题
     start_time (string: %d-%m-%Y %H:%M:%S)
     开始时间
     end_time (string: %d-%m-%Y %H:%M:%S)
     结束时间
     is_repeat (int)
     是否为重复事件。0 非重复事件，1 重复事件
     rrule_str (string)
     重复规则
     desc (string)
     即description
     location (string)
     位置
     url (string)
     链接
     */
    var title:String = ""
    var start_time:String = ""
    var end_time:String = ""
    var is_repeat:Int = 0
    var rrule_str:String = ""
    var desc:String = ""
    var location:String = ""
    var url:String = ""
}

@objcMembers class EventInfoModel: BaseModel {
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
    var location: String = ""
    var creator_id: Int = 0
    var creator_name: String = ""
    var end_time: String = ""
    var attendance_limit: Int = 0
    
    var attendance_count = 0
    var attendees_public = ""
    var remarks = ""
    var emails:[String] = []
    var room_id:Int = 0
    var room_name:String = ""
    var roomModel:MeetingRoom {
        let m = MeetingRoom()
        m.id = room_id
        m.name = room_name
        m.isSelect = true
        return m
    }
    
    var color:Int = 0
    var colorHexString:String? {
        if color < EventColor.allColor.count {
            return EventColor.allColor[color]
        }
        return nil
    }
    
    var rrule_str:String = ""
    var is_repeat:Int = 0
    
    var isCreator:Bool {
        CalendarBelongUserId == creator_id
    }
    
    var isCrossDay: Bool = false
    var isBySearch: Bool = false
    
    var repeat_start_time:String?
    var repeat_start_date:Date? {
        return repeat_start_time?.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue)
    }
    var repeat_end_time:String? {
        repeat_start_date?.addingTimeInterval(duration).toString()
    }
    var repeat_end_Date:Date? {
        repeat_start_date?.addingTimeInterval(duration)
    }
    
    var start_date:Date? {
        return start_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue)
    }
    var end_date:Date? {
        return end_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue)
    }
    var duration:TimeInterval  {
        guard let start = start_date,let end = end_date else { return 0 }
        return start.distance(to: end)
    }
    
    var rruleObject:RecurrenceRule? {
        if rrule_str.isEmpty == false, let rruleOptions = RecurrenceRule.toRRuleOptions(rrule_str) {
            let rruleObj = RRule.ruleFromDictionary(rruleOptions)
            return rruleObj
        }
        return nil
    }
    var recurrenceDescription:String {
        
        let startTime = start_time.split(separator: " ").last ?? ""
        let endTime = end_time.split(separator: " ").last ?? ""
        var desc = ""
        if isBySearch {
            desc =  start_time + "\n" + end_time + "\n\(formateTime(duration.int))"
            return desc
        }
        if is_repeat == 1 {
            // DTSTART:20230717T062741Z\nRRULE:FREQ=DAILY;INTERVAL=1;WKST=MO;COUNT=4
            let repeatStr = "repeat " + (rruleObject?.toText(rrulestr: rrule_str) ?? "") + ",start from \(start_time)"
            desc = (repeat_start_time ?? "") + "\n" + (startTime + " → " + endTime + "(\(formateTime(duration.int)))") + "\n" + repeatStr
            return desc
            
        }
        
        if isCrossDay {
            desc = start_time + "\n" + end_time + "\n\(formateTime(duration.int))"
            return desc
        }
        
        desc = start_time + "\n" + (startTime + " → " + endTime + "(\(formateTime(duration.int)))")
        return desc
    }
    var recurrenceType: String {
        if let freq = rruleObject?.frequency.toString().lowercased() {
            return  "repeat " + freq
        } else {
            return "none"
        }
        
    }
    
    func formateTime(_ duration:Int) -> String {
        let day = duration / (60 * 60 * 24);
        let hour = (duration % (60 * 60 * 24)) / (60 * 60)
        let minitue = (duration % (60 * 60)) / (60)
        
        var desc = ""
        let dayUnit = day > 1 ? "days" : "day"
        let hourUnit = hour > 1 ? "hours" : "hour"
        let minUnit = minitue > 1 ? "mins" : "min"
        if day > 0 {
            desc += "\(day) \(dayUnit) "
        }
        if hour > 0 {
            desc += "\(hour) \(hourUnit) "
        }
        if minitue > 0 {
            desc += "\(minitue) \(minUnit)"
        }
        
        return desc
    }
    
    var isCreateByiCS:Bool = false
    
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
    var is_own = 0 // 该事件是否与自己有关
    var creator_id = 0
    var creator_name = ""
    var creator_avt = ""
    var is_repeat = 0
    var rrule_str = ""
    var exdates:[String] = []
    var exdatesObject:[Date?] {
        exdates.map({ $0.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue)})
    }
    var color = 0
    
    var isCrossDay: Bool = false
    var isCrossDayStart: Bool = false
    var isCrossDayEnd: Bool = false
    var isCrossDayMiddle: Bool = false
    
    var isBySearch: Bool = false
    
    var colorHexString:String? {
        if color < EventColor.allColor.count {
            return EventColor.allColor[color]
        }
        return nil
    }
    
    var rruleObject:RecurrenceRule? {
        if rrule_str.isEmpty == false,let rruleOptions = RecurrenceRule.toRRuleOptions(rrule_str) {
            let rruleObj = RRule.ruleFromDictionary(rruleOptions)
            return rruleObj
        }
        return nil
    }
    
    var isParentData = false
    var start_date:Date? {
        return start_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue)
    }
    var end_date:Date? {
        return end_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue)
    }
    var duration:TimeInterval  {
        guard let start = start_date,let end = end_date else { return 0 }
        return start.distance(to: end)
    }
    func copyed(_ startDate:Date, endDate:Date? = nil, isCrossDays:Bool = false) -> EventListModel {
        let model = EventListModel()
        model.id = id
        model.title = title
        
        model.is_public = is_public
        model.status = status
        model.is_creator = is_creator
        model.creator_id = creator_id
        model.creator_avt = creator_avt
        model.creator_name = creator_name
        model.is_repeat = is_repeat
        model.color = color
        model.rrule_str = rrule_str
        model.is_own = is_own
        model.isParentData = false
        
        if isCrossDays {
            model.start_time = startDate.toString()
            model.end_time = endDate?.toString() ?? ""
        } else {
            model.start_time = startDate.toString()
            model.end_time = startDate.addingTimeInterval(duration).toString()
        }
        
        return model
    }
    
    
}

class AssistantInfo: BaseModel {
    var id: Int = 0
    var name: String = ""
    var avatar: String = ""
}

class MeetingRoom: BaseModel,Codable {
    var id: Int = 0
    var name: String = ""
    var isSelect: Bool = false
}

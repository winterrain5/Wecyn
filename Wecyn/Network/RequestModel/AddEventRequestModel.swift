//
//  AddEventRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/25.
//

import UIKit
/*
 参数
        "title": string # 必填。长度不得超过50个字符
        "color": int # 选填。事件颜色
        "start_time": "%Y-%m-%d %H:%M:%S" # 必填
        "end_time": "%Y-%m-%d %H:%M:%S" # 选填
        "is_repeat": int # 选填。是否为重复事件。0 非重复事件，1 重复事件
        "rrule": string # 选填。重复规则
        "desc": string # 选填。即description
        "is_online": int # 选填。默认：0。0 非线上事件（线下事件），1 线上事件
        "location": string # 选填。位置
        "url": string # 选填。链接
        "is_public": int # 选填。默认：0。0 Private，1 Public
        "attendees": string # 选填。对应is_public=0。参与者。格式：[{"id": user_id, "status": status}, ...]
                            # 注：① id即user_id
                            #     ② status，是否接受邀请。默认传0。0 未知，1 同意，2 拒绝
                            #     ③ 这里不必传创建者，因为创建者的status必然是1
        "attendance_limit": int # 选填。对应is_public=1。限制参与者人数（大于等于1的整数）
        "remarks": string # 选填
        "current_user_id" # 选填。仅当操作他人Schedule时传此参数
        注：attendees和attendance_limit二者选其一
            若is_public=0，则只传参attendees
            若is_public=1，则只传参attendance_limit
 */
import HandyJSON
class AddEventRequestModel: BaseModel {
    var end_time: String?
    var is_online: Int = 0
    var is_public: Int = 0
    var current_user_id: Int?
    var remarks: String?
    var title: String?
    var start_time: String?
    var location: String?
    var url: String?
    var attendance_limit: Int?
    var attendees: [Attendees]?
    var desc: String = ""
    var is_repeat: Int?
    var exdate_str: String?
    var rrule_str:String?
    var color: Int?
    // update event 
    var id: Int?
    
}


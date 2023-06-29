//
//  AddEventRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/25.
//

import UIKit
/*
 "title": string # 必填
 "start_time": "%Y-%m-%d %H:%M:%S" # 必填
 "end_time": "%Y-%m-%d %H:%M:%S" # 选填
 "description": string # 选填
 "is_online": int # 选填。默认：0。0 非线上事件（线下事件），1 线上事件
 "location": string # 选填。位置
 "url": string # 选填。链接
 "is_public": int # 选填。默认：0。0 Private，1 Public
 "attendees": string # 选填。对应is_public=0。参与者。格式：[{"user_id": user_id, "status": status}, ...]
 # 注：status，是否接受邀请。默认传0。0 未知，1 同意，2 拒绝
 "attendance_limit": int # 选填。对应is_public=1。限制参与者人数（非负整数）。
 "remarks": string # 选填
 */
import HandyJSON
class AddEventRequestModel: BaseModel {
    var end_time: String?
    var is_online: Int = 0
    var is_public: Int = 0
    var remarks: String?
    var title: String?
    var start_time: String?
    var location: String?
    var url: String?
    var attendance_limit: Int?
    var attendees: [Attendees]?
    var desc: String?
    // update event 
    var id: Int?
    
}


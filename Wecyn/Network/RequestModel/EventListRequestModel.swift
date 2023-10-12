//
//  EventListRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/3.
//

import UIKit

/*
 ///   - current_user_id: 仅当操作他人Schedule时传此参数
 ///   - keyword: 模糊查询title。默认空字符串
 ///   - startDate: 开始日期
 ///   - endDate: 结束日期
 */
class EventListRequestModel: BaseModel {
    var current_user_id:Int?
    var end_date:String?
    var start_date:String?
    var keyword:String?
    var room_id:Int?
}

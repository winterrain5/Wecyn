//
//  AddUserExperienceRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/10/23.
//

import UIKit

class AddUserExperienceRequestModel: BaseModel {
    var org_id: Int = 0
    var title_name: String?
    var is_current: Int = 0
    var start_date: String?
    var industry_name: String?
    var degree_name: String?
    var exp_type: Int = 0
    var field_name: String?
    var org_name: String?
    var end_date: String?
    var desc: String?
    var id:Int?
}

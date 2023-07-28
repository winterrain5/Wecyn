//
//  UpdateUserInfoRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/27.
//

import UIKit

class UpdateUserInfoRequestModel: BaseModel {
    var postal_code: String?
    var website: String?
    var last_name: String?
    var office_location: String?
    var location_id: Int = 0
    var office_number: String?
    var country_region_id: Int = 0
    var first_name: String?
    var mobile: String?
    var company_name: String?
    var job_title: String?
}

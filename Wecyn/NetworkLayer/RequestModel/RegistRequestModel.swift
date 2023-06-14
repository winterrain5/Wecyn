//
//  LoginRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation

class RegistRequestModel:BaseModel {
    var password: String?
    var postal_code: String?
    var last_name: String?
    var email: String?
    var location_id: Int?
    var country_region_id: Int?
    var first_name: String?
}

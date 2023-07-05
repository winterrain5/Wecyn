//
//  LoginRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation

class RegistRequestModel:BaseModel, Codable {
    var password: String?
    var postal_code: String?
    var last_name: String?
    var email: String?
    var location_id: Int?
    var country_region_id: Int?
    var first_name: String?
    
    var job_title: String? = nil
    var employment_type: String? = nil
    var recent_company: String? = nil
    var country: String? = nil
    var city: String? = nil
}

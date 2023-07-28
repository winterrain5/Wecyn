//
//  UserInfoModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/20.
//

import UIKit

class UserInfoModel: BaseModel,Codable {
    
    var id: Int = 0
    var mobile: String = ""
    var office_number: String = ""
    var job_title: String = ""
    var company: String = ""
    var avatar: String = ""
    var office_location: String = ""
    var first_name: String = ""
    var wid: String = ""
    var last_name: String = ""
    var email: String = ""
    var website: String = ""
    
    var full_name:String {
        return String.fullName(first: first_name, last: last_name)
    }
    
}

//
//  UserInfoModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/20.
//

import UIKit

class UserInfoModel: BaseModel,Codable {
    var mobile: String = ""
    var avatar: String  = ""
    var id: Int = 0
    var last_name: String = ""
    var wid: String = ""
    var email: String = ""
    var first_name: String = ""
    
    var full_name:String {
        return String.fullName(first: first_name, last: last_name)
    }
    
}

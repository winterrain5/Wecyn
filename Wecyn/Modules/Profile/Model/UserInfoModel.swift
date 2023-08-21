//
//  UserInfoModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/20.
//

import UIKit

@objcMembers class UserInfoModel: BaseModel,Codable {
    
    var id: String = ""
    var uuid: String = ""
    var tel_work: String = ""
    var company_id: String = ""
    var url: String = ""
    var company: String = ""
    var title: String = ""
    var avatar: String = ""
    var tel_cell: String = ""
    var wid: String = ""
    var first_name: String = ""
    var country_region: String = ""
    var city: String = ""
    var last_name: String = ""
    var email: String = ""
    var adr_work: String = ""

    var full_name:String {
        return String.fullName(first: first_name, last: last_name)
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
}

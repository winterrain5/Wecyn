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
    var org_id: String = ""
    var url: String = ""
    var org_name: String = ""
    var title: String = ""
    var avatar: String = ""
    var avatar_url: URL? {
        return URL(string: avatar)
    }
    var cover: String = ""
    var cover_url: URL? {
        return URL(string: cover)
    }
    var tel_cell: String = ""
    var wid: String = ""
    var first_name: String = ""
    var country_region: String = ""
    var city: String = ""
    var last_name: String = ""
    var email: String = ""
    var adr_work: String = ""
    
    var color_remark:[String] = []
    var edu_exp:[UserExperienceInfoModel] = []
    var work_exp:[UserExperienceInfoModel] = []
    
    var is_admin = 0
    var is_super = 0

    var full_name:String {
        get {
            String.fullName(first: first_name, last: last_name)
        }
        set {
            first_name = newValue
        }
    }
    
    override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
}

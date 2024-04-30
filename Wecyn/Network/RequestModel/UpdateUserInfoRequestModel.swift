//
//  UpdateUserInfoRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/27.
//

import UIKit
/*

 */
@objcMembers class UpdateUserInfoRequestModel: BaseModel {
    var id: String = ""
    var uuid: String?
    var tel_work: String?
    var org_id: String?
    var url: String?
    var org_name: String?
    var title: String?
    var avatar: String?
    var tel_cell: String?
    var wid: String?
    var first_name: String?
    var country_region: String?
    var city: String?
    var last_name: String?
    var email: String?
    var adr_work: String?
    var color_remark:[String] = []
    var headline: String?
}

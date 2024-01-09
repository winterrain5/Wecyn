//
//  AdminStaffModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit


class AdminStaffExps :BaseModel {
    var status: Int = 0
    var is_current: Int = 0
    var id: Int = 0
    var start_date: String = ""
    var title_name: String = ""
    var user_id: Int = 0
    var exp_type: Int = 0
    var industry_name: String = ""
    var end_date: String = ""
    var desc: String = ""
    
}

class AdminStaffDept :BaseModel {
    var remark: String = ""
    var id: Int = 0
    var has_addr: Int = 0
    var addr: String = ""
    var full_path: String = ""
    var name: String = ""
    var pid: Int = 0
    
}

class AdminStaffUser :BaseModel {
    var id: Int = 0
    var last_name: String = ""
    var first_name: String = ""
    var avatar: String = ""
    
}

class AdminStaffRole :BaseModel {
    var id: Int = 0
    var name: String = ""
    var dept_id: Int = 0
    var dept_full_path: String = ""
    
}

class AdminStaffModel :BaseModel {
    var org_id: Int = 0
    var exps: [AdminStaffExps]?
    var titles: String = ""
    var id: Int = 0
    var is_admin: Int = 0
    var dept: AdminStaffDept?
    var role: AdminStaffRole?
    var user: AdminStaffUser?
    
}

class AdminNewStaffModel: BaseModel {
    var id: Int = 0
    var desc: String?
    var start_date: String?
    var role_id: Int = 0
    var operator_id: Int = 0
    var apply_time: String?
    var user_id: Int = 0
    var title_name: String?
    var industry_name: String?
    var dept_id: Int = 0
    var role_dept_id: Int = 0
    var user_remark: String?
    var admin_remark: String?
    var user: AdminStaffUser?
    var status: Int = 0
    var org_id: Int = 0
    
}

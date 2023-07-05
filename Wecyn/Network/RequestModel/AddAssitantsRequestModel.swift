//
//  AddAssitantsRequestModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/3.
//

import UIKit
/*
 "assistants": array # 必填。助理。格式：[{"id": user_id, "type": type}, ...]
 # 注：① id即user_id
 #     ② type，权限。默认传1（所有）
 */
class AddAssitantsRequestModel: BaseModel {
    var assistants: [Assistant] = []
}

class Assistant: BaseModel {
    var id:Int?
    var type:Int = 1
}

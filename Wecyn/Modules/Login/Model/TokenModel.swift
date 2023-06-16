//
//  VerificationCodeModel.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class TokenModel: BaseModel,Codable {
    var user_id:Int = 0
    var refresh_token: String = ""
    var token: String = ""
    var expiry_time: String = ""
}

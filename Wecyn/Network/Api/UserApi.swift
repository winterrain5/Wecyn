//
//  UserApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import Foundation
import Moya
enum UserApi {
    case uploadAvatar(photo:String)
    case userInfo
}

extension UserApi: TargetType {
    var path: String {
        switch self {
        case .uploadAvatar:
            return "/api/user/uploadAvatar/"
        case .userInfo:
            return "/api/user/userInfo/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .userInfo:
            return Moya.Method.get
        default:
            return Moya.Method.post
        }
    }
    
    var task: Task {
        switch self {
        case .uploadAvatar(let photo):
            return requestParametersByPost(["photo":photo])
        case .userInfo:
            return .requestPlain
        }
    }
}

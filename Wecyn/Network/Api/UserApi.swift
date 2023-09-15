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
    case updateUserInfo(model:UpdateUserInfoRequestModel)
    case uploadCover(photo:String)
}

extension UserApi: TargetType {
    var path: String {
        switch self {
        case .uploadAvatar:
            return "/api/user/uploadAvatar/"
        case .userInfo:
            return "/api/user/userInfo/"
        case .updateUserInfo:
            return "/api/user/updateUserInfo/"
        case .uploadCover:
            return "/api/user/uploadCover/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .userInfo:
            return Moya.Method.get
        case .updateUserInfo:
            return Moya.Method.put
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
        case .updateUserInfo(let model):
            return requestToTaskByPost(model)
        case .uploadCover(let photo):
            return requestParametersByPost(["photo":photo])
        }
    }
}

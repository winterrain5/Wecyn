//
//  RequestApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation
import Moya
import RxMoyaCache

let UserProvider = MoyaProvider<UserApi>()
enum UserApi {
    case emailSendeVerificationCode(email:String)
    case emailVerification(email:String,code:String)
    case getCountryList
    case getCityList(countryId:Int)
    case uploadAvatar(photo:String)
    case signup(model:RegistRequestModel)
    case signin(username:String,password:String)
}

extension UserApi:  TargetType, Cacheable  {
    
    var path: String {
        switch self {
        case .emailSendeVerificationCode:
            return "/auth/emailSendVerificationCode/"
        case .emailVerification:
            return "/auth/emailVerification/"
        case .getCountryList:
            return "/local-geo/country/"
        case .getCityList:
            return "/local-geo/city/"
        case .uploadAvatar:
            return "/user/uploadAvatar/"
        case .signup:
            return "/auth/signUp/"
        case .signin:
            return "/auth/signIn/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getCountryList:
            return Moya.Method.get
        case .getCityList:
            return Moya.Method.get
        default:
            return Moya.Method.post
        }
    }
    var task: Task {
        switch self {
        case .emailSendeVerificationCode(let email):
            return requestParameters(["email":email])
        case .emailVerification(let email,let code):
            return requestParameters(["email":email,"code":code])
        case .getCountryList:
            return .requestPlain
        case .getCityList(let countryID):
            return requestURLParameters(["country_id":countryID])
        case .uploadAvatar(let photo):
            return requestParameters(["photo":photo])
        case .signup(let model):
            return requestToTask(model)
        case .signin(let username,let password):
            return requestParameters(["username":username,"password":password])
        }
    }
    
}

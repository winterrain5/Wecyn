//
//  RequestApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation
import Moya
import RxMoyaCache

let UserProvider = MoyaProvider<AuthApi>()
enum AuthApi {
    case emailSendeVerificationCode(email:String)
    case emailVerification(email:String,code:String)
    case getCountryList
    case getCityList(countryId:Int)
    case signup(model:RegistRequestModel)
    case signin(username:String,password:String)
}

extension AuthApi:  TargetType, Cacheable  {
    
    var path: String {
        switch self {
        case .emailSendeVerificationCode:
            return "/api/auth/emailSendVerificationCode/"
        case .emailVerification:
            return "/api/auth/emailVerification/"
        case .getCountryList:
            return "/api/local-geo/country/"
        case .getCityList:
            return "/api/local-geo/city/"
        case .signup:
            return "/api/auth/signUp/"
        case .signin:
            return "/api/auth/signIn/"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getCountryList,  .getCityList:
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
        case .signup(let model):
            return requestToTask(model)
        case .signin(let username,let password):
            return requestParameters(["username":username,"password":password])
        }
    }
    
}

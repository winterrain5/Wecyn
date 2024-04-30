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
    case resetPassword(_ email:String,_ code:String,_ password:String)
}

extension AuthApi:  TargetType, Cacheable  {
    
    var path: String {
        switch self {
        case .emailSendeVerificationCode:
            return "/api/auth/sendVerificationCode/"
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
        case .resetPassword:
            return "/api/auth/resetPassword/"
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
            return requestParametersByPost(["email":email])
        case .emailVerification(let email,let code):
            return requestParametersByPost(["email":email,"code":code,"platform":1])
        case .getCountryList:
            return .requestPlain
        case .getCityList(let countryID):
            return requestParametersByGet(["country_id":countryID])
        case .signup(let model):
            return requestToTaskByPost(model)
        case .signin(let username,let password):
            return requestParametersByPost(["username":username,"password":password,"platform":1])
        case .resetPassword(let email, let code, let pwd):
            return requestParametersByPost(["email":email,"code":code,"password":pwd])
        }
    }
    
}

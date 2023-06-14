//
//  RequestApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation
import Moya
import RxMoyaCache

let RegistProvider = MoyaProvider<RegistApi>()
enum RegistApi {
    case emailSendeVerificationCode(email:String)
    case emailVerification(email:String,code:String)
    case getCountryList
    case getCityList(countryId:Int)
    case signup(model:RegistRequestModel)
}

extension RegistApi:  TargetType, Cacheable  {
    
    var path: String {
        switch self {
        case .emailSendeVerificationCode:
            return "/wecyn/auth/emailSendVerificationCode/"
        case .emailVerification:
            return "/wecyn/auth/emailVerification/"
        case .getCountryList:
            return "/wecyn/local-geo/country/"
        case .getCityList(let countryID):
            return "/wecyn/local-geo/city/"
        case .signup:
            return "/wecyn/auth/signUp/"
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
        case .signup(let model):
            return requestToTask(model)
        }
    }
    
}
extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

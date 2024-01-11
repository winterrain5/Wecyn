//
//  MainApi.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/7/6.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import HandyJSON


/// 对request设置超时时间等
let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        request.timeoutInterval = 30
        done(.success(request))
    } catch {
        done(.failure(MoyaError.underlying(error, nil)))
    }
}

/// 通用请求Provider
let APIProvider = MoyaProvider<MultiTarget>(requestClosure:requestClosure,
                                            plugins: [NetworkLogPlugin()])



extension TargetType {
    
    var baseURL: URL {
        return URL(string:APIHost.share.BaseUrl.trimmed)!
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var method: Moya.Method {
        return Moya.Method.post
    }
    
    var headers: [String : String]? {
        if let token = UserDefaults.sk.get(of: TokenModel.self, for: TokenModel.className)?.token {
            return  [
                "device_type":"ios",
                "app_version":Device.appVersion,
                "device_system_version":Device.sysVersion,
                "Authorization": "Bearer " + token,
                "tz": TimeZone.current.identifier
            ]
        } else {
            return  [
                "device_type":"ios",
                "app_version":Device.appVersion,
                "device_system_version":Device.sysVersion,
                "tz": TimeZone.current.identifier
                    ]
        }
        
    }


    
    func requestToTaskByGet<T:HandyJSON>(_ request: T?) -> Task {
        guard let parameters = request?.toJSON() else { return .requestPlain }
        return .requestParameters(parameters: parameters, encoding: URLEncoding(destination: .queryString))
    }
    
    func requestParametersByGet(_ parameter:[String: Any?]) -> Task {
        return .requestParameters(parameters: parameter.compactMapValues{ $0 }, encoding: URLEncoding(destination: .queryString))
    }
    
    func requestToTaskByPost<T:HandyJSON>(_ request: T?) -> Task {
        guard let parameters = request?.toJSON() else { return .requestPlain }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    func requestParametersByPost(_ parameters:[String:Any?]) -> Task {
        return .requestParameters(parameters: parameters.compactMapValues{ $0 }, encoding: JSONEncoding.default)
    }

   
}


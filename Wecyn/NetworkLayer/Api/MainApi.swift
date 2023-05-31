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
        return  [
            "versionDevice":"ios",
            "versionNumber":Device.appVersion,
            "versionApp":"crm",
            "versionDeviceNumber":Device.sysVersion,
            "deviceModel":Device.deviceModel,
            "token-type":"5"
        ]
    }
    
    func requestToTask<T:HandyJSON>(_ request: T?) -> Task {
        guard let parameters = request?.toJSON() else { return .requestPlain }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    func requestNoneNilParameters(_ parameters:[String:Any?]) -> Task {
        return .requestParameters(parameters: parameters.compactMapValues{ $0 }, encoding: JSONEncoding.default)
    }
    
    func requestParameters(_ parameters:[String:Any]) -> Task {
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

}


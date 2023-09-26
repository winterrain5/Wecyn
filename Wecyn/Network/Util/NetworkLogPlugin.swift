//
//  NetworkLogPlugin.swift
//  VictorOnlineParent
//
//  Created by VICTOR03 on 2021/4/19.
//  Copyright © 2021 Victor. All rights reserved.
//

import UIKit
import Moya
class NetworkLogPlugin: PluginType {
    /// 返回数据的格式化
    fileprivate func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
    
    fileprivate func JSONRequestDataFormatter(_ data: Data) -> String? {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func didReceive(_ result: Swift.Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            APIError.moyaErrorHandler(response.statusCode)
            outputItems(logNetworkResponse(response.response, data: response.data, target: target))
        case .failure(let error):
            outputItems(logNetworkError(error.response, target: target))
        }
        
    }
    
    func logNetworkError(_ response:Response?,target: TargetType) -> [String] {
        var output = [String]()
        output += [format(identifier: "Request URL", message: "\(target.baseURL)\(target.path)")]
        output += [format(identifier: "Request Headers", message: "\(target.headers ?? [:])")]
        output += [format(identifier: "Error", message: response?.debugDescription ?? "")]
        return output
    }
    
    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> [String]{
        guard let _ = response else {
            return [format(identifier: "Response", message: "Received empty network response for \(target).")]
        }

        var output = [String]()
        
        output += [format(identifier: "Request URL", message: "\(target.baseURL)\(target.path)")]
        
        output += [format(identifier: "Request Headers", message: "\(target.headers ?? [:])")]
        
        switch target.task{
        case .requestParameters(let parameters,_):
            let json = (parameters.jsonString() ?? "").replacingOccurrences(of: "\\", with: "")
            output += [format(identifier: "Request Body", message: json)]
        default:
            output += ["No Request Body"]
        }
        
        if let data = data, let stringData = String(data: JSONResponseDataFormatter(data), encoding: String.Encoding.utf8) {
            if stringData.isEmpty {
                output += [format(identifier: "Response", message: "Received empty network response for \(target).")]
                return output
            }
            output += [format(identifier: "Response", message: stringData)]
        }
        
        return output
        
    }

    func format(identifier: String, message: String) -> String {
        return "\(identifier): \(message)"
    }
    
    fileprivate func outputItems(_ items: [String]) {
        items.forEach {
            Logger.debug("\($0)", label: "Moya")
        }
    }
}

//
//  ObservableType+HandyJson.swift
//  VictorOnlineParent
//
//  Created by Derrick on 2020/6/10.
//  Copyright © 2020 Victor. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import HandyJSON
class ResponseStatus: BaseModel {
    var success: Int   = 1
    var error_type: String = ""
    var message: String = ""
}
//解析路径
private let DataKey = "data"
private let ListKey = "list"

extension ObservableType where Element == Moya.Response {
    
    /// 过滤错误类型
    /// - Returns: dictionary
    func filterNetworkErrorAndMapJSON(toast:Bool = true) -> Observable<[String: Any]>  {
        return mapJSON()
            .catchError({ (error) -> Observable<Any> in
                throw APIError.networkError(error)
            })
            .map({ (response) -> [String: Any] in
                
                guard let res = response as? [String: Any] else {
                    throw APIError.serviceError(.notJson)
                }
                guard let status = ResponseStatus.deserialize(from: res) else {
                    throw APIError.serviceError(.notContainErrorCodeAndMessage)
                }
                guard status.success == 1 else {
                    APIError.errorCodeHandler(status.success,status.message,toast)
                    throw APIError.requestError(code: status.success, message: status.message)
                }
                return res
            })
    }
    
    
    /// 解析返回状态码
    /// - Returns: ResponseStatus
    func mapStatus(toast:Bool = true) -> Observable<ResponseStatus> {
        return mapJSON()
            .catchError({ (error) -> Observable<Any> in
                throw APIError.networkError(error)
            })
            .map({ (response) -> ResponseStatus in
                
                guard let res = response as? [String: Any] else {
                    throw APIError.serviceError(.notJson)
                }
                guard let status = ResponseStatus.deserialize(from: res) else {
                    throw APIError.serviceError(.notContainErrorCodeAndMessage)
                }
                return status
            })
    }
    
    
    /// 解析对象
    /// - Parameters:
    ///   - type: 对象类型
    ///   - designatedPath: 解析路径 默认 data
    /// - Returns: 对象
    func mapObject<T: HandyJSON>(_ type: T.Type, designatedPath: String = DataKey,toast:Bool = true) -> Observable<T> {
        return filterNetworkErrorAndMapJSON(toast:toast)
            .map({ (response) in
                //服务器返回格式解析错误
                guard let obj = T.deserialize(from: response, designatedPath: designatedPath) else {
                    throw APIError.serviceError(.unableHandyJsonNotObject)
                }
                return obj
            })
    }
    
    
    /// 解析数组模型
    /// - Parameters:
    ///   - type: 模型类型
    /// - Returns: 数组模型
    func mapArray<T: HandyJSON>(_ type: T.Type,toast:Bool = true) -> Observable<[T]> {
        return filterNetworkErrorAndMapJSON(toast:toast)
            .map({ (response)  in
                let jsonArray = JSON(response)[DataKey].arrayObject
                guard let array = Array<T>.deserialize(from: jsonArray) as? [T] else {
                    throw APIError.serviceError(.unableHandyJsonNotArray)
                }
                return array
            })
    }
    
    
    /// 解析基本数据类型数组
    /// - Parameters:
    ///   - type: 数组里的数据类型
    ///   - designatedPath: 解析的路径 默认 list
    /// - Returns: 数组
    func mapArray<T>(_ type: T.Type,toast:Bool = true) -> Observable<[T]> {
        return filterNetworkErrorAndMapJSON(toast:toast)
            .map({ (response)  in
                guard let jsonArray = response[DataKey] as? [T] else {
                    throw APIError.serviceError(.unableHandyJsonNotArray)
                }
                return jsonArray
            })
    }
    
    
    /// 解析字典
    /// - Parameters:
    ///   - key: 模块对应的key 如 "dict":{}
    ///   - type: key 对应的value的类型
    ///   - designatedPath: 需要解析的路径 默认 data
    /// - Returns:字典
    func mapDictionary<T>(_ key: String, _ type: T.Type, designatedPath: String = DataKey,toast:Bool = true) -> Observable<T> {
        return filterNetworkErrorAndMapJSON(toast:toast)
            .map({ (response)  in
                guard let dict = response[designatedPath] as? [String : Any] else {
                    throw APIError.serviceError(.unableHandyJsonNotObject)
                }
                guard let value = dict[key] as? T else{
                    throw APIError.serviceError(.unableParse)
                }
                return value
            })
    }
}

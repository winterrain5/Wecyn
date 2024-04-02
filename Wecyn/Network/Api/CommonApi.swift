//
//  CommonApi.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/29.
//

import Foundation
import Moya
enum CommonApi {
    // 获取文件上传url
    case getUploadFileUrl(_ ext:String)
    case getAccessFileUrl(_ name:String)
}

extension CommonApi:TargetType {
    var path: String {
        switch self {
        case .getUploadFileUrl:
            return "/api/im/getUploadFileUrl/"
        case .getAccessFileUrl:
            return  "/api/im/getAccessFileUrl/"
        }

    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getUploadFileUrl(let ext):
            return requestParametersByGet(["ext":ext])
        case .getAccessFileUrl(let name):
            return requestParametersByGet(["name":name])
        }
        
    }
}



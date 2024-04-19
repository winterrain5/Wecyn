//
//  ApiHost.swift
//  VictorOnlineParent
//
//  Created by Derrick on 2020/6/10.
//  Copyright © 2020 Victor. All rights reserved.
//

import Foundation

class APIHost: NSObject {
    
    static let share = APIHost()
    
    var buildType: AppBuildType = .Uat
    
    enum AppBuildType: Int {
        case Dev
        case Uat
        case Release
    }
    
    enum BackgroundServerType: Int {
        case BaseClient
        case ImageClients
        case OpenIMApiClints
        case OpenIMWSClients
        case WebpageClients
    }
    var BaseClients = ["Dev": "http://10.1.3.23:1213",
                       "Uat": "https://uat.wecyn.com",
                       "Release": ""]
    
    var ImageClients = ["Dev": "http://10.1.3.23:1213",
                        "Uat": "https://uat.wecyn.com",
                        "Release": ""]
    
    var WebpageClients = ["Dev": "http://10.1.3.144:5173",
                          "Uat": "https://uat.wecyn.com",
                          "Release": ""]
    
    var OpenIMApiClients = ["Dev": "http://10.1.3.83:10002",
                           "Uat": "https://im.uat.wecyn.com/api",
                           "Release": ""]
    
    var OpenIMWSClients = ["Dev": "ws://10.1.3.83:10001",
                           "Uat": "wss://im.uat.wecyn.com/msg_gateway",
                           "Release": ""]
    
    func getUrlAddress(buildType:AppBuildType,serverType:BackgroundServerType) -> String {
        let buildType = "\(buildType)"
        var address: String
        switch serverType {
        case .BaseClient :
            address = BaseClients[buildType]!
        case .ImageClients:
            address = ImageClients[buildType]!
        case .WebpageClients:
            address = WebpageClients[buildType]!
        case .OpenIMApiClints:
            address = OpenIMApiClients[buildType]!
        case .OpenIMWSClients:
            address = OpenIMWSClients[buildType]!
        }
        return address
    }
    
    @objc var BaseUrl: String {
        return getUrlAddress(buildType: buildType,serverType: .BaseClient)
    }
    
    @objc var ImageUrl: String {
        return getUrlAddress(buildType: buildType,serverType: .ImageClients)
    }
    
    @objc var WebpageUrl: String {
        return getUrlAddress(buildType: buildType,serverType: .WebpageClients)
    }
    
    @objc var OpenImApiUrl: String {
        return getUrlAddress(buildType: buildType, serverType: .OpenIMApiClints)
    }
    
    @objc var OpenImWsUrl: String {
        return getUrlAddress(buildType: buildType, serverType: .OpenIMWSClients)
    }
    
    var allBuildTypeCases:[AppBuildType] {
        return [.Dev,.Uat,.Release]
    }
    
    let suitName = "group.widget.calendar"
    
}

extension APIHost.AppBuildType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Dev:
            return "Dev"
        case .Uat:
            return "Uat"
        case .Release:
            return "Release"
        }
    }
    var currentBuildType:String {
        self.description
    }
}


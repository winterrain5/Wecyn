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
    
    var buildType: AppBuildType = .Dev
    
    enum AppBuildType: Int {
        case Dev
        case Uat
        case Release
    }
    
    enum BackgroundServerType: Int {
        case BaseClient
        case ImageClients
    }
     var BaseClients = ["Dev": "http://10.1.3.23:826",
                        "Uat": "http://27.54.57.5:1412",
                    "Release": ""]
    
    var ImageClients = ["Dev": "http://10.1.3.23:826",
                        "Uat": "http://27.54.57.5:1412",
                    "Release": ""]
    
     func getUrlAddress(buildType:AppBuildType,serverType:BackgroundServerType) -> String {
        let buildType = "\(buildType)"
        var address: String
        switch serverType {
        case .BaseClient :
            address = BaseClients[buildType]!
        case .ImageClients:
            address = ImageClients[buildType]!
        }
        return address
    }
    
    @objc var BaseUrl: String {
        return getUrlAddress(buildType: buildType,serverType: .BaseClient)
    }
   
    @objc var ImageUrl: String {
        return getUrlAddress(buildType: buildType,serverType: .ImageClients)
    }
   
     var allBuildTypeCases:[AppBuildType] {
        return [.Dev,.Uat,.Release]
    }
    
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


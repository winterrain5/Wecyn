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
    }
     var BaseClients = ["Dev": "http://10.1.3.22:826",
                        "Uat": "",
                    "Release": ""]
    
    
     func getUrlAddress(buildType:AppBuildType,serverType:BackgroundServerType) -> String {
        var buildType = "\(buildType)"
        if let current = Defaults.shared.get(for: .currentBuildType) {
            buildType = current
        }else {
            buildType = "\(buildType)"
        }
        var address: String
        switch serverType {
        case .BaseClient :
            address = BaseClients[buildType]!
        }
        return address
    }
    
    @objc var BaseUrl: String {
        return getUrlAddress(buildType: .Dev,serverType: .BaseClient)
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


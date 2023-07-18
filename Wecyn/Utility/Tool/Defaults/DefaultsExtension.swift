//
//  DefaultsExtension.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/29.
//

import Foundation

extension DefaultsKey {
    static let currentBuildType = Key<String>("currentBuildType")
}

extension UserDefaults {
    static var userModel:UserInfoModel? {
        UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    }
}

//
//  UserService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import Foundation
class UserService {
    /// 上传头像
    /// - Parameter photo: base64字符串
    /// - Returns: ResponseStatus
    static func updateAvatar(photo:String) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.uploadAvatar(photo: photo))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 获取用户信息
    /// - Returns: UserInfoModel
    static func getUserInfo() -> Observable<UserInfoModel> {
        let target = MultiTarget(UserApi.userInfo)
        return APIProvider.rx.request(target).asObservable().mapObject(UserInfoModel.self)
    }
}

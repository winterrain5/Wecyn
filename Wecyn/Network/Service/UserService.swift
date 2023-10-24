//
//  UserService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import Foundation
import RxSwift
import Moya
class UserService {
    /// 上传头像
    /// - Parameter photo: base64字符串
    /// - Returns: ResponseStatus
    static func updateAvatar(photo:String) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.uploadAvatar(photo: photo))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 上传cover
    /// - Parameter photo: base64字符串
    /// - Returns: ResponseStatus
    static func updateCover(photo:String) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.uploadCover(photo: photo))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 获取用户信息
    /// - Returns: UserInfoModel
    static func getUserInfo() -> Observable<UserInfoModel> {
        let target = MultiTarget(UserApi.userInfo)
        return APIProvider.rx.request(target).asObservable().mapObject(UserInfoModel.self)
    }
    
    
    /// 修改用户信息
    /// - Parameter model: UpdateUserInfoRequestModel
    /// - Returns: ResponseStatus
    static func updateUserInfo(model:UpdateUserInfoRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.updateUserInfo(model: model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 添加经历（教育、工作
    /// - Parameter model:org_id和org_name至少填一个，start_date必填
    
    /// exp_type，经历类型。1 教育经历（edu experience），2 工作经历（work experience）
    /// 若exp_type=1，则传参field_name（专业）和degree_name（学位）
    /// 若exp_type=2，则传参title_name（职位）和industry_name（行业），title_name必填
    /// - Returns: ResponseStatus
    static func addUserExperience(model:AddUserExperienceRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.addExperience(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 删除经历
    /// - Parameters:
    ///   - id: id
    ///   - type: 经历类型。1 教育经历（edu experience），2 工作经历（work experience）
    /// - Returns: ResponseStatus
    static func deleteUserExperience(id:Int,type:Int) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.deleteExperience(id, type))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 经历详情
    /// - Parameters:
    ///   - id: id
    ///   - type: 经历类型。1 教育经历（edu experience），2 工作经历（work experience）
    /// - Returns: ResponseStatus
    static func experienceInfo(id:Int,type:Int) -> Observable<UserExperienceInfoModel> {
        let target = MultiTarget(UserApi.experienceInfo(id, type))
        return APIProvider.rx.request(target).asObservable().mapObject(UserExperienceInfoModel.self)
    }
    
    
    /// 经历列表
    /// - Parameters:
    ///   - type: 1 教育经历（edu experience），2 工作经历（work experience）
    ///   - userId: 用户id 默认登录用户
    /// - Returns: UserExperienceInfoModel
    static func experienceList(type:Int,userId:Int? = nil) -> Observable<[UserExperienceInfoModel]> {
        let target = MultiTarget(UserApi.experienceList(type,userId))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(UserExperienceInfoModel.self)
    }
    
    /// 组织机构列表
    /// - Parameters:
    ///   - isEdu: 默认0。0 查询所有，1 仅查询教育机构
    ///   - keyword: 关键词
    /// - Returns: OriganizationModel
    static func origanizationList(isEdu:Int = 0,keyword:String) -> Observable<[OriganizationModel]> {
        let target = MultiTarget(UserApi.organizationList(isEdu,keyword))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(OriganizationModel.self)
    }
    
    static func updateUserExperience(model:AddUserExperienceRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.updateExperience(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
}


class UserExperienceInfoModel:BaseModel, Codable {
    var id: Int = 0
    var org_name: String = ""
    var start_date: String = ""
    var start_date_format: String {
        start_date.date(withFormat: "MM-yyyy")?.toString(format: "MMM yyyy") ?? ""
    }
    var end_date_format: String {
        end_date.date(withFormat: "MM-yyyy")?.toString(format: "MMM yyyy") ?? ""
    }
    var degree_name: String = ""
    var field_name: String = ""
    var end_date: String = ""
    var org_avatar: String = ""
    var user_id: Int = 0
    var desc: String = ""
    var title_name: String = ""
    var industry_name: String = ""
    var exp_type: Int = 0
    var is_current: Int = 0
    var org_id: Int = 0
}

class OriganizationModel:BaseModel {
    var id:Int = 0
    var name:String = ""
    var avatar:String = ""
}

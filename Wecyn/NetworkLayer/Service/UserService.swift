//
//  RegistService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation
import Moya
class UserService {
    ///  邮箱发送验证码
    static func emailSendVertificationCode(email:String) -> Observable<ResponseStatus>{
        let target = MultiTarget(UserApi.emailSendeVerificationCode(email: email))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 邮箱验证
    static func emailVerification(email:String,code:String) -> Observable<TokenModel> {
        let target = MultiTarget(UserApi.emailVerification(email: email, code: code))
        return APIProvider.rx.request(target).asObservable().mapObject(TokenModel.self)
    }
    
    /// 国家信息
    static func getAllCountry() -> Observable<[CountryModel]> {
        let target = UserApi.getCountryList
        return UserProvider.rx.cache.request(target).asObservable().mapArray(CountryModel.self)
    }
    
    /// 城市信息
    static func getAllCity(by countryID:Int) -> Observable<[CityModel]> {
        let target = UserApi.getCityList(countryId: countryID)
        return UserProvider.rx.cache.request(target).asObservable().mapArray(CityModel.self)
//        let target = MultiTarget(RegistApi.getCityList(countryId: countryID))
//        return APIProvider.rx.request(target).asObservable().mapArray(CityModel.self)
    }
    
    
    /// 上传头像
    /// - Parameter photo: base64字符串
    /// - Returns: ResponseStatus
    static func updateAvatar(photo:String) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.uploadAvatar(photo: photo))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 注册
    static func signup(model:RegistRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(UserApi.signup(model: model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 登录
    static func signin(username:String,password:String) -> Observable<TokenModel> {
        let target = MultiTarget(UserApi.signin(username: username, password: password))
        return APIProvider.rx.request(target).asObservable().mapObject(TokenModel.self)
    }
}

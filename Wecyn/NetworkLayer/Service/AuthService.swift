//
//  RegistService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation
import Moya
class AuthService {
    ///  邮箱发送验证码
    static func emailSendVertificationCode(email:String) -> Observable<ResponseStatus>{
        let target = MultiTarget(AuthApi.emailSendeVerificationCode(email: email))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 邮箱验证
    static func emailVerification(email:String,code:String) -> Observable<TokenModel> {
        let target = MultiTarget(AuthApi.emailVerification(email: email, code: code))
        return APIProvider.rx.request(target).asObservable().mapObject(TokenModel.self)
    }
    
    /// 国家信息
    static func getAllCountry() -> Observable<[CountryModel]> {
        let target = AuthApi.getCountryList
        return UserProvider.rx.cache.request(target).asObservable().mapArray(CountryModel.self)
//        let target = MultiTarget(AuthApi.getCountryList)
//        return APIProvider.rx.request(target).asObservable().mapArray(CountryModel.self)
    }
    
    /// 城市信息
    static func getAllCity(by countryID:Int) -> Observable<[CityModel]> {
        let target = MultiTarget(AuthApi.getCityList(countryId: countryID))
        return APIProvider.rx.request(target).asObservable().mapArray(CityModel.self)
    }
    
    /// 注册
    static func signup(model:RegistRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(AuthApi.signup(model: model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 登录
    static func signin(username:String,password:String) -> Observable<TokenModel> {
        let target = MultiTarget(AuthApi.signin(username: username, password: password))
        return APIProvider.rx.request(target).asObservable().mapObject(TokenModel.self)
    }
}

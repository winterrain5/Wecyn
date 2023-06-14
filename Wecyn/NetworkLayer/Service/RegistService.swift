//
//  RegistService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import Foundation
import Moya
class RegistService {
    ///  邮箱发送验证码
    static func emailSendVertificationCode(email:String) -> Observable<ResponseStatus>{
        let target = MultiTarget(RegistApi.emailSendeVerificationCode(email: email))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 国家信息
    static func getAllCountry() -> Observable<[CountryModel]> {
        let target = RegistApi.getCountryList
        return RegistProvider.rx.cache.request(target).asObservable().mapArray(CountryModel.self)
    }
    
    /// 城市信息
    static func getAllCity(by countryID:Int) -> Observable<[CityModel]> {
//        let target = RegistApi.getCityList(countryId: countryID)
//        return RegistProvider.rx.cache.request(target).asObservable().mapArray(CityModel.self)
        let target = MultiTarget(RegistApi.getCityList(countryId: countryID))
        return APIProvider.rx.request(target).asObservable().mapArray(CityModel.self)
    }
}

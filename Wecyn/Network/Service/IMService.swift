//
//  IMService.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/1.
//

import Foundation
import OpenIMSDK
import RxSwift
class IMService {
    static func imSDKInit() -> Observable<ResponseStatus>{
        return Observable.create { observable -> Disposable in
            let status = ResponseStatus()
            let config = OIMInitConfig()
            OIMManager.manager.initSDK(with: config) {
                print("connecting")
            } onConnectFailure: { code, message in
                observable.onError(APIError.requestError(code: code, message: message ?? ""))
            } onConnectSuccess: {
                status.success = 1
                observable.onNext(status)
                observable.onCompleted()
            } onKickedOffline: {
                observable.onError(APIError.requestError(code: -999, message: "KickedOffline"))
            } onUserTokenExpired: {
                observable.onError(APIError.requestError(code: -998, message: "UserTokenExpired"))
            }
            return Disposables.create()
        }
        
    }
    
    static func imLogin(uid:String,token:String) -> Observable<String?> {
        return Observable.create { observable -> Disposable in
            OIMManager.manager.login(uid, token: token) { data in
                observable.onNext(data)
                observable.onCompleted()
            } onFailure: { code, message in
                observable.onError(APIError.requestError(code: code, message: message ?? "Login Failure"))
            }
            return Disposables.create()
        }
    }
}



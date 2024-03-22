//
//  IMManager.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/21.
//

import Foundation
import OpenIMSDK
let IMLoggerLabel = "OpenIMSDK"
let IMObjectStorage = "OpenIMStorage"
class IMManager {
    static let shared = IMManager()
    
    func config() {
        
        let config = OIMInitConfig()
        config.apiAddr = "http://27.54.57.6:10002"
        config.wsAddr = "ws://27.54.57.6:10001"
        
        OIMManager.manager.initSDK(with: config) {
            Logger.debug("im onConnecting",label: IMLoggerLabel)
        } onConnectFailure: { code, string in
            Logger.error("code:\(code),message:\(string ?? "")", label: IMLoggerLabel)
        } onConnectSuccess: {
            Logger.debug("im onConnectSuccess",label: IMLoggerLabel)
        } onKickedOffline: {
            Logger.debug("im onKickedOffline",label: IMLoggerLabel)
        } onUserTokenExpired: {
            Logger.debug("im onUserTokenExpired",label: IMLoggerLabel)
        }

    }
    
    func login(success:@escaping ()->(),error:@escaping (Error) -> ()) {
        let model = UserDefaults.sk.get(of: TokenModel.self, for: TokenModel.className)
        let uid = model?.user_id ?? 0
        let token = model?.im_token ?? ""
        if token.isEmpty {
            success()
            return
        }
        OIMManager.manager.login(uid.string, token: token) { data in
            Logger.info("login success data:\(data ?? "")", label: IMLoggerLabel)
            success()
        } onFailure: { code, message in
            error(APIError.requestError(code: code, message: message ?? ""))
            Logger.error("code:\(code),message:\(message ?? "")", label: IMLoggerLabel)
        }

    }
    
    func logout(success:@escaping ()->(),error:@escaping (Error) -> ()) {
        OIMManager.manager.logoutWith { message in
            Logger.info("logout data:\(message ?? "")", label: IMLoggerLabel)
            success()
        } onFailure: { code, message in
            error(APIError.requestError(code: code, message: message ?? ""))
            Logger.error("code:\(code),message:\(message ?? "")", label: IMLoggerLabel)
        }

    }
    
    var currentSender:IMUser {
        let model = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
        return IMUser(senderId: model?.id ?? "", displayName: model?.full_name ?? "")
    }
}

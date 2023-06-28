//
//  FriendService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/20.
//

import UIKit

class FriendService {
    
    
    /// 添加好友
    /// - Parameters:
    ///   - userId: 被添加用户的user_id
    ///   - reason: 申请理由
    ///   - remark: 备注
    /// - Returns: ResponseStatus
    static func addFriend(userId: Int, reason: String? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(FriendApi.addFriend(userId, reason))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 好友审核（同意/拒绝好友请求)
    /// - Parameters:
    ///   - from_user_id: 申请者的user_id
    ///   - audit_status: 审核状态。默认0。0 待审核，1 已通过，2 未通过
    ///   - is_delete: 删除好友请求信息。默认0。0 不删除，1 删除
    /// - Returns: ResponseStatus
    static func auditFriend(from_user_id: Int, audit_status: Int = 0, is_delete: Int? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(FriendApi.auditFriend(from_user_id, audit_status, is_delete))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 删除好友
    /// - Parameter friend_id: 好友的user_id
    /// - Returns: ResponseStatus
    static func deleteFriend(friend_id: Int) -> Observable<ResponseStatus> {
        let target = MultiTarget(FriendApi.deleteFriend(friend_id))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 好友列表
    /// - Returns: FriendListModel
    static func friendList() -> Observable<[FriendListModel]> {
        let target = MultiTarget(FriendApi.friendList)
        return APIProvider.rx.request(target).asObservable().mapArray(FriendListModel.self)
    }
    
    /// 获取收到的好友申请列表
    /// - Returns: FriendRecieveModel
    static func friendRecieveList() -> Observable<[FriendRecieveModel]> {
        let target = MultiTarget(FriendApi.friendReceiveList)
        return APIProvider.rx.request(target).asObservable().mapArray(FriendRecieveModel.self)
    }
    
    /// 获取发出的好友申请列表
    /// - Returns: FriendRecieveModel
    static func friendSendList() -> Observable<[FriendSendModel]> {
        let target = MultiTarget(FriendApi.friendSendList)
        return APIProvider.rx.request(target).asObservable().mapArray(FriendSendModel.self)
    }
    
    
    /// 获取好友详情
    /// - Parameter friendID: 好友ID
    /// - Returns: FriendUserInfoModel
    static func friendUserInfo(_ friendID: Int) -> Observable<FriendUserInfoModel> {
        let target = MultiTarget(FriendApi.friendUserInfo(friendID))
        return APIProvider.rx.request(target).asObservable().mapObject(FriendUserInfoModel.self)
    }
    
    
    /// 搜索用户
    /// - Parameter keyword: 默认空
    /// - Returns: FriendUserInfoModel
    static func searchUserList(_ keyword: String = "") -> Observable<[FriendUserInfoModel]> {
        let target = MultiTarget(FriendApi.userSearchList(keyword))
        return APIProvider.rx.request(target).asObservable().mapArray(FriendUserInfoModel.self)
    }
    
}

class FriendListModel: BaseModel {
    /*
     "id": int # 好友的user_id
     "fn": string # 好友的first_name
     "ln": string # 好友的last_name
     "avt": int # 用户头像
     */
    var id: Int = 0
    var fn:  String = ""
    var ln: String = ""
    var avt: String = ""
    var isSelected: Bool = false
}

class FriendRecieveModel: BaseModel {
    /*
     "from_user_id": int # 申请者的user_id
     "first_name": string # 申请者的first_name
     "last_name": string # 申请者的last_name
     "avatar": string # 头像
     "reason": string # 申请理由
     */
    var from_user_id: Int = 0
    var first_name: String = ""
    var last_name: String = ""
    var avatar = ""
    var reason = ""
    
}

class FriendSendModel: BaseModel {
    /*
     "to_user_id": int # 被添加用户的user_id
     "first_name": string # 被添加用户的first_name
     "last_name": string # 被添加用户的last_name
     "avatar": string # 头像
     "apply_time": %Y-%m-%d %H:%M:%S # 申请时间
     "reason": string # 申请理由
     "audit_status": int # 审核状态。0 待审核，1 已通过，2 未通过
     "operate_time": %Y-%m-%d %H:%M:%S # 操作时间
     */
    
    var to_user_id: Int = 0
    var first_name: String = ""
    var last_name: String = ""
    var avatar = ""
    var reason = ""
    var apply_time: String =  ""
    var audit_status:  Int = 0
    var operate_time = ""
}

class FriendUserInfoModel: BaseModel {
    /*
     "id": int # 用户的user_id
     "wid": string # Wecyn ID。类似QQ号和微信号
     */
    var id: Int = 0
    var first_name: String = ""
    var last_name: String = ""
    var avatar = ""
    var wid = ""
}

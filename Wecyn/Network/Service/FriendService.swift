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
    /// - Parameter id: id所属的好友列表
    /// - Returns: FriendListModel
    static func friendList(id:Int? = nil) -> Observable<[FriendListModel]> {
        let target = MultiTarget(FriendApi.friendList(id))
        return APIProvider.rx.request(target).asObservable().mapArray(FriendListModel.self)
//                return FriendProvider.rx.cache.request(FriendApi.friendList(id)).asObservable().mapArray(FriendListModel.self)
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
    /// - Returns: FriendListModel
    static func searchUserList(keyword: String = "") -> Observable<[FriendUserInfoModel]> {
        let target = MultiTarget(FriendApi.userSearchList(keyword))
        return APIProvider.rx.request(target).asObservable().mapArray(FriendUserInfoModel.self)
    }
    
    
    /// 添加分组
    /// - Parameters:
    ///   - name: 分组名称
    ///   - friends: 好友id
    /// - Returns: ResponseStatus
    static func addGroup(name:String,friends:[Int] = []) -> Observable<ResponseStatus> {
        let target = MultiTarget(FriendApi.addGroup(name, friends))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 删除分组
    /// - Parameter id: 分组ID
    /// - Returns: ResponseStatus
    static func deleteGroup(id:Int) ->  Observable<ResponseStatus> {
        let target = MultiTarget(FriendApi.deleteGroup(id))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 移动好友到分组
    /// - Parameters:
    ///   - id: 分组ID
    ///   - friendId: 好友ID
    /// - Returns: ResponseStatus
    static func friendToGroup(id:Int,friendIds:[Int]) -> Observable<ResponseStatus> {
        let target = MultiTarget(FriendApi.friendToGroup(id, friendIds))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 查询分组
    /// - Parameter id: 分组ID
    /// - Returns: GroupListModel 数组
    static func selectGroup(id:Int? = nil) -> Observable<[GroupListModel]> {
        let target = MultiTarget(FriendApi.selectGroup(id))
        return APIProvider.rx.request(target).asObservable().mapArray(GroupListModel.self)
    }
    
    
    /// 更新分组
    /// - Parameter model: GroupUpdateRequestModel
    /// - Returns: ResponseStatus
    static func updateGroup(model: GroupUpdateRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(FriendApi.updateGroup(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
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
    var first_name: String = ""
    var last_name: String = ""
    var avatar = ""
    var group_id: Int = 0
    var full_name: String {
        get {
            String.fullName(first: first_name, last: last_name)
        }
        set {
            first_name =  String(newValue.split(separator: " ").first ?? "")
            last_name = String(newValue.split(separator: " ").last ?? "")
        }
    }
    
    override func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.first_name <-- "fn"
        mapper <<<
            self.last_name <-- "ln"
        mapper <<<
            self.avatar <-- "avt"
        mapper <<<
            self.group_id <-- "gid"
    }
    
    // 本地字段
    var isSelected: Bool = false
    var status = 0
    var wid = ""
}

class FriendUserInfoModel: BaseModel {
    /*
     "id": int # 用户的user_id
     "wid": string # Wecyn ID。类似QQ号和微信号
     */
    var id: Int = 0
    var first_name: String = ""
    var last_name: String = ""
    var full_name: String {
        String.fullName(first: first_name, last: last_name)
    }
    var avatar = ""
    var wid = ""
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
    var full_name: String {
        String.fullName(first: first_name, last: last_name)
    }
    var avatar = ""
    var reason = ""
    
    var isAgree:Bool = false
    
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
    var full_name: String {
        String.fullName(first: first_name, last: last_name)
    }
    var avatar = ""
    var reason = ""
    var apply_time: String =  ""
    var audit_status:  Int = 0
    var operate_time = ""
}

class GroupListModel: BaseModel {
    /*
     "id": int # group_id
     "name": string # 组名
     "count": int # 好友数量
     */
    var id: Int = 0
    var name = ""
    var count = 0
    var isExpand = false
}

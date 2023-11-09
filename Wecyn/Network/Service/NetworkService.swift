//
//  FriendService.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/20.
//

import UIKit

class NetworkService {
    
    
    /// 添加好友
    /// - Parameters:
    ///   - userId: 被添加用户的user_id
    ///   - reason: 申请理由
    ///   - remark: 备注
    /// - Returns: ResponseStatus
    static func addFriend(userId: Int, reason: String? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.addFriend(userId, reason))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 好友审核（同意/拒绝好友请求)
    /// - Parameters:
    ///   - from_user_id: 申请者的user_id
    ///   - audit_status: 审核状态。默认0。0 待审核，1 已通过，2 未通过
    ///   - is_delete: 删除好友请求信息。默认0。0 不删除，1 删除
    /// - Returns: ResponseStatus
    static func auditFriend(from_user_id: Int, audit_status: Int = 0, is_delete: Int? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.auditFriend(from_user_id, audit_status, is_delete))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 删除好友
    /// - Parameter friend_id: 好友的user_id
    /// - Returns: ResponseStatus
    static func deleteFriend(friend_id: Int) -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.deleteFriend(friend_id))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 好友列表
    /// - Parameter id: id所属的好友列表
    /// - Returns: FriendListModel
    static func friendList(id:Int? = nil) -> Observable<[FriendListModel]> {
        let target = MultiTarget(NetworkApi.friendList(id))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(FriendListModel.self)
        //                return FriendProvider.rx.cache.request(FriendApi.friendList(id)).asObservable().mapArray(FriendListModel.self)
    }
    
    /// 获取收到的好友申请列表
    /// - Returns: FriendRecieveModel
    static func friendRecieveList() -> Observable<[FriendRecieveModel]> {
        let target = MultiTarget(NetworkApi.friendReceiveList)
        return APIProvider.rx.request(target).asObservable().mapObjectArray(FriendRecieveModel.self)
    }
    
    /// 获取发出的好友申请列表
    /// - Returns: FriendRecieveModel
    static func friendSendList() -> Observable<[FriendSendModel]> {
        let target = MultiTarget(NetworkApi.friendSendList)
        return APIProvider.rx.request(target).asObservable().mapObjectArray(FriendSendModel.self)
    }
    
    
    /// 获取好友详情
    /// - Parameter friendID: 好友ID
    /// - Returns: FriendUserInfoModel
    static func friendUserInfo(_ friendID: Int) -> Observable<FriendUserInfoModel> {
        let target = MultiTarget(NetworkApi.friendUserInfo(friendID))
        return APIProvider.rx.request(target).asObservable().mapObject(FriendUserInfoModel.self)
    }
    
    
    /// 搜索用户
    /// - Parameter keyword: 默认空
    /// - Returns: FriendListModel
    static func searchUserList(keyword: String = "") -> Observable<[FriendUserInfoModel]> {
        let target = MultiTarget(NetworkApi.userSearchList(keyword))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(FriendUserInfoModel.self)
    }
    
    
    /// 添加分组
    /// - Parameters:
    ///   - name: 分组名称
    ///   - friends: 好友id
    /// - Returns: ResponseStatus
    static func addGroup(name:String,friends:[Int] = []) -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.addGroup(name, friends))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 删除分组
    /// - Parameter id: 分组ID
    /// - Returns: ResponseStatus
    static func deleteGroup(id:Int) ->  Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.deleteGroup(id))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 移动好友到分组
    /// - Parameters:
    ///   - id: 分组ID
    ///   - friendId: 好友ID
    /// - Returns: ResponseStatus
    static func friendToGroup(id:Int,friendIds:[Int]) -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.friendToGroup(id, friendIds))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 查询分组
    /// - Parameter id: 分组ID
    /// - Returns: GroupListModel 数组
    static func selectGroup(id:Int? = nil) -> Observable<[GroupListModel]> {
        let target = MultiTarget(NetworkApi.selectGroup(id))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(GroupListModel.self)
    }
    
    
    /// 更新分组
    /// - Parameter model: GroupUpdateRequestModel
    /// - Returns: ResponseStatus
    static func updateGroup(model: GroupUpdateRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.updateGroup(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 朋友的名片
    /// - Parameter id: 好友ID
    /// - Returns:UserInfoModel
    static func friendNameCard(uuid: String) -> Observable<UserInfoModel> {
        let target = MultiTarget(NetworkApi.friendNameCard(uuid))
        return APIProvider.rx.request(target).asObservable().mapObject(UserInfoModel.self)
    }
    
    
    /// 关注好友
    /// - Parameter userId: 用户id
    /// - Returns: ResponseStatus
    static func addFollow(userId:Int)  -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.addFollow(userId))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 取消关注好友
    /// - Parameter userId: 用户id
    /// - Returns: ResponseStatus
    static func cancelFollow(userId:Int)  -> Observable<ResponseStatus> {
        let target = MultiTarget(NetworkApi.cancelFollow(userId))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 关注列表
    /// - Parameter type: 1 following 2 follower
    /// - Returns: FriendListModel
    static func followedList(type:Int,userId:Int = 0,page:Int = 1,pageSize:Int = 10,keyword:String = "") -> Observable<[FriendFollowModel]> {
        let target = MultiTarget(NetworkApi.followedList(type,userId,page,pageSize,keyword))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(FriendFollowModel.self,designatedPath: "items")
    }
    
    
    /// 添加备注
    /// - Parameters:
    ///   - id: 用户id
    ///   - remark: 备注
    /// - Returns: ResponseStatus
    static func updateRemark(id:Int,remark:String) -> Observable<ResponseStatus>  {
        let target = MultiTarget(NetworkApi.updateRemark(id, remark))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 扫描实体名片
    /// - Parameter photo: base64
    /// - Returns: ScanCardModel
    static func scanCard(photo:String) -> Observable<ScanCardModel> {
        let target = MultiTarget(NetworkApi.scanCard(photo))
        return APIProvider.rx.request(target).asObservable().mapObject(ScanCardModel.self)
    }
    
}

class ScanCardModel:BaseModel  {
    var url: String = ""
    var postal_code: String = ""
    var adr_work: String = ""
    var tel_work: String = ""
    var title: String = ""
    var email: String = ""
    var other: [String] = []
    var org_name: String = ""
    var name: String = ""
    var tel_cell: String = ""
    
}

class FriendFollowModel: BaseModel {
    var id: Int = 0
    var first_name: String = ""
    var headline:  String = ""
    var last_name: String = ""
    var avatar = ""
    var is_following:Bool = false
    var full_name: String {
        String.fullName(first: first_name, last: last_name)
    }
    var is_my_follow:Bool = false
}

class FriendListModel: BaseModel {
    /*
     "id": int # 好友的user_id
     "fn": string # 好友的first_name
     "ln": string # 好友的last_name
     "avt": int # 用户头像
     */
    var uuid:  String = ""
    var id: Int = 0
    var first_name: String = ""
    var last_name: String = ""
    var avatar = ""
    var avatar_url: URL? {
        return URL(string: avatar)
    }
    var remark = ""
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
    
    var is_following:Bool = false
    
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
     "status": 1 没关系，2 好友关系，3 已申请好友，4 被申请好友
     */
    var id: Int = 0
    var first_name: String = ""
    var last_name: String = ""
    var full_name: String {
        String.fullName(first: first_name, last: last_name)
    }
    /// "friend_status" int # 好友状态。1 没关系，2 好友关系，3 已申请好友，4 被申请好友
    var friend_status: Int = 0
    var avatar = ""
    var cover = ""
    var wid = ""
    var remark = ""
    var is_following:Bool = false
    
    var follower_count:Int = 0
    var following_count:Int = 0
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

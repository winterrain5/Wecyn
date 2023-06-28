//
//  FriendApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/20.
//

import Foundation
import Moya
enum FriendApi  {
    case addFriend(_ userId: Int,_ reason: String? = nil)
    case auditFriend(_ from_user_id: Int,_ audit_status: Int = 0,_ is_delete: Int? = 0)
    case deleteFriend(_ friendId: Int)
    case friendList
    case friendReceiveList
    case friendSendList
    case friendUserInfo(_ friendId: Int)
    case userSearchList(_ keyword: String = "")
}

extension FriendApi:TargetType {
    var path: String {
        switch self {
        case .addFriend:
            return "/api/network/addFriend/"
        case .auditFriend:
            return "/api/network/auditFriend/"
        case .deleteFriend:
            return "/api/network/deleteFriend/"
        case .friendList:
            return "/api/network/friendList/"
        case .friendReceiveList:
            return "/api/network/friendReceiveList/"
        case .friendSendList:
            return "/api/network/friendSendList/"
        case .friendUserInfo:
            return "/api/network/networkUserInfo/"
        case .userSearchList:
            return "/api/network/searchList/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addFriend, .auditFriend, .deleteFriend:
            return Moya.Method.post
        default:
            return Moya.Method.get
        }
    }
    
    var task: Task {
        switch self {
        case .addFriend(let userId, let reason):
            
            return requestNoneNilParameters(["to_user_id":userId,
                                             "reason":reason])
            
        case .auditFriend(let from_user_id, let audit_status, let is_delete):
            
            return requestNoneNilParameters(["from_user_id":from_user_id,
                                             "audit_status":audit_status,
                                             "is_delete": is_delete])
            
        case .deleteFriend(let friendId):
            
            return requestNoneNilParameters(["id":friendId])
        
        case .friendList, .friendReceiveList, .friendSendList:
            return .requestPlain
        case .friendUserInfo(let friendId):
            return requestURLParameters(["id":friendId])
            
        case .userSearchList(let keyword):
            return requestURLParameters(["keyword":keyword])
        }
        
    }
}

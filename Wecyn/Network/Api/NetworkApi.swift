//
//  FriendApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/20.
//

import Foundation
import Moya
import RxMoyaCache
let NetworkProvider = MoyaProvider<NetworkApi>()
enum NetworkApi  {
    case addFriend(_ userId: Int,_ reason: String? = nil)
    case auditFriend(_ from_user_id: Int,_ audit_status: Int = 0,_ is_delete: Int? = 0)
    case deleteFriend(_ friendId: Int)
    case friendList(_ id:Int? = nil)
    case friendReceiveList
    case friendSendList
    case friendUserInfo(_ friendId: Int)
    case userSearchList(_ keyword: String = "")
    case addGroup(_ name:String, _ friends:[Int] = [])
    case deleteGroup(_ id:Int)
    case friendToGroup(_ id:Int, _ friendIds: [Int])
    case selectGroup(_ id:Int? = nil)
    case updateGroup(_ model:GroupUpdateRequestModel)
    case friendNameCard(_  uuid:String)
    case addFollow(_ userId:Int)
    case cancelFollow(_ userId:Int)
    case followedList(_ type:Int,_ userId:Int,_ page:Int,_ pageSize:Int,_ keyword:String)
    case updateRemark(_ id:Int,_ remark:String)
    case scanCard(_ photo:String,_ lang:Int)
}

extension NetworkApi:TargetType, Cacheable {
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
        case .addGroup:
            return "/api/network/addGroup/"
        case .deleteGroup:
            return "/api/network/deleteGroup/"
        case .friendToGroup:
            return "/api/network/friendToGroup/"
        case .selectGroup:
            return "/api/network/selectGroup/"
        case .updateGroup:
            return "/api/network/updateGroup/"
        case .friendNameCard:
            return "/api/network/cardInfo/"
        case .addFollow:
            return "/api/network/follow/"
        case  .cancelFollow:
            return "/api/network/unfollow/"
        case .followedList:
            return "/api/network/followList/"
        case .updateRemark:
            return "/api/network/updateRemark/"
        case  .scanCard:
            return "/api/network/scanCard/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addFriend,
             .auditFriend,
             .deleteFriend,
             .addGroup,
             .deleteGroup,
             .friendToGroup,
             .addFollow,
             .cancelFollow,
             .updateRemark,
             .scanCard:
            return Moya.Method.post
        case .updateGroup:
            return Moya.Method.put
        default:
            return Moya.Method.get
        }
    }
    
    var task: Task {
        switch self {
        case .addFriend(let userId, let reason):
            
            return requestParametersByPost(["to_user_id":userId,
                                             "reason":reason])
            
        case .auditFriend(let from_user_id, let audit_status, let is_delete):
            
            return requestParametersByPost(["from_user_id":from_user_id,
                                             "audit_status":audit_status,
                                             "is_delete": is_delete])
            
        case .deleteFriend(let friendId):
            
            return requestParametersByPost(["id":friendId])
        
        case .friendReceiveList, .friendSendList:
            return .requestPlain
        case .friendList(let id):
            return requestParametersByGet(["current_user_id":id])
        case .friendUserInfo(let friendId):
            return requestParametersByGet(["id":friendId])
        case .userSearchList(let keyword):
            return requestParametersByGet(["keyword":keyword])
        case .addGroup(let name, let friends):
            return requestParametersByPost(["name":name,"friends":friends])
        case .deleteGroup(let id):
            return requestParametersByPost(["id":id])
        case .friendToGroup(let id, let friendIds):
            return requestParametersByPost(["id":id,"friends":friendIds])
        case .selectGroup(let id):
            return requestParametersByGet(["id":id])
        case .updateGroup(let model):
            return requestToTaskByPost(model)
        case .friendNameCard(let uuid):
            return requestParametersByGet(["uuid":uuid])
        case .addFollow(let userId):
            return requestParametersByPost(["user_id":userId])
        case .cancelFollow(let userId):
            return requestParametersByPost(["user_id":userId])
        case .followedList(let type,let userId,let page,let pageSize,let keyword):
            return requestParametersByGet(["type":type,"user_id":userId,"page":page,"pagesize":pageSize,"keyword":keyword])
        case .updateRemark(let id, let remark):
            return requestParametersByPost(["user_id":id,"remark":remark])
        case .scanCard(let photo,let lang):
            return requestParametersByPost(["photo":photo,"lang":lang])
        }
        
    }
}

//
//  UserApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import Foundation
import Moya
enum UserApi {
    case uploadAvatar(photo:String)
    case userInfo
    case updateUserInfo(model:UpdateUserInfoRequestModel)
    case uploadCover(photo:String)
    case addExperience(_ model:AddUserExperienceRequestModel)
    case deleteExperience(_ id:Int,_ type:Int)
    case updateExperience(_ model:AddUserExperienceRequestModel)
    case experienceInfo(_ id:Int,_ type:Int)
    case experienceList(_ type:Int,_ userId:Int? = nil)
    case organizationList(_ isEdu:Int = 0,_ keyword:String)
    case applyForCertification(_ id:Int,_ type:Int,_ remark:String)
}

extension UserApi: TargetType {
    var path: String {
        switch self {
        case .uploadAvatar:
            return "/api/user/uploadAvatar/"
        case .userInfo:
            return "/api/user/userInfo/"
        case .updateUserInfo:
            return "/api/user/updateUserInfo/"
        case .uploadCover:
            return "/api/user/uploadCover/"
        case .addExperience:
            return "/api/user/addExperience/"
        case .deleteExperience:
            return "/api/user/deleteExperience/"
        case .experienceInfo:
            return "/api/user/experienceInfo/"
        case .experienceList:
            return "/api/user/experienceList/"
        case .organizationList:
            return "/api/org/searchList/"
        case .updateExperience:
            return "/api/user/updateExperience/"
        case .applyForCertification:
            return "/api/user/applyCertification/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .userInfo,.experienceInfo,.experienceList,.organizationList:
            return Moya.Method.get
        case .updateUserInfo,.updateExperience:
            return Moya.Method.put
        default:
            return Moya.Method.post
        }
    }
    
    var task: Task {
        switch self {
        case .uploadAvatar(let photo):
            return requestParametersByPost(["photo":photo])
        case .userInfo:
            return .requestPlain
        case .updateUserInfo(let model):
            return requestToTaskByPost(model)
        case .uploadCover(let photo):
            return requestParametersByPost(["photo":photo])
        case .addExperience(let model):
            return requestToTaskByPost(model)
        case .deleteExperience(let id, let type):
            return requestParametersByPost(["id":id,"exp_type":type])
        case .experienceInfo(let id, let type):
            return requestParametersByGet(["id":id,"exp_type":type])
        case .experienceList(let type,let id):
            return requestParametersByGet(["user_id":id,"exp_type":type])
        case .organizationList(let isEdu,let keyword):
            return requestParametersByGet(["is_edu":isEdu,"keyword":keyword])
        case .updateExperience(let model):
            return requestToTaskByPost(model)
        case .applyForCertification(let id,let type,let remark):
            return requestParametersByPost(["id":id,"exp_type":type,"user_remark":remark])
            
        }
    }}

//
//  AdminApi.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import Foundation
import Moya

enum AdminApi {
    case addRole(_ orgid:Int,_ name:String,_ permission:[Int],_ remark:String? = nil)
    case deleteRole(_ id:Int,_ toId:Int? = nil)
    case roleList(_ orgid:Int,_ keyword:String? = nil)
    case updateRole(_ id:Int,_ name:String? = nil,_ permission:[Int]? = [],_ remark:String? = nil)
    
    case adminRoomList(_ orgid:Int,_ keyword:String? = nil)
    case userRoomList(_ orgid:Int,_ keyword:String? = nil)
    
    case departmentList(_ orgid:Int,_ keyword:String? = nil)
    case deleteDepartment(_ id:Int,_ toId:Int? = nil)
    case updateDepartment(_ model:AdminDepartmentAddRequestModel)
    case addDepartment(_ model:AdminDepartmentAddRequestModel)
    
    case staffList(_ orgId:Int,_ deptId:Int? = nil)
    
    case adminOrgList
    case userOrgList
}

extension AdminApi:TargetType {
    var path: String {
        switch self {
        case .userRoomList:
            return "/api/room/searchList/"
        case .adminRoomList:
            return "/api/admin/room/searchList/"
        case .addRole:
            return "/api/admin/role/addRole/"
        case .deleteRole:
            return "/api/admin/role/deleteRole/"
        case .roleList:
            return "/api/admin/role/searchList/"
        case .updateRole:
            return "/api/admin/role/updateRole/"
        case .adminOrgList:
            return "/api/admin/user-org/searchList/"
        case .userOrgList:
            return "/api/user-org/searchList/"
        case .departmentList:
            return "/api/admin/dept/searchList/"
        case .deleteDepartment:
            return "/api/admin/dept/deleteDepartment/"
        case .addDepartment:
            return "/api/admin/dept/addDepartment/"
        case .updateDepartment:
            return "/api/admin/dept/updateDepartment/"
        case .staffList:
            return "/api/admin/staff/searchList/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addRole,.deleteRole,.deleteDepartment,.addDepartment:
            return .post
        case  .updateRole,.updateDepartment:
            return .put
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .addRole(let orgid, let name, let permission,let remark):
            return requestParametersByPost(["org_id":orgid,"name":name,"permission":permission,"remark":remark])
        case .userRoomList(let orgid,let keyword),.adminRoomList(let orgid,let keyword):
            return requestParametersByGet(["org_id":orgid,"keyword":keyword])
        case .deleteRole(let id,let toId):
            return requestParametersByPost(["id":id,"to_id":toId])
        case .roleList(let orgid,let keyword):
            return requestParametersByGet(["org_id":orgid,"keyword":keyword])
        case .updateRole(let id, let name, let permission,let remark):
            return requestParametersByPost(["id":id,"name":name,"permission":permission,"remark":remark])
        case .adminOrgList,.userOrgList:
            return .requestPlain
        case .departmentList(let orgid,let keyword):
            return requestParametersByGet(["org_id":orgid,"keyword":keyword])
        case .deleteDepartment(let id,let toId):
            return requestParametersByPost(["id":id,"to_id":toId])
        case .updateDepartment(let model):
            return requestToTaskByPost(model)
        case .addDepartment(let model):
            return requestToTaskByPost(model)
        case .staffList(let orgId,let deptId):
            return requestParametersByGet(["org_id":orgId,"dept_id":deptId])
        }
    }
}

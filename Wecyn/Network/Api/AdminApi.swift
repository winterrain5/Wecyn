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

    case addRoom(_ model:AdminAddRoomRequestModel)
    case updateRoom(_ model:AdminAddRoomRequestModel)
    case deleteRoom(_ id:Int)
    
    case departmentList(_ orgid:Int,_ keyword:String? = nil)
    case deleteDepartment(_ id:Int,_ toId:Int? = nil)
    case updateDepartment(_ model:AdminDepartmentAddRequestModel)
    case addDepartment(_ model:AdminDepartmentAddRequestModel)
    
    case staffList(_ orgId:Int,_ deptId:Int? = nil)
    case pendingCertificateStaff(_ orgId:Int,_ keyword:String? = nil)
    case staffCertification(_ model:AdminCertificatStaffRequestModel)
    case updateStaff(_ model:AdminUpdateStaffRequestModel)
    case updateStaffExp(_ model:AdminUpdateStaffExpRequestModel)
    case deleteStaffExp(_ id:Int)
    
    case adminOrgList
    case userOrgList
}

extension AdminApi:TargetType {
    var path: String {
        switch self {
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
        case .pendingCertificateStaff:
            return "/api/admin/staff/certList/"
        case .staffCertification:
            return "/api/admin/staff/staffCertification/"
        case .addRoom:
            return "/api/admin/room/addRoom/"
        case .deleteRoom:
            return "/api/admin/room/deleteRoom/"
        case .updateRoom:
            return "/api/admin/room/updateRoom/"
        case .updateStaff:
            return "/api/admin/staff/updateStaff/"
        case .updateStaffExp:
            return "/api/admin/staff/updateStaffExperience/"
        case .deleteStaffExp:
            return "/api/admin/staff/deleteStaffExperience/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addRole,.deleteRole,.deleteDepartment,.addDepartment,.staffCertification,.addRoom,.deleteRoom,.deleteStaffExp:
            return .post
        case  .updateRole,.updateDepartment,.updateRoom,.updateStaff,.updateStaffExp:
            return .put
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .addRole(let orgid, let name, let permission,let remark):
            return requestParametersByPost(["org_id":orgid,"name":name,"permission":permission,"remark":remark])
        case .adminRoomList(let orgid,let keyword):
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
        case .pendingCertificateStaff(let orgId,let keyword):
            return requestParametersByGet(["org_id":orgId,"keyword":keyword])
        case .staffCertification(let model):
            return requestToTaskByPost(model)
        case .addRoom(let model):
            return requestToTaskByPost(model)
        case .deleteRoom(let id):
            return requestParametersByPost(["id":id])
        case .updateRoom(let model):
            return requestToTaskByPost(model)
        case .updateStaff(let model):
            return requestToTaskByPost(model)
        case .updateStaffExp(let model):
            return requestToTaskByPost(model)
        case .deleteStaffExp(let id):
            return requestParametersByPost(["id":id])
        }
    }
}

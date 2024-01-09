//
//  AdminService.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import Foundation
import RxSwift
import Moya
///
class AdminService {
    
    
    
    /// 角色列表
    /// - Parameters:
    ///   - orgId: org_id
    ///   - keyword: 关键词
    /// - Returns:
    static func roleList(orgId:Int,keyword:String = "") -> Observable<[AdminRoleItemModel]> {
        let target = MultiTarget(AdminApi.roleList(orgId,keyword))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AdminRoleItemModel.self)
    }
    
    
    /// 删除角色
    /// - Parameters:
    ///   - id: 角色ID
    ///   - toId: 分配到另外一个角色的ID
    /// - Returns:
    static func deleteRole(id:Int,toId:Int? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.deleteRole(id,toId))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 添加角色
    /// - Parameters:
    ///   - orgid: 组织ID
    ///   - name: 角色名称
    ///   - permission: 权限
    ///   - remark: 备注
    /// - Returns:
    static func addRole(orgid:Int,name:String,permission:[Int],remark:String? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.addRole(orgid, name, permission,remark))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    /// 更新角色
    /// - Parameters:
    ///   - id: 角色ID
    ///   - name: 角色名称
    ///   - permission: 权限
    ///   - remark: 备注
    /// - Returns:
    static func updateRole(id:Int,name:String,permission:[Int],remark:String? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.updateRole(id, name, permission,remark))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 部门列表
    /// - Parameters:
    ///   - orgId: 组织ID
    ///   - keyword: 关键词
    /// - Returns:
    static func departmentList(orgId:Int,keyword:String = "") -> Observable<Array<Dictionary<String, Any>>> {
        let target = MultiTarget(AdminApi.departmentList(orgId,keyword))
        return APIProvider.rx.request(target).asObservable().mapArray(Dictionary<String, Any>.self)
    }
    
    
    /// 添加部门
    /// - Parameter model:AdminDepartmentAddRequestModel
    /// - Returns:
    static func addDepartment(model:AdminDepartmentAddRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.addDepartment(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 更新部门
    /// - Parameter model: AdminDepartmentAddRequestModel
    /// - Returns:
    static func updateDepartment(model:AdminDepartmentAddRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.updateDepartment(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 删除部门
    /// - Parameters:
    ///   - id:部门ID
    ///   - toId: 要分配到的部门ID
    /// - Returns:
    static func deleteDepartment(id:Int,toId:Int? = nil) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.deleteDepartment(id, toId))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// 有admin权限的组织列表
    /// - Returns:
    static func adminOrgList() -> Observable<[AdminOrgModel]> {
        let target = MultiTarget(AdminApi.adminOrgList)
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AdminOrgModel.self)
    }
    
    /// 普通用户的组织列表
    /// - Returns:
    static func userOrgList() -> Observable<[AdminOrgModel]> {
        let target = MultiTarget(AdminApi.userOrgList)
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AdminOrgModel.self)
    }
    
    
    /// 在职员工列表
    /// - Parameters:
    ///   - orgId: orgid
    ///   - deptId: deptid
    /// - Returns: AdminStaffModel
    static func staffList(orgId:Int,deptId:Int? = nil) -> Observable<[AdminStaffModel]> {
        let target = MultiTarget(AdminApi.staffList(orgId,deptId))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AdminStaffModel.self)
    }
    
    
    /// 待认证员工
    /// - Parameters:
    ///   - orgId:
    ///   - keyword:
    /// - Returns:
    static func pendingCertificateStaff(orgId:Int,keyword:String? = nil) -> Observable<[AdminNewStaffModel]> {
        let target = MultiTarget(AdminApi.pendingCertificateStaff(orgId))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AdminNewStaffModel.self)
    }
    
    
    /// 认证员工
    /// - Parameter model:
    /// - Returns:
    static func staffCertificate(model:AdminCertificatStaffRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.staffCertification(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    /// admin room list
    /// - Parameters:
    ///   - orgId:
    ///   - keyword:
    /// - Returns:
    static func adminRoomList(orgId:Int,keyword:String? = nil) -> Observable<[AdminRoomModel]> {
        let target = MultiTarget(AdminApi.adminRoomList(orgId,keyword))
        return APIProvider.rx.request(target).asObservable().mapObjectArray(AdminRoomModel.self)
    }
    
    static func deleteRoom(id:Int) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.deleteRoom(id))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    static func addRoom(model:AdminAddRoomRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.addRoom(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
    
    
    static func updateRoom(model:AdminAddRoomRequestModel) -> Observable<ResponseStatus> {
        let target = MultiTarget(AdminApi.updateRoom(model))
        return APIProvider.rx.request(target).asObservable().mapStatus()
    }
}




class AdminRoleItemModel :BaseModel {
    var id: Int = 0
    var org_id: Int = 0
    var permission: [Int]  = []
    var name: String  = ""
    var remark: String = ""
    var isSelected = false
}


class  AdminOrgModel: BaseModel {
    var role_id: Int = 0
    var id: Int = 0
    var role_name: String = ""
    var name: String = ""
    var dept_id: Int = 0
    var avatar: String = ""
}

class AdminDepartmentModel :BaseModel {
    var org_id: Int = 0
    var remark: String = ""
    var id: Int = 0
    var has_addr: Int = 0
    var children: [AdminDepartmentModel]?
    var addr: String = ""
    var name: String = ""
    var pid: Int = 0
    var isSelected = false
}


class AdminDepartmentAddRequestModel: BaseModel {
    var addr: String?
    var org_id: Int?
    var has_addr: Int?
    var name: String?
    var pid: Int?
    var remark: String?
    var id: String?
}
class AdminRoomDept :BaseModel {
    var id: Int = 0
    var name: String?
    var addr: String?
    
}

class AdminRoomModel :BaseModel {
    var id: Int = 0
    var org_id: Int = 0
    var name: String = ""
    var dept: AdminRoomDept = AdminRoomDept()
    var remark: String = ""
    
}
class AdminAddRoomRequestModel: BaseModel {
    var org_id: Int = 0
    var id: Int? = nil
    var name: String?
    var dept_id: Int = 0
    var remark: String?
    
}

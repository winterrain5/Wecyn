//
//  AdminEditStaffContainer.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/4.
//

import UIKit

class AdminEditStaffContainer: UIView {
    @IBOutlet weak var departmentTf: UITextField!
    
    @IBOutlet weak var departmentButton: UIButton!
    
    @IBOutlet weak var departmentContainer: UIView!
    @IBOutlet weak var roleTf: UITextField!
    
    @IBOutlet weak var roleButton: UIButton!
    
    @IBOutlet weak var roleContainer: UIView!
    
    @IBOutlet weak var roleDepartmentTf: UITextField!
    
    @IBOutlet weak var roleDepartmentButton: UIButton!
    
    @IBOutlet weak var roleDepartmentContainer: UIView!
    
    @IBOutlet weak var submitButton: LoadingButton!
    
    var departmentSelectModel:AdminDepartmentModel?
    var roleSelectModel:AdminRoleItemModel?
    var roleDepartmentSelectModel:AdminDepartmentModel?
    
    var requestModel = AdminUpdateStaffRequestModel()
    
    var model:AdminStaffModel? {
        didSet {
            guard let model = model else { return }
            
            requestModel.id = model.id
            requestModel.org_id = model.org_id
            requestModel.dept_id = model.dept?.id
            
            if let role = model.role {
                
                requestModel.role_id = role.id
                requestModel.role_dept_id = role.dept_id
                
                let dept = AdminDepartmentModel()
                dept.id = model.dept?.id ?? 0
                dept.name = model.dept?.name ?? ""
                self.departmentSelectModel = dept
                
                let role = AdminRoleItemModel()
                role.id = model.role?.id ?? 0
                role.name = model.role?.name ?? ""
                self.roleSelectModel = role
                
                if role.id == 1 { // role 为 super admin，不需要修改role的department
                    roleContainer.isHidden = true
                    roleDepartmentContainer.isHidden = true
                    
                } else { // 普通角色
                    roleContainer.isHidden = false
                    roleDepartmentContainer.isHidden = false
                    
                    let roleDept = AdminDepartmentModel()
                    roleDept.id = model.role?.dept_id ?? 0
                    roleDept.name = String(model.role?.dept_full_path.split(separator: ">").last ?? "")
                    self.roleDepartmentSelectModel = roleDept
                    
                    
                }
            } else { // 没有角色 normal staff ,默认显示role,当选择为其它角色时，为该角色分配部门
                roleContainer.isHidden = false
                roleDepartmentContainer.isHidden = true
                
                let role = AdminRoleItemModel()
                role.id = -1
                role.name = "Normal Staff"
                self.roleSelectModel = role
            }
            
            departmentTf.text = model.dept?.name
            roleTf.text = model.role?.name
            roleDepartmentTf.text = String(model.role?.dept_full_path.split(separator: ">").last ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        departmentButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = AdminSelectDepartmentController(selectedNode: self.departmentSelectModel)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
            vc.selectComplete = {
                self.departmentSelectModel = $0
                self.departmentTf.text = $0.name
                self.requestModel.dept_id = $0.id
            }
        }).disposed(by: rx.disposeBag)
        
        roleDepartmentButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = AdminSelectDepartmentController(selectedNode: self.roleDepartmentSelectModel)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
            vc.selectComplete = {
                self.roleDepartmentSelectModel = $0
                self.roleDepartmentTf.text = $0.name
                self.requestModel.role_dept_id = $0.id
            }
        }).disposed(by: rx.disposeBag)
        
        roleButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = AdminSelectRoleController(selectModel: self.roleSelectModel)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
            vc.selectComplete = {
                self.roleSelectModel = $0
                self.roleTf.text = $0.name
                self.requestModel.role_id = $0.id
            }
        }).disposed(by: rx.disposeBag)
        
        
        submitButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            self.submitButton.startAnimation()
            
            AdminService.updateStaff(model: self.requestModel).subscribe(onNext:{
                if $0.success == 1 {
                    Toast.showSuccess("successfully edited")
                    UIViewController.sk.getTopVC()?.dismiss(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
                } else {
                    self.submitButton.stopAnimation()
                    Toast.showError($0.message)
                }
            },onError: { e in
                self.submitButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
       
        }).disposed(by: rx.disposeBag)
        
    }
    
}

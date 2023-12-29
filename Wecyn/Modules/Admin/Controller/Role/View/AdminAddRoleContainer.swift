//
//  AdminAddRoleContainer.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/19.
//

import UIKit
import KMPlaceholderTextView
class AdminAddRoleContainer: UIView,UITextFieldDelegate {

    @IBOutlet weak var nameTf: UITextField!
    
    @IBOutlet weak var departmentSeg: UISegmentedControl!
    
    @IBOutlet weak var meetingRoomSeg: UISegmentedControl!
    
    @IBOutlet weak var staffSeg: UISegmentedControl!
    
    @IBOutlet weak var nameCardSeg: UISegmentedControl!
    
    
    @IBOutlet weak var remark: KMPlaceholderTextView!
    
    
    @IBOutlet weak var submitButton: LoadingButton!
    
    var editModel:AdminRoleItemModel? {
        didSet {
            guard let editModel = editModel else { return }
            
            nameTf.text = editModel.name
            
            if editModel.permission.count >= 1 {
                departmentSeg.selectedSegmentIndex  = editModel.permission[0]
            }
            if editModel.permission.count >= 2 {
                meetingRoomSeg.selectedSegmentIndex  = editModel.permission[1]
            }
            if editModel.permission.count >= 3 {
                staffSeg.selectedSegmentIndex  = editModel.permission[2]
            }
            if editModel.permission.count >= 4 {
                nameCardSeg.selectedSegmentIndex  = editModel.permission[3]
            }
            remark.text = editModel.remark
            self.submitButton.isEnabled = true
        }
    }
    
    var permissons:[Int] = [0,0,0,0]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameTf.rx.text.orEmpty.map({ !$0.isEmpty }).bind(to: submitButton.rx.isEnabled).disposed(by: rx.disposeBag)
        nameTf.delegate = self
        
        updatePermisson(departmentSeg, index: 0)
        updatePermisson(meetingRoomSeg, index: 1)
        updatePermisson(staffSeg, index: 2)
        updatePermisson(nameCardSeg, index: 3)
        
        submitButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            guard let `self` = self else { return }
            self.submitButton.startAnimation()
            let name = self.nameTf.text ?? ""
            let remark = self.remark.text
            if let editModel = self.editModel {
                AdminService.updateRole(id: editModel.id, name: name, permission: self.permissons,remark: remark).subscribe(onNext:{
                    if $0.success == 1 {
                        Toast.showSuccess("successfully edited")
                        UIViewController.sk.getTopVC()?.dismiss(animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
                    } else {
                        Toast.showError($0.message)
                    }
                    self.submitButton.stopAnimation()
                },onError: { e in
                    Toast.showError(e.asAPIError.errorInfo().message)
                    self.submitButton.stopAnimation()
                }).disposed(by: self.rx.disposeBag)
            } else {
                AdminService.addRole(orgid: Admin_Org_ID, name: name, permission: self.permissons,remark: remark).subscribe(onNext:{
                    if $0.success == 1 {
                        Toast.showSuccess("successfully added")
                        UIViewController.sk.getTopVC()?.dismiss(animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
                    } else {
                        Toast.showError($0.message)
                    }
                    self.submitButton.stopAnimation()
                },onError: { e in
                    Toast.showError(e.asAPIError.errorInfo().message)
                    self.submitButton.stopAnimation()
                }).disposed(by: self.rx.disposeBag)
            }
          
            
            
        }).disposed(by: rx.disposeBag)
    }
    
    func updatePermisson(_ seg:UISegmentedControl,index:Int) {
        
        seg.rx.controlEvent(.valueChanged).subscribe(onNext:{  [weak self] in
            self?.permissons[index] =  seg.selectedSegmentIndex
        }).disposed(by: rx.disposeBag)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}

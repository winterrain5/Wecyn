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
    
    var segments:[UISegmentedControl] = []
    
    @IBOutlet weak var remark: KMPlaceholderTextView!
    
    
    @IBOutlet weak var submitButton: LoadingButton!
    
    var editModel:AdminRoleItemModel? {
        didSet {
            guard let editModel = editModel else { return }
            
            nameTf.text = editModel.name
            
            editModel.permission.enumerated().forEach { [weak self] i,e in
                guard let `self` = self else { return }
                self.segments[i].selectedSegmentIndex = e
                self.permissons[i] = e
            }
            
           
            print(self.permissons)
            
            remark.text = editModel.remark
            self.submitButton.isEnabled = true
        }
    }
    
    var permissons:[Int] = [0,0,0,0]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameTf.rx.text.orEmpty.map({ !$0.isEmpty }).bind(to: submitButton.rx.isEnabled).disposed(by: rx.disposeBag)
        nameTf.delegate = self
        
        departmentSeg.rx.controlEvent(.valueChanged).subscribe(onNext:{  [weak self] in
            guard let `self` = self else { return }
            print(self.departmentSeg.selectedSegmentIndex)
            self.permissons[0] =  self.departmentSeg.selectedSegmentIndex
            
            print(self.permissons)
        }).disposed(by: rx.disposeBag)
        
        meetingRoomSeg.rx.controlEvent(.valueChanged).subscribe(onNext:{  [weak self] in
            guard let `self` = self else { return }
            self.permissons[1] =  self.meetingRoomSeg.selectedSegmentIndex
        }).disposed(by: rx.disposeBag)
        
        staffSeg.rx.controlEvent(.valueChanged).subscribe(onNext:{  [weak self] in
            guard let `self` = self else { return }
            self.permissons[2] =  self.staffSeg.selectedSegmentIndex
        }).disposed(by: rx.disposeBag)
        
        nameCardSeg.rx.controlEvent(.valueChanged).subscribe(onNext:{  [weak self] in
            guard let `self` = self else { return }
            self.permissons[3] =  self.nameCardSeg.selectedSegmentIndex
        }).disposed(by: rx.disposeBag)
        
        segments = [departmentSeg,meetingRoomSeg,staffSeg,nameCardSeg]
        
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
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}

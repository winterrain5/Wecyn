//
//  AdminAddRoomContainer.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/9.
//

import UIKit
import KMPlaceholderTextView
import RxRelay

class AdminAddRoomContainer: UIView,UITextFieldDelegate {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var parentNodeTf: UITextField!
    @IBOutlet weak var selectParentNodeButton: UIButton!
    @IBOutlet weak var remark: KMPlaceholderTextView!
 
    var requestModel = AdminAddRoomRequestModel()
    var selectNode:AdminDepartmentModel?
    var parentNodeAccept:BehaviorRelay = BehaviorRelay<AdminDepartmentModel?>.init(value: nil)
    var nameAccept:BehaviorRelay = BehaviorRelay<String>.init(value: "")
    
    var model:AdminRoomModel? {
        didSet {
            guard let model = model else { return }
            parentNodeTf.text = model.dept.name
            nameTf.text = model.name
            remark.text = model.remark
            
            self.requestModel.name = model.name
            self.requestModel.org_id = Admin_Org_ID
            self.requestModel.dept_id = model.dept.id
            self.requestModel.id = model.id
            
            let parentNode = AdminDepartmentModel()
            parentNode.id = model.dept.id
            
            self.selectNode = parentNode

            parentNodeAccept.accept(parentNode)
            nameAccept.accept(model.dept.name ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        nameTf.delegate = self
        nameTf.returnKeyType = .done
        
        remark.textContainerInset = UIEdgeInsets(inset: 8)
        
        Observable.combineLatest(parentNodeAccept, nameAccept).map({
            return $0.0 != nil && !$0.1.isEmpty
        }).bind(to: submitButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        nameTf.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.nameAccept.accept($0)
            self?.requestModel.name = $0
        }).disposed(by: rx.disposeBag)
        
        selectParentNodeButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = AdminSelectDepartmentController(selectedNode: self.selectNode,selectFrom: .Room)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
            vc.selectComplete = {
                self.parentNodeAccept.accept($0)
                self.selectNode = $0
                self.requestModel.dept_id = $0.id
                self.parentNodeTf.text = $0.name
            }
        }).disposed(by: rx.disposeBag)
        
        
        submitButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.model == nil {
                self.addRoom()
            } else {
                self.updateRoom()
            }
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    func addRoom() {
        self.requestModel.remark = remark.text
        self.requestModel.org_id = Admin_Org_ID
        
        AdminService.addRoom(model: requestModel).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("Added successfully")
                UIViewController.sk.getTopVC()?.dismiss(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    func updateRoom() {
        self.requestModel.remark = remark.text
        
        AdminService.updateRoom(model: requestModel).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("successfully edited")
                UIViewController.sk.getTopVC()?.dismiss(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }

}

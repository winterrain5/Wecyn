//
//  AdminDepartmentDetailContainer.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/20.
//

import UIKit
import KMPlaceholderTextView
import EntryKit

import RxRelay
class AdminDepartmentDetailContainer: UIView ,UITextFieldDelegate{

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var hasAddressSwitch: UISwitch!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var parentNodeTf: UITextField!
    @IBOutlet weak var selectParentNodeButton: UIButton!
    @IBOutlet weak var remark: KMPlaceholderTextView!
    
    @IBOutlet weak var addrTf: UITextField!
    @IBOutlet weak var addrContainerHCons: NSLayoutConstraint!
    var mode:CheckMode = .Check
    var requestModel = AdminDepartmentAddRequestModel()
    var selectNode:AdminDepartmentModel?
    var node:MMNode<AdminDepartmentModel>! {
        didSet {
            parentNodeTf.text = node.parent?.element.name
            
            nameTf.text = node.element.name
            
            hasAddressSwitch.isOn = (node.element.has_addr == 1)
            addrTf.text = node.element.addr
            
            remark.text = node.element.remark
            
            func setViewUserInteractionEnabled(_ isEnable:Bool) {
                parentNodeTf.isUserInteractionEnabled = isEnable
                nameTf.isUserInteractionEnabled = isEnable
                selectParentNodeButton.isUserInteractionEnabled = isEnable
                hasAddressSwitch.isUserInteractionEnabled = isEnable
                addrTf.isUserInteractionEnabled = isEnable
            }
            
            if mode == .Check {
                setViewUserInteractionEnabled(false)
                submitButton.isHidden = true
                
            }
            
            if mode == .Add {
                setViewUserInteractionEnabled(true)
                submitButton.isHidden = false
                bottomView.isHidden = true
                submitButton.backgroundColor  = R.color.disableColor()
                submitButton.isEnabled = false
            }
            
            if mode == .Edit {
                setViewUserInteractionEnabled(true)
                submitButton.isHidden = false
                submitButton.isEnabled = true
                bottomView.isHidden = true
                
                self.requestModel.id = node.element.id.string
                self.requestModel.pid = node.element.pid
                self.requestModel.name = node.element.name
                self.requestModel.remark = node.element.remark
                self.requestModel.has_addr = node.element.has_addr
                self.requestModel.addr = node.element.addr
                
                let parentNode = AdminDepartmentModel()
                parentNode.id = node.element.pid
                
                self.selectNode = parentNode

                parentNodeAccept.accept(parentNode)
                nameAccept.accept(node.element.name)
            }
            
        }
    }
    
    var parentNodeAccept:BehaviorRelay = BehaviorRelay<AdminDepartmentModel?>.init(value: nil)
    var nameAccept:BehaviorRelay = BehaviorRelay<String>.init(value: "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        hasAddressSwitch.rx.isOn.bind(to: addrTf.rx.isUserInteractionEnabled).disposed(by: rx.disposeBag)
        hasAddressSwitch.rx.isOn.subscribe(onNext:{ [weak self] in
           
            self?.addrTf.isHidden = !$0
            self?.addrContainerHCons.constant = $0 ? 99 : 50
            self?.setNeedsUpdateConstraints()
            self?.layoutIfNeeded()
            self?.requestModel.has_addr = $0.int
            
        }).disposed(by: rx.disposeBag)
        addrTf.delegate = self
        addrTf.returnKeyType = .done
        
        nameTf.delegate = self
        nameTf.returnKeyType = .done
        
        Observable.combineLatest(parentNodeAccept, nameAccept).map({
            return $0.0 != nil && !$0.1.isEmpty
        }).bind(to: submitButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        nameTf.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.nameAccept.accept($0)
            self?.requestModel.name = $0
        }).disposed(by: rx.disposeBag)
        
        selectParentNodeButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = AdminDepartmentSelectParentNodeController(selectedNode: self.selectNode)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
            vc.selectComplete = {
                self.parentNodeAccept.accept($0)
                self.selectNode = $0
                self.requestModel.pid = $0.id
                self.parentNodeTf.text = $0.name
            }
        }).disposed(by: rx.disposeBag)
        
        
        submitButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.mode == .Add {
                self.addDepartment()
            }
            if self.mode == .Edit {
                self.updateDepartment()
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    func addDepartment() {
        self.requestModel.remark = remark.text
        self.requestModel.org_id = Admin_Org_ID
        self.requestModel.addr = addrTf.text
        AdminService.addDepartment(model: requestModel).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("successfully added")
                UIViewController.sk.getTopVC()?.dismiss(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    func updateDepartment() {
        self.requestModel.remark = remark.text
        self.requestModel.addr = addrTf.text
        AdminService.updateDepartment(model: requestModel).subscribe(onNext:{
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

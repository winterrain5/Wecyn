//
//  AdminAddDomainContainer.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/20.
//

import UIKit

class AdminAddDomainContainer: UIView,UITextFieldDelegate {

    @IBOutlet weak var emailSufixLabel: UILabel!
    @IBOutlet weak var submitButton: LoadingButton!
    @IBOutlet weak var sendCodeButton: CountDownButton!
    @IBOutlet weak var codeTf: UITextField!
    @IBOutlet weak var domainTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        emailSufixLabel.text = "  @  "
        domainTf.rx.text.orEmpty.map({ "  @\($0)  " }).bind(to: emailSufixLabel.rx.text).disposed(by: rx.disposeBag)
        
        domainTf.becomeFirstResponder()
        domainTf.delegate = self
        emailTf.delegate = self
        codeTf.delegate = self
        
        sendCodeButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            let email = self.emailTf.text?.appending("@").appending(self.domainTf.text ?? "") ?? ""
            guard email.isValidEmail else {
                Toast.showError("Email format is incorrect")
                return
            }
            
            self.sendCodeButton.startAnimation(title: "Send Code")
            AdminService.sendVerificationCode(email: email).subscribe(onNext:{
                
                self.sendCodeButton.startCountDownWithSecond(60)
                
                if $0.success == 1 {
                    
                } else {
                    self.sendCodeButton.stopAnimation()
                    Toast.showError($0.message)
                }
                
            },onError: { e in
                self.sendCodeButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        submitButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            self.submitButton.startAnimation()
            let email = self.emailTf.text?.appending("@").appending(self.domainTf.text ?? "") ?? ""
            let code = self.codeTf.text?.int ?? 0
            AdminService.domainVerification(orgId: Admin_Org_ID, email: email, code: code).subscribe(onNext:{
                self.submitButton.stopAnimation()
                
                if $0.success == 1 {
                    Toast.showSuccess("Added successfully")
                    UIViewController.sk.getTopVC()?.dismiss(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
                } else {
                    Toast.showError($0.message)
                }
                
            },onError: { e in
                self.submitButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
            
        }).disposed(by: rx.disposeBag)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
    }

}

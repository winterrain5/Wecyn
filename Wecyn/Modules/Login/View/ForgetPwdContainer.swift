//
//  ForgetPwdContainer.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/1.
//

import UIKit

class ForgetPwdContainer: UIView,UITextFieldDelegate{

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var emailTf: UITextField!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        emailTf.returnKeyType = .next
        emailTf.becomeFirstResponder()
        emailTf.delegate = self
        emailTf.enablesReturnKeyAutomatically = true
        
        emailTf.rx.text.orEmpty.map({ !$0.isEmpty }).subscribe {
            [weak self] in
            self?.nextButton.isEnabled = $0
            self?.nextButton.titleColorForNormal = $0 ?  R.color.theamColor() :  R.color.disableColor()
        }.disposed(by: rx.disposeBag)
        
        nextButton.rx.tap.subscribe(onNext:{
        [weak self] in
            self?.validateText()
        }).disposed(by: rx.disposeBag)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.validateText()
        
        return true
    }
    
    func validateText() {
        let text = self.emailTf.text ?? ""
        if !text.isValidEmail {
            Toast.showError("Invalid Email")
            return
        }
        
        endEditing(true)
        Toast.showLoading()
        AuthService.emailSendVertificationCode(email: text).subscribe(onNext:{
            Toast.dismiss()
            if $0.success == 1 {
                UserDefaults.sk.set(value: text, for: "ForgetPwd_Email")
                let vc = InputCodeController()
                UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.dismiss()
            Toast.showMessage(e.asAPIError.errorInfo().message, multiLine: true)
        }).disposed(by: rx.disposeBag)
            
      
        
    }

}

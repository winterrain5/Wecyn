//
//  ResetPwdContainer.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/1.
//

import UIKit
import Cache
class ResetPwdContainer: UIView,UITextFieldDelegate {
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var pwd2Tf: UITextField!
    @IBOutlet weak var pwd1Tf: UITextField!
  
    
    @IBOutlet weak var errorInfoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        errorInfoLabel.isHidden = true
        pwd1Tf.becomeFirstResponder()
        pwd1Tf.returnKeyType = .next
        pwd2Tf.returnKeyType = .send
        pwd2Tf.enablesReturnKeyAutomatically = true
        
        pwd1Tf.delegate = self
        pwd2Tf.delegate = self
        
        let pwd1 = pwd1Tf.rx.text.orEmpty
        let pwd2 = pwd2Tf.rx.text.orEmpty
        
        Observable.combineLatest(pwd1,pwd2).map({ !$0.1.isEmpty && !$0.0.isEmpty && ($0.1 == $0.0)}).subscribe(onNext:{
            [weak self] in
            self?.submitButton.isEnabled = $0
            self?.submitButton.titleColorForNormal = $0 ?  R.color.theamColor() :  R.color.disableColor()
        }).disposed(by: rx.disposeBag)
        
        pwd1Tf.rx.controlEvent(.editingDidEnd).subscribe { [weak self] _ in
            guard let `self` = self else { return }
            guard let result = self.pwd1Tf.text?.valiatePassword() else { return }
            if result.flag{
                self.errorInfoLabel.isHidden = false
                self.errorInfoLabel.text = result.message
            } else {
                self.errorInfoLabel.isHidden = true
            }
            
            UIView.animate(withDuration: 0.25) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }.disposed(by: rx.disposeBag)
        
        
        pwd1Tf.rx.controlEvent(.editingChanged).subscribe(onNext:{  [weak self] _ in
            guard let `self` = self else { return }
            
            if self.pwd2Tf.text?.isEmpty ?? false {
                self.errorInfoLabel.isHidden = true
                return
            }
            
            guard let result = self.pwd1Tf.text?.valiatePassword() else { return }
            
            if result.flag == false {
                self.errorInfoLabel.isHidden = true
            }
            
            
        }).disposed(by: rx.disposeBag)
        
        
        
        pwd2Tf.rx.controlEvent(.editingDidEnd).subscribe(onNext:{  [weak self] _ in
            guard let `self` = self else { return }
            if self.pwd2Tf.text?.isEmpty ?? false {
                self.errorInfoLabel.isHidden = true
                return
            }
            let result = self.pwd1Tf.text == self.pwd2Tf.text
            if result {
                self.errorInfoLabel.isHidden = true
            } else {
                self.errorInfoLabel.isHidden = false
                self.errorInfoLabel.text = "Two passwords do not match"
            }
            
            UIView.animate(withDuration: 0.25) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            
        }).disposed(by: rx.disposeBag)
        
        pwd2Tf.rx.controlEvent(.editingChanged).subscribe(onNext:{  [weak self] _ in
            guard let `self` = self else { return }
            let result = self.pwd1Tf.text == self.pwd2Tf.text
            
            if result {
                self.errorInfoLabel.isHidden = true
            }
            
            
        }).disposed(by: rx.disposeBag)
        
        submitButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            self?.submit()
            
        }).disposed(by: rx.disposeBag)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == pwd1Tf {
            pwd2Tf.becomeFirstResponder()
        }
        if textField == pwd2Tf {
            submit()
        }
        return true
    }
    
    func submit() {
        
        let email = UserDefaults.sk.value(for: "ForgetPwd_Email") as? String ?? ""
        let code = UserDefaults.sk.value(for: "ForgetPwd_Code") as? String ?? ""
        let pwd = self.pwd1Tf.text ?? ""
        
        Toast.showLoading()
        AuthService.resetPassword(email: email, code: code, password: MD5(pwd + "wecyn").lowercased()).subscribe(onNext:{
            
            Toast.dismiss()
            if $0.success == 1 {
                Toast.showSuccess("Reset Password Successfully")
                UIViewController.sk.getTopVC()?.navigationController?.popToRootViewController(animated: true)
            } else {
                Toast.showError($0.message)
            }
            
        },onError: { e in
            Toast.dismiss()
            Toast.showMessage(e.asAPIError.errorInfo().message, multiLine: true)
        }).disposed(by: rx.disposeBag)
    }
}

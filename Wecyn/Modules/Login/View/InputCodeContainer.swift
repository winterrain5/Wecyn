//
//  InputCodeContainer.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/1.
//

import UIKit

class InputCodeContainer: UIView,UITextFieldDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var codeTf: UITextField!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        codeTf.becomeFirstResponder()
        codeTf.delegate = self
        codeTf.returnKeyType = .next
        codeTf.enablesReturnKeyAutomatically = true
        
        codeTf.rx.text.orEmpty.map({ !$0.isEmpty }).subscribe {
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
        let text = self.codeTf.text ?? ""
        if text.count != 6 {
            Toast.showError("Invalid Code")
            return
        }
        UserDefaults.sk.set(value: text, for: "ForgetPwd_Code")
        let vc = ResetPwdController()
        UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
    }
    
}

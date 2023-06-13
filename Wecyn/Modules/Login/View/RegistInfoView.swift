//
//  RegisInfoView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class RegistInfoView: UIView {

    @IBOutlet weak var emailTf: UITextField!
    
    @IBOutlet weak var firstNameTf: UITextField!
    
    @IBOutlet weak var lastNameTf: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    
    @IBOutlet weak var contryTf: UITextField!
    
    @IBOutlet weak var codeTf: UITextField!
    
    @IBOutlet weak var locationTf: UITextField!
    
    @IBOutlet weak var nextButton: LoadingButton!
    
    
    
    override func awakeFromNib() {
     
        super.awakeFromNib()
     
        emailTf.keyboardType = .emailAddress
        
        nextButton.addShadow(cornerRadius: 20)
        self.subviews.filter({ $0 is UITextField }).forEach({ $0.addShadow(cornerRadius: 11) })
        
        let email = emailTf.rx.text.orEmpty
        let firstName = firstNameTf.rx.text.orEmpty
        let lastName = lastNameTf.rx.text.orEmpty
        let password = passwordTf.rx.text.orEmpty
        let country = contryTf.rx.text.orEmpty
        let code = codeTf.rx.text.orEmpty
        let location = locationTf.rx.text.orEmpty
        
        let isEmpty = Observable.combineLatest(email,firstName,lastName,password,country,code,location).map({
            return !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && !$0.3.isEmpty && !$0.4.isEmpty && !$0.5.isEmpty && !$0.6.isEmpty
        })
        
        let emailValid = email.asObservable().map({ $0.isValidEmail })
        let passwordValid = password.asObservable().map({ $0.isValidPassword })
        
        let result = Observable.combineLatest(isEmpty,emailValid,passwordValid).map({
            return $0.0 && $0.1 && $0.2
        })
        
//        result.asDriver(onErrorJustReturn: false).drive(nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        result.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if $0 {
                self.nextButton.backgroundColor = R.color.theamColor()
            } else {
                self.nextButton.backgroundColor = R.color.enableColor()
            }
        }).disposed(by: rx.disposeBag)
        
        
        nextButton.rx.tap.subscribe(onNext:{
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(RegistConfirmController(), animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    

}

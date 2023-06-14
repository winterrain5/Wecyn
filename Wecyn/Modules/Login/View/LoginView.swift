//
//  LoginView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class LoginView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameTf: UITextField!
    @IBOutlet weak var forgetPwdLabel: UILabel!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var regitLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userNameTf.addShadow(cornerRadius: 11)
        passwordTf.addShadow(cornerRadius: 11)
   
        
        forgetPwdLabel.sk.addBorderBottom(borderWidth: 1, borderColor: UIColor(hexString: "707070")!)
        
        signInButton.addShadow(cornerRadius: 20)
        
        googleLoginButton.cornerRadius = 20
        googleLoginButton.sk.addBorder(borderWidth: 2, borderColor: R.color.theamColor()!)

        regitLabel.sk.setSpecificTextUnderLine("Join now!", color: R.color.theamColor()!)
        regitLabel.sk.setSpecificTextColor("Join now!", color: R.color.theamColor()!)
        regitLabel.sk.setSpecificTextColor("New to Wecyn?", color: UIColor(hexString: "#525252")!)
        
        forgetPwdLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{_ in
            
        }).disposed(by: rx.disposeBag)
        
        signInButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let main = MainController()
            UIApplication.shared.keyWindow?.rootViewController = main
        }).disposed(by: rx.disposeBag)
        
        googleLoginButton.rx.tap.subscribe(onNext:{
            
        }).disposed(by: rx.disposeBag)
        
        regitLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(RegistInfoController(), animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}

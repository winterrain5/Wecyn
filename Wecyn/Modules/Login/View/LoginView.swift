//
//  LoginView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit
import Cache
import RxSwift
class LoginView: UIView {

    @IBOutlet weak var passwordStateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameTf: UITextField!
    @IBOutlet weak var forgetPwdLabel: UILabel!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var regitLabel: UILabel!
    @IBOutlet weak var signInButton: LoadingButton!
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
        
        let username = userNameTf.rx.text.orEmpty
        let password = passwordTf.rx.text.orEmpty
        let isNotEmpty = Observable.combineLatest(username,password).map({ !$0.0.isEmpty && !$0.1.isEmpty})
        isNotEmpty.asDriver(onErrorJustReturn: false).drive(signInButton.rx.isEnabled).disposed(by: rx.disposeBag)
        isNotEmpty.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.signInButton.backgroundColor = $0 ? R.color.theamColor()! : R.color.disableColor()!
        }).disposed(by: rx.disposeBag)
        
        forgetPwdLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{_ in
            
        }).disposed(by: rx.disposeBag)
        
        signInButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            guard let username = self.userNameTf.text,let password = self.passwordTf.text else { return }
            self.signInButton.startAnimation()
            AuthService.signin(username: username, password: MD5(password + "wecyn").lowercased()).subscribe(onNext:{ model in
                self.signInButton.stopAnimation()
                UserDefaults.sk.set(object: model, for: TokenModel.className)
                
                UserService.getUserInfo().subscribe(onNext:{ model in
                    UserDefaults.sk.set(object: model, for: UserInfoModel.className)
                    let main = MainController()
                    UIApplication.shared.keyWindow?.rootViewController = main
                },onError: { e in
                    let main = MainController()
                    UIApplication.shared.keyWindow?.rootViewController = main
                }).disposed(by: self.rx.disposeBag)
               
            },onError: { e in
                self.signInButton.stopAnimation()
                Toast.showMessage((e as! APIError).errorInfo().message)
            }).disposed(by: self.rx.disposeBag)

        }).disposed(by: rx.disposeBag)
        
        googleLoginButton.rx.tap.subscribe(onNext:{
            
        }).disposed(by: rx.disposeBag)
        
        regitLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(RegistInfoController(), animated: true)
        }).disposed(by: rx.disposeBag)
        
        passwordStateButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.passwordStateButton.isSelected.toggle()
            self.passwordTf.isSecureTextEntry = !self.passwordStateButton.isSelected
        }).disposed(by: rx.disposeBag)
        
        self.passwordTf.rx.text.orEmpty.map({ $0.isEmpty }).asDriver(onErrorJustReturn: false).drive(passwordStateButton.rx.isHidden).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}

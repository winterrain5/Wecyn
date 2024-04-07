//
//  LoginView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import PromiseKit
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
            
            let md5pwd = MD5(password + "wecyn").lowercased()
            self.signin(username: username, password: md5pwd)
                .then { _ in
                    self.getUserInfo()
                }
                .then { _ in
                    self.imLogin()
                }
                .done { _ in
                    
                    let tokenModel = UserDefaults.sk.get(of: TokenModel.self, for: TokenModel.className)
                    tokenModel?.is_logined = true
                    
                    UserDefaults.sk.set(object: tokenModel, for: TokenModel.className)
                    
                    let main = MainController()
                    UIApplication.shared.keyWindow?.rootViewController = main
                }
                .catch { e in
                    self.signInButton.stopAnimation()
                    Toast.showError((e as! APIError).errorInfo().message)
                }

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
        
        forgetPwdLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            let vc = ForgetPwdController()
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    
    func signin(username:String,password:String) -> Promise<Void>{
        Promise { resolver in
            AuthService.signin(username: username, password: password).subscribe(onNext:{ model in
                
                UserDefaults.sk.set(object: model, for: TokenModel.className)
                
                let userDefaults = UserDefaults(suiteName: APIHost.share.suitName)
                userDefaults?.setValue(model.token, forKey: "token")
                userDefaults?.synchronize()
                
                resolver.fulfill_()
               
            },onError: { e in
                self.signInButton.stopAnimation()
                Toast.showError((e as! APIError).errorInfo().message)
                resolver.reject(APIError.networkError(e))
            }).disposed(by: self.rx.disposeBag)
        }
    }
    
    func getUserInfo() -> Promise<Void> {
        Promise.init { resolver in
            UserService.getUserInfo().retry(3).subscribe(onNext:{ model in
                
                UserDefaults.sk.set(object: model, for: UserInfoModel.className)
                
                let userDefaults = UserDefaults(suiteName: APIHost.share.suitName)
                userDefaults?.setValue(model.id, forKey: "userId")
                userDefaults?.synchronize()
      
                resolver.fulfill_()
            },onError: { e in
                self.signInButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
                resolver.reject(e)
            }).disposed(by: self.rx.disposeBag)
           
        }
    }
    
    func imLogin() -> Promise<Void> {
        Promise { reslover in
            IMController.shared.login {
                reslover.fulfill_()
            } error: { e in
                reslover.reject(e)
                self.signInButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }

        }
    }
    
    func setImUser() -> Promise<Void> {
        Promise.init { resolver in
            guard let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.toIMUserInfo() else {
                resolver.reject(APIError.requestError(code: -1, message: "get UserInfoModel failure"))
                return
            }
            
            IMController.shared.setSelfInfo(userInfo: user) { str in
                resolver.fulfill_()
            }
        }
    }
}

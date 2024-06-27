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
import AuthenticationServices

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSignInWithAppleStateChanged(noti:)), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        
        userNameTf.addShadow(cornerRadius: 11)
        passwordTf.addShadow(cornerRadius: 11)
   
        
        forgetPwdLabel.sk.addBorderBottom(borderWidth: 1, borderColor: UIColor(hexString: "707070")!)
        
        signInButton.addShadow(cornerRadius: 20)

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
    
    @IBAction func signInWithApple(_ sender: Any) {
        //不要使用let requests = [ASAuthorizationAppleIDProvider().createRequest(), ASAuthorizationPasswordProvider().createRequest()]
//ASAuthorizationPasswordProvider().createRequest()在第一次用苹果登录授权的时候会报错ASAuthorizationErrorUnknown 1000
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        let appleIDProvide = ASAuthorizationAppleIDProvider()
        // 授权请求AppleID
        let appIDRequest = appleIDProvide.createRequest()
        // 在用户授权期间请求的联系信息
        appIDRequest.requestedScopes = [.fullName,.email]
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        let authorizationController = ASAuthorizationController.init(authorizationRequests: [appIDRequest])
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self
        // 在控制器初始化期间启动授权流
        authorizationController.performRequests()

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
    
    @objc func handleSignInWithAppleStateChanged(noti:NotificationCenter) {
        
    }

    deinit {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
    }
}


extension LoginView: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    

    func authorizationController(controller:ASAuthorizationController, didCompleteWithAuthorization authorization:ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            
            if authorization.credential.isKind(of: ASAuthorizationAppleIDCredential.classForCoder()) {
                // 用户登录使用ASAuthorizationAppleIDCredential
                let appleIDCredential = authorization.credential as! ASAuthorizationAppleIDCredential
                let user = appleIDCredential.user
                // 使用过授权的，可能获取不到以下三个参数
                let familyName = appleIDCredential.fullName?.familyName ?? ""
                let givenName = appleIDCredential.fullName?.givenName ?? ""
                let email = appleIDCredential.email ?? ""
                
                let identityToken = appleIDCredential.identityToken ?? Data()
                let authorizationCode = appleIDCredential.authorizationCode ?? Data()
                // 用于判断当前登录的苹果账号是否是一个真实用户，取值有：unsupported、unknown、likelyReal
                let realUserStatus = appleIDCredential.realUserStatus
                
                print("user:\n\(user)")
                print("identityToken:\n\(identityToken)")
                print("authorizationCode:\n\(authorizationCode)")
                // 服务器验证需要使用的参数
            }else if authorization.credential.isKind(of: ASPasswordCredential.classForCoder()) {
                // 这个获取的是iCloud记录的账号密码，需要输入框支持iOS 12 记录账号密码的新特性，如果不支持，可以忽略
                // Sign in using an existing iCloud Keychain credential.
                // 用户登录使用现有的密码凭证
                let passworCreddential = authorization.credential as! ASPasswordCredential
                // 密码凭证对象的用户标识 用户的唯一标识
                let user = passworCreddential.user
                // 密码凭证对象的密码
                let password = passworCreddential.password
                print("password:\n\(password)")
                
            }else{
                // "授权信息不符合"
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        if let e = error as? ASAuthorizationError {
            Toast.showError(e.localizedDescription)
        }

    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
    

    
}

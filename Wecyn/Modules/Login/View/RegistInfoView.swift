//
//  RegisInfoView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit
import Cache
import SwifterSwift
class RegistInfoView: UIView {
    
    @IBOutlet weak var emailTf: UITextField!
    
    @IBOutlet weak var firstNameTf: UITextField!
    
    @IBOutlet weak var lastNameTf: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    
    @IBOutlet weak var contryTf: UITextField!
    
    @IBOutlet weak var codeTf: UITextField!
    
    @IBOutlet weak var locationTf: UITextField!
    
    @IBOutlet weak var nextButton: LoadingButton!
    
    @IBOutlet weak var selectCountryButton: UIButton!
    
    @IBOutlet weak var selectLocationButton: UIButton!
    
    var registModel = RegistRequestModel()
    
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
        
        passwordTf.rx.controlEvent(.editingDidEnd).subscribe { [weak self] _ in
            guard let `self` = self else { return }
            guard let result = self.passwordTf.text?.valiatePassword() else { return }
            if result.flag{
                Toast.showMessage(result.message, multiLine: true)
            }
        }.disposed(by: rx.disposeBag)
        let isEmpty = Observable.combineLatest(email,firstName,lastName,password,code).map({
            self.registModel.email = $0.0
            self.registModel.first_name = $0.1
            self.registModel.last_name = $0.2
            self.registModel.password = MD5($0.3 + "wecyn").lowercased()
            self.registModel.postal_code = $0.4
            return !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && !$0.3.isEmpty && !$0.4.isEmpty
        })
        let emailValid = email.asObservable().map({ $0.isValidEmail })
        let passwordValid = password.asObservable().map({ $0.isPasswordRuler() })
        let result = Observable.combineLatest(isEmpty,emailValid,passwordValid).map({
            return $0.0 && $0.1 && $0.2
        })
        result.asDriver(onErrorJustReturn: false).drive(nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        result.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.nextButton.backgroundColor = $0 ? R.color.theamColor()! : R.color.disableColor()!
        }).disposed(by: rx.disposeBag)
        
     
        
        selectCountryButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = CountryListController(dataType: .Country)
            vc.selectedCountry.subscribe(onNext:{
                
                self.contryTf.text = $0?.country_name
                self.registModel.country_region_id = $0?.country_id
                self.registModel.country = $0?.country_name ?? ""
                
                self.registModel.location_id = nil
                self.locationTf.text = ""
                
                
            }).disposed(by: self.rx.disposeBag)
            let nav = BaseNavigationController(rootViewController: vc)
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
        }).disposed(by: rx.disposeBag)
        
        selectLocationButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            guard let countryID = self.registModel.country_region_id else {
                Toast.showMessage("Please select a country first")
                return
            }
            let vc = CountryListController(dataType: .City, countryID: countryID)
            vc.selectedCity.subscribe(onNext:{
                
                self.locationTf.text = $0?.city_name
                self.registModel.location_id = $0?.city_id ?? 0
                self.registModel.city = $0?.city_name ?? ""
                
            }).disposed(by: self.rx.disposeBag)
            let nav = BaseNavigationController(rootViewController: vc)
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
        }).disposed(by: rx.disposeBag)
        
        
        nextButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.nextButton.startAnimation()
            AuthService.signup(model: self.registModel).subscribe(onNext:{ model in
                self.nextButton.stopAnimation()
                
                UserDefaults.sk.set(object: self.registModel, for: RegistRequestModel.className)
                
                let vc = RegistConfirmController(registModel: self.registModel)
                UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc, animated: true)
                
            },onError: { e in
                self.nextButton.stopAnimation()
            }).disposed(by: self.rx.disposeBag)
            
            
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
}

//
//  RegistProfileView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class RegistProfileView: UIView {

    @IBOutlet weak var jobTitleTf: UITextField!
    
    @IBOutlet weak var emType: UITextField!
    
    @IBOutlet weak var companyTf: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var studentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        nextButton.addShadow(cornerRadius: 20)
        self.subviews.filter({ $0 is UITextField }).forEach({ $0.addShadow(cornerRadius: 11) })
        
        studentLabel.sk.setSpecificTextUnderLine("I'm a student", color: R.color.textColor33()!)
        studentLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            let main = MainController()
            UIApplication.shared.keyWindow?.rootViewController =  main
        }).disposed(by: rx.disposeBag)
        
        
        let jobTitle = jobTitleTf.rx.text.orEmpty
        let company = companyTf.rx.text.orEmpty
        
        let isNotEmpty = Observable.combineLatest(jobTitle,company).map({ !$0.0.isEmpty && !$0.1.isEmpty })
        isNotEmpty.asDriver(onErrorJustReturn: false).drive(nextButton.rx.isEnabled).disposed(by: rx.disposeBag)
        isNotEmpty.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.nextButton.backgroundColor = $0 ? R.color.theamColor()! : R.color.disableColor()!
        }).disposed(by: rx.disposeBag)
        
        Observable.combineLatest(jobTitle,company).subscribe(onNext:{ t1,t2 in
            
            if let registModel = UserDefaults.sk.get(of: RegistRequestModel.self, for: RegistRequestModel.className) {
                registModel.job_title = t1
                registModel.recent_company = t2
                
                UserDefaults.sk.set(object: registModel, for: RegistRequestModel.className)
            }
            
        }).disposed(by: rx.disposeBag)
        
        nextButton.rx.tap.subscribe(onNext:{
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(RegistAddAvatarController())
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}

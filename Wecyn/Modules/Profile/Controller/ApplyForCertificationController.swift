//
//  ApplyForCertificationController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/14.
//

import UIKit

class ApplyForCertificationController: BaseViewController {
    var updateComplete:(()->())?
    var model:UserExperienceInfoModel!
    required init(model:UserExperienceInfoModel) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let tf = UITextField()
        self.view.addSubview(tf)
        tf.frame = CGRect(x: 16, y: kNavBarHeight + 8, width: kScreenWidth - 32, height: 40)
        tf.becomeFirstResponder()
        tf.textColor = R.color.textColor33()!
        tf.placeholder = "Remark"
        tf.borderStyle = .none
        
        
        let line = UIView()
        line.frame = CGRect(x: 16, y: tf.frame.maxY + 1, width: kScreenWidth - 32, height: 1)
        line.backgroundColor = R.color.seperatorColor()!
        self.view.addSubview(line)

        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        let saveButton = UIButton()
        saveButton.imageForNormal = R.image.checkmark()
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            UserService.applyForCertification(id: self.model.id, type: self.model.exp_type, remark: tf.text ?? "").subscribe(onNext:{
                if $0.success == 1 {
                    Toast.showSuccess("Submitted successfully")
                    self.returnBack()
                    self.model.status = 2
                    self.updateComplete?()
                } else {
                    Toast.showError($0.message)
                }
            },onError: { e in
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        
        tf.rx.text.orEmpty.map({ !$0.isEmpty }).bind(to: saveButton.rx.isEnabled).disposed(by: rx.disposeBag)
                
    }
    

  

}

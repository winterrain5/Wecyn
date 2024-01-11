//
//  AdminEditStaffExpContainer.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/10.
//

import UIKit

class AdminEditStaffExpContainer: UIView,UITextFieldDelegate {
    
    @IBOutlet weak var titleTf: UITextField!
    
    @IBOutlet weak var industryTf: UITextField!
    
    @IBOutlet weak var submitButton: LoadingButton!
    
    @IBOutlet weak var descTf: UITextField!
    
    var requestModel = AdminUpdateStaffExpRequestModel()
    var updateComplete:((AdminUpdateStaffExpRequestModel)->())?
    var model:AdminStaffExps? {
        didSet {
            guard let model = model else { return }
            titleTf.text = model.title_name
            industryTf.text = model.industry_name
            descTf.text = model.desc
            
            requestModel.id = model.id
            requestModel.title_name = model.title_name
            requestModel.industry_name = model.industry_name
            requestModel.desc = model.desc
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleTf.delegate = self
        industryTf.delegate = self
        descTf.delegate = self
        
        
        submitButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            if self.titleTf.text?.isEmpty ?? false{
                Toast.showWarning("title cannot be empty")
                return
            }
            
            self.submitButton.startAnimation()
            
            self.requestModel.title_name = self.titleTf.text
            self.requestModel.industry_name = self.industryTf.text
            self.requestModel.desc = self.descTf.text
            
            AdminService.updateStaffExp(model: self.requestModel).subscribe(onNext:{
                if $0.success == 1 {
                   
                    
                    self.updateComplete?(self.requestModel)
                } else {
                    self.submitButton.stopAnimation()
                    Toast.showError($0.message)
                }
            },onError: { e in
                self.submitButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
       
        }).disposed(by: rx.disposeBag)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
    
}

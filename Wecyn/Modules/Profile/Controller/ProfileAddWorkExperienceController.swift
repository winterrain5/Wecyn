//
//  ProfileAddWorkExperienceController.swift
//  Wecyn
//
//  Created by Derrick on 2023/10/23.
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift
class ProfileAddWorkExperienceController: BaseViewController {

    var scrollView = UIScrollView()
    let container = AddUserWorkExperienceView.loadViewFromNib()
    var model:UserExperienceInfoModel?
    
    var orgNameRelay:BehaviorRelay = BehaviorRelay(value: "")
    var jobTitleRelay:BehaviorRelay = BehaviorRelay(value: "")
    var durationStartRelay:BehaviorRelay = BehaviorRelay(value: "")
    
    var requestModel = AddUserExperienceRequestModel()
    var profileWorkDataUpdated:(()->())?
    required init(model:UserExperienceInfoModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        view.addSubview(scrollView)
        scrollView.frame = self.view.bounds
        scrollView.contentSize = self.view.size
    
        scrollView.addSubview(container)
        container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 580)
        
        
        if let model = model {
            self.navigation.item.title = "Edit Work Experience"
            self.container.orgTf.text = model.org_name
            self.container.jobTitleTf.text = model.title_name
            self.container.startButton.titleForNormal = model.start_date
            self.container.startButton.titleColorForNormal = R.color.textColor33()
            self.container.endButton.titleForNormal = model.end_date.isEmpty ? "Present" :  model.end_date
            self.container.currentSwitch.isOn = model.end_date.isEmpty
            self.container.industryTf.text = model.industry_name
            self.container.descTf.text = model.desc
            
            self.requestModel.start_date = model.start_date
            self.requestModel.end_date = model.end_date
            self.requestModel.is_current = model.is_current
            self.requestModel.org_id = model.org_id
            
            self.orgNameRelay.accept(model.org_name)
            self.jobTitleRelay.accept(model.title_name)
            self.durationStartRelay.accept(model.start_date)
            
            func updateLayout() {
                let height = model.desc.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont.systemFont(ofSize: 16))
                let calHeight = height == 0 ? 60 :  (height + 15)
                self.container.descTfHCons.constant  = calHeight
                self.container.setNeedsUpdateConstraints()
                self.container.updateConstraintsIfNeeded()
                
                self.container.frame.size.height += height
                self.scrollView.contentSize =  CGSize(width: kScreenWidth, height: self.container.height)
            }

            updateLayout()
           
        } else {
            self.navigation.item.title = "Add Work Experience"
        }
        
        let saveButton = UIButton()
        saveButton.imageForNormal = R.image.checkmark()
        saveButton.size = CGSize(width: 40, height: 36)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.requestModel.exp_type = 2
            self.requestModel.org_name = self.container.orgTf.text
            self.requestModel.title_name = self.container.jobTitleTf.text
            self.requestModel.desc = self.container.descTf.text
            self.requestModel.industry_name = self.container.industryTf.text
            if self.model == nil {
                self.add()
            } else {
                self.requestModel.id = self.model?.id
                self.update()
            }
            
        }).disposed(by: rx.disposeBag)
        
        let isSaveEnable = Observable.combineLatest(orgNameRelay,jobTitleRelay,durationStartRelay).map({
            !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty
        }).asObservable()
        
        isSaveEnable.bind(to: saveButton.rx.isEnabled).disposed(by: rx.disposeBag)
     
        container.jobTitleTf.rx.text.orEmpty.changed.bind(onNext: { [weak self] in self?.jobTitleRelay.accept($0) }).disposed(by: rx.disposeBag)
        
        
        container.startButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.view.endEditing(true)
            let maxmumDate = self.requestModel.end_date?.date(withFormat: "MM-yyyy") ?? Date()
            DatePickerView(title: "Start Date", mode: .date,maximumDate: maxmumDate) { date in
                let dateStr = date.toString(format: "MM-yyyy",isZero: false)
                self.durationStartRelay.accept(dateStr)
                self.requestModel.start_date = dateStr
                self.container.startButton.titleForNormal = dateStr
                self.container.startButton.titleColorForNormal = R.color.textColor33()
            }.show()
        }).disposed(by: rx.disposeBag)
        
        container.endButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.view.endEditing(true)
            let minimumDate = self.requestModel.start_date?.date(withFormat: "MM-yyyy")
            DatePickerView(title: "End Date", mode: .date,minimumDate: minimumDate,maximumDate: Date()) { date in
                let dateStr = date.toString(format: "MM-yyyy",isZero: false)
                self.requestModel.end_date = dateStr
                self.requestModel.is_current = 0
                self.container.endButton.titleForNormal = dateStr
                self.container.endButton.titleColorForNormal = R.color.textColor33()
                self.container.currentSwitch.isOn = false
            }.show()
        }).disposed(by: rx.disposeBag)
        
        
        container.orgNameSelectButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = OrganizationSearchController()
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            vc.selectComplete = {
                self.container.orgTf.text = $0.name
                self.orgNameRelay.accept($0.name)
                if $0.id != -1 {
                    self.requestModel.org_id = $0.id
                } else {
                    self.requestModel.org_id = nil
                }
            }
            self.present(nav, animated: true)
        }).disposed(by: rx.disposeBag)

        
        container.currentSwitch.rx.controlEvent(.valueChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            if self.container.currentSwitch.isOn {
                self.container.endButton.titleForNormal = "Present"
                self.container.endButton.titleColorForNormal = R.color.textColor33()
                self.requestModel.end_date = nil
                self.requestModel.is_current = 1
            } else {
                self.container.endButton.titleForNormal = "End Date"
                self.container.endButton.titleColorForNormal = R.color.textColor99()
            }
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    

    func add() {
       
        UserService.addUserExperience(model: self.requestModel).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("Add successfully")
                self.returnBack()
                self.profileWorkDataUpdated?()
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
    }

    func update() {
        UserService.updateUserExperience(model: self.requestModel).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("Edit successfully")
                self.returnBack()
                self.profileWorkDataUpdated?()
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
    }
}

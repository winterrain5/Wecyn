//
//  NFCNameCardEditController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/26.
//

import UIKit



class NameCardEditModel {
    var placeholder:String
    var image:UIImage? = nil
    var value:String
    var type:NameCardDataType
    init(placeholder: String, image: UIImage? = nil, value: String = "", type: NameCardDataType) {
        self.placeholder = placeholder
        self.image = image
        self.value = value
        self.type = type
    }
}

class NFCNameCardEditController: BaseTableController {
    var datas:[[NameCardEditModel]] = []
    
    let firstname = NameCardEditModel(placeholder: "First Name", type:.FirstName)
    let lastname = NameCardEditModel(placeholder: "Last Name", type:.LastName)
    let jobTitle = NameCardEditModel(placeholder: "Job Title", type:.JobTitle)
    let companyName = NameCardEditModel(placeholder: "Organization Name", type:.CompanyName)
    
    let mobile = NameCardEditModel(placeholder: "Mobile Number", type:.Mobile)
    let officeNo = NameCardEditModel(placeholder: "Office Number",image: R.image.phoneCircleFill(), type:.OfficeNumber)
    let officeLocation = NameCardEditModel(placeholder: "Office Location",image: R.image.locationCircleFill(), type:.OfficeLocation)
    let website = NameCardEditModel(placeholder: "Organization Website",image: R.image.rectangleOnRectangleCircleFill(), type:.Website)
    
    let request = UpdateUserInfoRequestModel()
    
    let headView = NFCNameCardEditHeadView()
    var updateComplete:(()->())?
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className) else {
            return
        }
        firstname.value = user.first_name
        lastname.value = user.last_name
        jobTitle.value = user.title
        companyName.value = user.org_name
        datas.append([firstname,lastname,companyName,jobTitle,mobile])
        
        mobile.value  = user.tel_cell
        officeNo.value = user.tel_work
        officeLocation.value = user.adr_work
        website.value = user.url
        datas.append([officeNo,officeLocation,website])
        
        headView.model = user
        
        Mirror(reflecting: UpdateUserInfoRequestModel()).children.forEach { child in
            guard let key = child.label else { return }
            self.request.setValue(user.value(forKey: key), forKey: key)
        }
      
        
        let saveButton = UIButton()
        saveButton.imageForNormal = R.image.checkmark()
        saveButton.size = CGSize(width: 30, height: 30)
        saveButton.contentMode = .right
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Toast.showLoading()
            UserService.updateUserInfo(model: self.request).subscribe(onNext:{
                if $0.success == 1 {
                    Toast.showSuccess(withStatus: "Update Successful")
                    self.navigationController?.popViewController(animated: true,{
                        self.updateComplete?()
                    })
                } else {
                    Toast.showError(withStatus: $0.message)
                }
            },onError: { e in
                Toast.showError(withStatus: e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
            
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        
        self.navigation.item.title = "Edit your card"
    }

    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.backgroundColor = R.color.backgroundColor()
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        tableView?.register(cellWithClass: NameCardEditItemCell.self)
        tableView?.rowHeight = 48
        
        headView.size = CGSize(width: kScreenWidth, height: 280)
        tableView?.tableHeaderView = headView
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        datas.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: NameCardEditItemCell.self)
        let model = datas[indexPath.section][indexPath.row]
        cell.model = model
        cell.inputChanged = { [weak self] e in
            guard let `self` = self else { return }
            switch e.type {
            case .FirstName:
                self.request.first_name = e.value
            case .LastName:
                self.request.last_name = e.value
            case .CompanyName:
                self.request.org_name = e.value
            case .JobTitle:
                self.request.title = e.value
            case .Mobile:
                self.request.tel_cell = e.value
            case .OfficeNumber:
                self.request.tel_work = e.value
            case .OfficeLocation:
                self.request.adr_work = e.value
            case .Website:
                self.request.url = e.value
            default:
                print(e.value)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = NameCardSectionView()
            view.label.text = "Personal details"
            return view
        }
        if section == 1 {
            let view = NameCardSectionView()
            view.label.text = "Organization Info"
            return view
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

class NameCardSectionView: UIView {
    
    var label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.textColor = R.color.textColor162C46()
        label.font = UIFont.sk.pingFangSemibold(15)
        label.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
    }
}




class NameCardEditItemCell: UITableViewCell,UITextFieldDelegate {
    var input = UITextField()
    var imgView = UIImageView()
    var model: NameCardEditModel? {
    
        didSet  {
            guard let model = model else { return }
            input.placeholder = model.placeholder
            input.text = model.value
            imgView.image = model.image
            setNeedsLayout()
            layoutIfNeeded()
            
            switch model.type {
            case .Mobile,.OfficeNumber:
                input.keyboardType = .phonePad
            case .Email:
                input.keyboardType = .emailAddress
            case .Website:
                input.keyboardType = .URL
            default:
                input.keyboardType = .default
            }
        }
    }
    var inputChanged:((NameCardEditModel)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(input)
        contentView.addSubview(imgView)
        
        input.borderStyle = .none
        input.clearButtonMode = .whileEditing
        input.textColor = R.color.textColor52()
        input.font = UIFont.sk.pingFangRegular(16)
        input.setPlaceHolderTextColor(R.color.textColor162C46()!)
        input.returnKeyType = .done
        input.enablesReturnKeyAutomatically = true
        input.delegate = self
        input.rx.controlEvent(.editingChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.model?.value = self.input.text ?? ""
            self.inputChanged?(self.model!)
        }).disposed(by: rx.disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if model?.image == nil {
            input.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.top.bottom.equalToSuperview()
                make.right.equalToSuperview().inset(16)
            }
        } else {
            imgView.snp.remakeConstraints { make in
                make.left.equalToSuperview().inset(16)
                make.width.height.equalTo(20)
                make.centerY.equalToSuperview()
            }
            
            input.snp.remakeConstraints { make in
                make.left.equalTo(imgView.snp.right).offset(16)
                make.top.bottom.equalToSuperview()
                make.right.equalToSuperview().inset(16)
            }
        }
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
}

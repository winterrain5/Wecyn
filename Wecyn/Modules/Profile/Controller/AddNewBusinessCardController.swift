//
//  AddNewBusinessCardController.swift
//  Wecyn
//
//  Created by Derrick on 2023/11/8.
//

import UIKit
import AddressBook
import AddressBookUI
import Contacts
// email, tel_cell, name, postal_code, title, adr_work, tel_work, url

enum BusinessCardField {
    case FamilyName
    case GivenName
    
    case Phone
    case TelWork
    
    case Organization
    case Department
    case JobTitle
    
    case Address
    case PostCode
    case Email
    case Url
    
    case Note
    case Other
    
}

class BusinessCardModel {
    var label:String
    var value:String
    var type:BusinessCardField
    init(label: String,type:BusinessCardField, value: String = "") {
        self.label = label
        self.type = type
        self.value = value
    }
}

class AddNewBusinessCardController: BaseTableController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    var datas:[[BusinessCardModel]] = []
    var model:ScanCardModel!
    required init(model:ScanCardModel) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.item.title = "Edit BusinessCard"
        
        let saveButton = UIButton()
        saveButton.size = CGSize(width: 30, height: 30)
        saveButton.contentMode = .right
        saveButton.imageForNormal = R.image.checkmark()
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            self.addContact()
            
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        /*
         {
           "email": "user@example.com",
           "tel_cell": "",
           "name": "",
           "postal_code": "",
           "title": "",
           "org_name": "",
           "adr_work": "",
           "tel_work": "",
           "url": "https://www.example.com",
           "other": []
         }
         */
        datas = [
            [BusinessCardModel(label: "FamilyName",type: .FamilyName,value: model.name),BusinessCardModel(label: "GivenName",type: .GivenName)],
            [BusinessCardModel(label: "Phone",type: .Phone,value: model.tel_cell),BusinessCardModel(label: "Office Number",type: .TelWork,value: model.tel_work)],
            [BusinessCardModel(label: "Organization",type: .Organization,value: model.org_name),BusinessCardModel(label: "Department",type: .Department),BusinessCardModel(label: "Job Title",type: .JobTitle,value: model.title)],
            [BusinessCardModel(label: "Address",type: .Address,value: model.adr_work),BusinessCardModel(label: "Postal Code", type: .PostCode,value: model.postal_code),BusinessCardModel(label: "Email",type: .Email,value: model.email),BusinessCardModel(label: "Url", type: .Url,value: model.url)],
            [BusinessCardModel(label: "Note", type: .Note)],
            [BusinessCardModel(label: "Other", type: .Other,value: model.other.joined(separator: "\n"))]
        ]
    }
    
   
    func  addContact() {
        
        
        let contact = CNMutableContact()
        
        
        let flapData = datas.flatMap({ $0 })

        func getValue(_ type:BusinessCardField) -> String {
            return flapData.filter({ $0.type == type }).first?.value ?? ""
        }
        //姓名
        contact.familyName = String(getValue(.FamilyName).split(separator: " ").first ?? "")
        contact.givenName =  String(getValue(.GivenName).split(separator: " ").last ?? "")
        
        //公司信息
        contact.organizationName = getValue(.Organization)
        contact.departmentName = getValue(.Department)
        contact.jobTitle = getValue(.JobTitle)
        
        
        //电话
        let mobileNumber = CNPhoneNumber(stringValue:  getValue(.Phone) )
        let mobileValue = CNLabeledValue (label:CNLabelPhoneNumberMobile ,
                                            value:mobileNumber)
        
        let tel_work = CNPhoneNumber(stringValue: getValue(.TelWork))
        let tel_work_value = CNLabeledValue(label: CNLabelWork, value: tel_work)
        contact.phoneNumbers = [mobileValue,tel_work_value]
        
        //email
        let email = CNLabeledValue(label:CNLabelWork,value:getValue(.Email) as NSString )
        let url = CNLabeledValue(label:CNLabelURLAddressHomePage,value:getValue(.Url) as NSString )
        contact.emailAddresses = [email,url]
        
        let address = CNMutablePostalAddress()
        address.street = getValue(.Address)
        address.postalCode = getValue(.PostCode)
        let labeledAddress = CNLabeledValue<CNPostalAddress>(label: CNLabelWork, value: address)
        contact.postalAddresses = [labeledAddress]
        
        contact.note = getValue(.Note)
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact,toContainerWithIdentifier: nil )
        
        
        let store = CNContactStore()
        do {
            //写入联系人
            try store.execute(saveRequest)
            Toast.showSuccess("Business card saved to address book")
        } catch {
            print (error)
        }
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = UIEdgeInsets(horizontal: 16, vertical: 0)
        tableView?.register(cellWithClass: AddNewBusinessCardCell.self)
        tableView?.register(cellWithClass: AddNewBusinessCardOtherCell.self)
    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == datas.count - 1 {
            return 200
        }
        return 44
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        datas.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == datas.count - 1 {
            
            let cell = AddNewBusinessCardOtherCell()
            let data = datas[indexPath.section][indexPath.row]
            cell.model = data
            return cell
        }
        let cell = AddNewBusinessCardCell()
        let data = datas[indexPath.section][indexPath.row]
        cell.model = data
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().backgroundColor(R.color.backgroundColor()!)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
}

class AddNewBusinessCardCell:UITableViewCell {
    let label = UILabel().color(R.color.textColor77()!).font(UIFont.systemFont(ofSize: 15, weight: .regular))
    let textField = UITextField().font(UIFont.systemFont(ofSize: 15, weight: .regular)).color(R.color.textColor22()!)
    var model:BusinessCardModel! {
        didSet {
            label.text = model.label
            textField.text = model.value
        }
    }
    var editEndHandler:((BusinessCardModel)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(textField)
        textField.clearButtonMode = .whileEditing
        textField.rx.controlEvent(.editingChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.model.value = self.textField.text ?? ""
            self.editEndHandler?(self.model)
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(106)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(label.snp.right).offset(8)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}

class AddNewBusinessCardOtherCell: UITableViewCell {
    let label = UILabel().color(R.color.textColor77()!).font(UIFont.systemFont(ofSize: 15, weight: .regular)).text("unrecognized")
    let textField = UITextView()
    var model:BusinessCardModel! {
        didSet {
            label.text = model.label
            textField.text = model.value
        }
    }
    var editEndHandler:((BusinessCardModel)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(textField)
        textField.textColor = R.color.textColor22()
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(106)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(label.snp.right).offset(8)
            make.top.bottom.equalToSuperview().inset(8)
            make.right.equalToSuperview().offset(-16)
        }
    }
}

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
import ParallaxHeader
import KMPlaceholderTextView
//import PaddleOCR
import AnyImageKit
import GPUImage

enum BusinessCardField {
    case Lang
    case Model
    case OCRTime
    case AITime
    case AllTime
    
    case Name
    
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
    var cellHeight:CGFloat {
        let h = value.heightWithConstrainedWidth(width: kScreenWidth - 146, font: UIFont.systemFont(ofSize: 15, weight: .regular)) + 16
        return h < 44 ? 44 : h
    }
    init(label: String,type:BusinessCardField, value: String = "") {
        self.label = label
        self.type = type
        self.value = value
    }
}

class AddNewBusinessCardController: BaseTableController, ImageEditorControllerDelegate {
    func imageEditorDidCancel(_ editor: AnyImageKit.ImageEditorController) {
        
    }
    
    func imageEditor(_ editor: AnyImageKit.ImageEditorController, didFinishEditing result: AnyImageKit.EditorResult) {
        
        result.mediaURL.loadImage(completion: { res in
            switch res {
            case .success(let image):
                editor.dismiss(animated: true)
                let scaledImage = image.scaled(toWidth: kScreenWidth)
                self.headImageView.image = scaledImage
                self.tableView?.tableHeaderView = self.headImageView
                self.headImageView.size = CGSize(width: kScreenWidth, height: scaledImage?.size.height ?? 0)
                
                self.image = image
                self.imageOCRByPaddle()
                
            case .failure(let e):
                Toast.showError(e.localizedDescription)
            }
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    var datas:[[BusinessCardModel]] = []
    var model:ScanCardModel?
    var image:UIImage!
    var lange = "1"
    /// 1 gpt-4-1106-preview,2 gpt-3.5-turbo-0613,3 gpt-3.5-turbo-1106
    var ai_model = "2"
    var ocrText:String = ""
    var headImageView = UIImageView()
    required init(image:UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.item.title = "Add BusinessCard"
        
        let saveButton = UIButton()
        saveButton.size = CGSize(width: 30, height: 30)
        saveButton.contentMode = .right
        saveButton.imageForNormal = R.image.checkmark()
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            self.addContact()
            
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        imageOCRByPaddle()
    }
    
    func imageOCRByPaddle() {
        
        let scaledImage = image.scaledImage(1000) ?? image
        let preprocessedImage = scaledImage?.preprocessedImage() ?? scaledImage
//        MLPaddleOCR().scanText(from: preprocessedImage, complete: { (result) in
//            guard let ocrResultList = result else { return }
//            var resultString = ""
//            for ocrData in ocrResultList {
//                if !ocrData.label.isEmpty {
//                    resultString = resultString + ocrData.label + "\n"
//                }
//            }
//            self.ocrText = resultString
//            DispatchQueue.main.async {
//                Logger.debug(resultString,label: "PaddleOCR")
//                self.uploadBusinessCard(resultString)
//            }
//        })
        
        
    }
    
    func uploadBusinessCard(_ cardText:String) {
        Toast.showLoading(withStatus: "Recognizing...")
        NetworkService.scanCard(cardText:cardText,lang: lange.int ?? 1,model: ai_model.int ?? 1).subscribe(onNext:{
            Toast.dismiss()
            self.model = $0
            self.configData()
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
            Toast.dismiss()
        }).disposed(by: self.rx.disposeBag)
        
    }
    
    func configData() {
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
        guard let model = self.model else { return }
        datas = [
            [BusinessCardModel(label: "Lang", type: .Lang,value: lange)],
            
            
            [BusinessCardModel(label: "Name",type: .Name,value: model.name)],
            [BusinessCardModel(label: "MB.",type: .Phone,value: model.tel_cell),
             BusinessCardModel(label: "Tel.",type: .TelWork,value: model.tel_work)],
            [BusinessCardModel(label: "Org.",type: .Organization,value: model.org_name),
             BusinessCardModel(label: "Dept.",type: .Department),
             BusinessCardModel(label: "Job Title",type: .JobTitle,value: model.title)],
            [BusinessCardModel(label: "Address",type: .Address,value: model.adr_work),
             BusinessCardModel(label: "P.C.", type: .PostCode,value: model.postal_code),
             BusinessCardModel(label: "Email",type: .Email,value: model.email),
             BusinessCardModel(label: "Url", type: .Url,value: model.url)],
            [BusinessCardModel(label: "Note", type: .Note)],
            [BusinessCardModel(label: "Other", type: .Other,value: model.other.joined(separator: "\n"))]
        ]
        
        if APIHost.share.buildType == .Dev {
            
            let ai_model_section = [BusinessCardModel(label: "Model", type: .Model,value: ai_model),
                                    BusinessCardModel(label: "ocr", type: .OCRTime,value: model.run_time?.ocr.string ?? ""),
                                    BusinessCardModel(label: "ai", type: .AITime,value: model.run_time?.ai.string ?? ""),
                                    BusinessCardModel(label: "all", type: .AllTime,value: model.run_time?.all.string ?? "")]
            
            datas.insert(ai_model_section, at: 1)
            
            
        }
        
        self.tableView?.reloadData()
    }
    
    
    func addContact() {
        
        
        let contact = CNMutableContact()
        
        
        let flapData = datas.flatMap({ $0 })
        
        func getValue(_ type:BusinessCardField) -> String {
            return flapData.filter({ $0.type == type }).first?.value ?? ""
        }
        //姓名
        contact.givenName =  getValue(.Name)
        
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
        
        
        let scaledImage = image.scaled(toWidth: kScreenWidth)
        headImageView.image = image
        headImageView.contentMode = .scaleAspectFill
        tableView?.tableHeaderView = headImageView
        headImageView.size = CGSize(width: kScreenWidth, height: scaledImage?.size.height ?? 0)
        headImageView.isUserInteractionEnabled = true
        
        let cropButton = UIButton()
        cropButton.imageForNormal = R.image.crop()?.scaled(toWidth: 16)
        cropButton.backgroundColor = .white
        cropButton.cornerRadius = 16
        headImageView.addSubview(cropButton)
        cropButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
        
        cropButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            var photoOption = EditorPhotoOptionsInfo()
            photoOption.toolOptions = [.crop]
            
            let scaledImage = self.image.scaled(toWidth: kScreenWidth)!
            let vc = ImageEditorController(photo: scaledImage, options: photoOption, delegate: self)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }).disposed(by: rx.disposeBag)
        
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = UIEdgeInsets(horizontal: 16, vertical: 0)
        
        tableView?.register(cellWithClass: AddNewBusinessCardOptionCell.self)
        tableView?.register(cellWithClass: AddNewBusinessCardCell.self)
        tableView?.register(cellWithClass: AddNewBusinessCardOtherCell.self)
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == datas.count - 1 {
            return 200
        } else {
            return datas[indexPath.section][indexPath.row].cellHeight
        }
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        datas.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = datas[indexPath.section][indexPath.row]
        if data.type == .Model || data.type == .Lang{
            let cell = AddNewBusinessCardOptionCell()
            cell.model = data
            cell.changeOptionHandler = { [weak self] model in
                guard let `self` = self else { return }
                
                if model.type == .Lang {
                    self.lange = model.value
                } else {
                    self.ai_model = model.value
                }
                
                self.tableView?.reloadData()
                self.uploadBusinessCard(self.ocrText)
                
            }
            return cell
        }
        if indexPath.section == datas.count - 1 {
            
            let cell = AddNewBusinessCardOtherCell()
            cell.model = data
            return cell
        }
        let cell = AddNewBusinessCardCell()
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
    let textField = KMPlaceholderTextView()
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
        
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textField.textColor = R.color.textColor22()!
        textField.rx.didEndEditing.subscribe(onNext:{ [weak self] in
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
            make.width.equalTo(66)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(label.snp.right).offset(8)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}

class AddNewBusinessCardOptionCell: UITableViewCell {
    let label = UILabel().color(R.color.textColor77()!).font(UIFont.systemFont(ofSize: 15, weight: .regular)).text("Lang")
    let langLabel = UILabel().color(R.color.textColor22()!).font(UIFont.systemFont(ofSize: 15, weight: .regular)).text("中文")
    let button = UIButton()
    var changeOptionHandler:((BusinessCardModel)->())?
    var model:BusinessCardModel! {
        didSet {
            label.text = model.label
            
            if model.type == .Lang {
                langLabel.text = model.value.int == 1 ? "中文" : "English"
                
                
                // 1.1 gpt-4-1106-preview,2 gpt-3.5-turbo-0613,3 gpt-3.5-turbo-1106
                let action1 = UIAction(title: "中文",image: nil) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.model.value = "1"
                    self.changeOptionHandler?(self.model)
                }
                
                let action2 = UIAction(title: "English",image: nil) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.model.value = "2"
                    self.changeOptionHandler?(self.model)
                }
                
                
                button.showsMenuAsPrimaryAction = true
                let menus = [action1,action2]
                button.menu = UIMenu(children: menus)
                
            } else {
                if model.value.int == 2 {
                    langLabel.text = "gpt-3.5-turbo-0613"
                }
                if APIHost.share.buildType == .Dev {
                    if model.value.int == 1 {
                        langLabel.text = "gpt-4-1106-preview"
                    }
                    
                    if model.value.int == 2 {
                        langLabel.text = "gpt-3.5-turbo-0613"
                    }
                    
                    if model.value.int == 3 {
                        langLabel.text = "gpt-3.5-turbo-1106"
                    }
                    
                    // 1.1 gpt-4-1106-preview,2 gpt-3.5-turbo-0613,3 gpt-3.5-turbo-1106
                    let action1 = UIAction(title: "gpt-4-1106-preview",image: nil) { [weak self] _ in
                        guard let `self` = self else { return }
                        self.model.value = "1"
                        self.changeOptionHandler?(self.model)
                    }
                    
                    let action2 = UIAction(title: "gpt-3.5-turbo-0613",image: nil) { [weak self] _ in
                        guard let `self` = self else { return }
                        self.model.value = "2"
                        self.changeOptionHandler?(self.model)
                    }
                    
                    let action3 = UIAction(title: "gpt-3.5-turbo-1106",image: nil) { [weak self] _ in
                        guard let `self` = self else { return }
                        self.model.value = "3"
                        self.changeOptionHandler?(self.model)
                    }
                    
                    button.showsMenuAsPrimaryAction = true
                    let menus = [action1,action2,action3]
                    button.menu = UIMenu(children: menus)
                }
                
            }
            
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(langLabel)
        contentView.addSubview(button)
        
        button.titleForNormal = "Change"
        button.titleColorForNormal = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(66)
        }
        
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(72)
        }
        
        langLabel.snp.makeConstraints { make in
            make.left.equalTo(label.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(button.snp.left).offset(-16)
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
            make.width.equalTo(66)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(label.snp.right).offset(8)
            make.top.bottom.equalToSuperview().inset(8)
            make.right.equalToSuperview().offset(-16)
        }
    }
}


// MARK: - UIImage extension
extension UIImage {
  func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)

    if size.width > size.height {
      scaledSize.height = size.height / size.width * scaledSize.width
    } else {
      scaledSize.width = size.width / size.height * scaledSize.height
    }

    UIGraphicsBeginImageContext(scaledSize)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
  
  func preprocessedImage() -> UIImage? {
    let stillImageFilter = GPUImageAdaptiveThresholdFilter()
    stillImageFilter.blurRadiusInPixels = 15.0
    let filteredImage = stillImageFilter.image(byFilteringImage: self)
    return filteredImage
  }
}

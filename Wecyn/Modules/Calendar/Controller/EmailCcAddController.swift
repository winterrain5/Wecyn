//
//  EmailCcAddController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/10.
//

import UIKit
import TagListView
class EmailCcModel {
    var email:String
    var isSelect: Bool
    
    init(email: String, isSelect: Bool = true) {
        self.email = email
        self.isSelect = isSelect
    }
}
class EmailCcAddController: BaseViewController ,UITextFieldDelegate, TagListViewDelegate{
    
    var inputEmails: BehaviorRelay = BehaviorRelay<[EmailCcModel]>(value: [])
    var selectComplete:(([String])->())?
    var tagListView = TagListView()
    lazy var inputEmailView: UIView = {
        let view = UIView()
        
        
        let tf = UITextField()
        tf.returnKeyType = .done
        tf.keyboardType = .emailAddress
        tf.borderStyle = .none
        tf.placeholder = "input email"
        tf.font = UIFont.sk.pingFangRegular(16)
        tf.becomeFirstResponder()
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
        view.addSubview(tf)
        
        tf.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.top.equalToSuperview().offset(-1)
        }
        
        return view
    }()
    
    init(emails:[String]) {
        super.init(nibName: nil, bundle: nil)
        
        self.inputEmails.accept(emails.map({ [weak self] in
            self?.tagListView.insertTag($0, at: 0)
            return EmailCcModel(email: $0)
        }))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.title = "Email Cc"

        view.addSubview(inputEmailView)
        inputEmailView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: 44)
        inputEmailView.sk.addBorderBottom(borderWidth: 1, borderColor: R.color.backgroundColor()!)
        
        self.addLeftBarButtonItem()
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        let doneButton = UIButton()
        doneButton.textColor(.black)
        let doneItem = UIBarButtonItem(customView: doneButton)
        
        let fixItem = UIBarButtonItem.fixedSpace(width: 16)
        
        self.navigation.item.rightBarButtonItems = [doneItem,fixItem]
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.selectComplete?(self.inputEmails.value.map({ $0.email }))
            self.returnBack()
        }).disposed(by: rx.disposeBag)
        
        self.inputEmails.map({ !$0.isEmpty }).subscribe(onNext:{ $0 ? (doneButton.titleForNormal = "Done") : (doneButton.titleForNormal = "Cancel") }).disposed(by: rx.disposeBag)
 
        view.addSubview(tagListView)
        tagListView.frame = CGRect(x: 16, y: inputEmailView.frame.maxY + 16, width: kScreenWidth - 32, height: kScreenHeight - inputEmailView.frame.maxY)
        tagListView.delegate = self
        tagListView.textColor = .white
        tagListView.tagBackgroundColor = (R.color.theamColor()?.withAlphaComponent(0.8))!
        tagListView.textFont = UIFont.sk.pingFangRegular(15)
        tagListView.enableRemoveButton = true
        tagListView.tagCornerRadius = 3
        tagListView.paddingX = 8
        tagListView.paddingY = 4
        tagListView.removeButtonIconSize = 10
    }


    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        self.tagListView.removeTagView(tagView)
        var emails = self.inputEmails.value
        emails.removeAll(where: { $0.email == tagView.titleForNormal })
        self.inputEmails.accept(emails)
    }
    


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if !text.isValidEmail {
            Toast.showMessage("Invalid Email")
            return true
        }
        var emails = self.inputEmails.value
        emails.append(EmailCcModel(email: text))
        self.inputEmails.accept(emails)
        self.tagListView.insertTag(text, at: 0)
        textField.text = ""
        return true
    }

}

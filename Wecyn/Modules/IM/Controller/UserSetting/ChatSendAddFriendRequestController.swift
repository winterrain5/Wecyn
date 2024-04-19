//
//  ChatSendAddFriendRequestController.swift
//  Wecyn
//
//  Created by Derrick on 2024/4/10.
//

import UIKit
import IQKeyboardManagerSwift
class ChatSendAddFriendRequestController: BaseViewController {
    let label = UILabel()
    let tf = UITextField()
    var updateComplete:(()->())?
    var model:FriendUserInfoModel!
    required init(model:FriendUserInfoModel) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigation.item.title = "申请添加朋友".innerLocalized()
       
        label.text = "你需要发送验证申请，等对方通过".innerLocalized()
        label.numberOfLines = 0
        label.textColor = .gray
        view.addSubview(label)
        label.frame.origin = CGPoint(x: 16, y: kNavBarHeight + 16)
        label.width = kScreenWidth - 32
        label.sizeToFit()

       
        self.view.addSubview(tf)
        tf.frame = CGRect(x: 16, y: label.frame.maxY + 16, width: kScreenWidth - 32, height: 40)
        tf.becomeFirstResponder()
        tf.textColor = R.color.textColor33()!
        tf.placeholder = "备注".innerLocalized()
        tf.borderStyle = .none
        
        
        let line = UIView()
        line.frame = CGRect(x: 16, y: tf.frame.maxY + 1, width: kScreenWidth - 32, height: 1)
        line.backgroundColor = R.color.seperatorColor()!
        self.view.addSubview(line)

        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        let saveButton = LoadingButton()
        saveButton.imageForNormal = R.image.checkmark()
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let remark = self.tf.text ?? ""
            NetworkService.addFriend(userId: self.model.id,reason: remark).subscribe(onNext:{
                saveButton.stopAnimation()
                if $0.success == 1 {
                    Toast.showSuccess( "加好友请求已发送".innerLocalized())
                    self.returnBack()
                } else {
                    Toast.showError($0.message)
                }
                
            },onError: { e in
                saveButton.stopAnimation()
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        
        tf.rx.text.orEmpty.map({ !$0.isEmpty }).bind(to: saveButton.rx.isEnabled).disposed(by: rx.disposeBag)
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }



}

//
//  PostCommentFullScreenController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/21.
//

import UIKit
import KMPlaceholderTextView
import IQKeyboardManagerSwift
class PostCommentFullScreenController: BaseViewController {
    var name: String = ""
    var id: Int = 0
    var type: Int = 1 // 1 comment 2 reply
    let tv = KMPlaceholderTextView()
    var addCommentComplete:((PostCommentModel)->())?
    var addReplyComplete:((PostCommentReplyModel)->())?
    required init(name:String,id:Int,type:Int) {
        super.init(nibName: nil, bundle: nil)
        self.name = name
        self.id = id
        self.type = type
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        let postButton = UIButton()
        postButton.imageForNormal = R.image.paperplaneFill()!
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: postButton)
        postButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.type == 1 {
                self.addComment()
            } else {
                self.addReply()
            }
        }).disposed(by: rx.disposeBag)
        
        let line = UIView()
        self.view.addSubview(line)
        line.backgroundColor = R.color.backgroundColor()!
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.width.equalTo(2)
            make.height.equalTo(44)
        }
        
        let avatar = UIImageView()
        avatar.backgroundColor = R.color.backgroundColor()!
        avatar.kf.setImage(with: UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.avatar_url)
        self.view.addSubview(avatar)
        avatar.cornerRadius = 20
        avatar.snp.makeConstraints { make in
            make.centerX.equalTo(line.snp.centerX)
            make.width.height.equalTo(40)
            make.top.equalTo(line.snp.bottom).offset(2)
        }
        
        let label = UILabel()
        label.text = "reply @\(name)"
        label.font = UIFont.sk.pingFangRegular(15)
        label.textColor = R.color.textColor33()!
        label.sk.setSpecificTextColor("@\(name)", color: R.color.theamColor()!)
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(line.snp.right).offset(31)
            make.top.equalToSuperview().offset(12 + kNavBarHeight)
            make.right.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(tv)
        tv.placeholder = "add your comment"
        tv.textColor = R.color.textColor33()!
        tv.font = UIFont.sk.pingFangRegular(18)
        tv.placeholderFont = UIFont.sk.pingFangRegular(18)
        tv.snp.makeConstraints { make in
            make.left.equalTo(label.snp.left)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(label.snp.bottom).offset(12)
            make.height.equalTo(120)
        }
        tv.rx.text.orEmpty.map({ !$0.isEmpty }).bind(to: postButton.rx.isEnabled).disposed(by: rx.disposeBag)
        tv.becomeFirstResponder()
        
        navigation.bar.isShadowHidden = false
    }
    
    func addComment() {
        PostService.addComment(postId: id, content: self.tv.text).subscribe(onNext:{ model in
            self.addCommentComplete?(model)
            self.returnBack()
        }).disposed(by: self.rx.disposeBag)
    }
    
    func addReply() {
        PostService.addReply(commentId: id, content: self.tv.text).subscribe(onNext:{ model in
            self.addReplyComplete?(model)
            self.returnBack()
        }).disposed(by: self.rx.disposeBag)
    }

  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
}

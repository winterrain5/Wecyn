//
//  PostCommentToolBarView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/15.
//

import UIKit
import KMPlaceholderTextView
class PostCommentToolBarView: UIView {

    var tvContentView = UIView()
    var tv = KMPlaceholderTextView()
    var sendButton = LoadingButton()
    let line = CALayer()
    var isBeginEdit = false
    var expendButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tvContentView)
        tvContentView.backgroundColor = R.color.backgroundColor()
        tvContentView.cornerRadius = 16
        
        tvContentView.addSubview(tv)
        tv.placeholder = "Post your comment"
        tv.textColor = R.color.textColor33()!
        tv.font = UIFont.sk.pingFangRegular(15)
        tv.backgroundColor = .clear
        tv.rx.text.map({ ($0?.isEmpty ?? false) }).subscribe(onNext:{ [weak self] in
            self?.sendButton.isEnabled = !$0
        }).disposed(by: rx.disposeBag)
        
        addSubview(sendButton)
        sendButton.imageForNormal = R.image.paperplaneFill()!
        
        tvContentView.addSubview(expendButton)
        expendButton.imageForNormal = R.image.post_comment_expend()?.rotated(by: 80)
        
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        
        tvContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(32)
            make.top.equalToSuperview().offset(8)
            make.right.equalTo(sendButton.snp.left).offset(-12)
        }
        
        tv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.height.equalTo(32)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-42)
        }
        
        expendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
    
    }

}

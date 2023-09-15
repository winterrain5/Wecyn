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
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tvContentView)
        tvContentView.backgroundColor = R.color.backgroundColor()
        tvContentView.cornerRadius = 16
        
        tvContentView.addSubview(tv)
        tv.placeholder = "Post your comment"
        tv.textColor = R.color.textColor52()!
        tv.font = UIFont.sk.pingFangRegular(15)
        tv.backgroundColor = .clear
        tv.rx.didBeginEditing.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.tvContentView.frame.size.width = self.width - 88
                self.sendButton.alpha = 1
            }
            
        }).disposed(by: rx.disposeBag)
        tv.rx.didEndEditing.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.tvContentView.frame.size.width = self.width - 32
                self.sendButton.alpha = 0
            }
        }).disposed(by: rx.disposeBag)
        
        addSubview(sendButton)
        sendButton.cornerRadius = 16
        sendButton.backgroundColor = R.color.theamColor()
        sendButton.titleForNormal = "Post"
        sendButton.titleColorForNormal = .white
        sendButton.titleLabel?.font = UIFont.sk.pingFangRegular(14)
        sendButton.alpha = 0
        
        tv.rx.text.map({ $0?.isEmpty ?? false }).asObservable().bind(to: sendButton.rx.isEnabled).disposed(by: rx.disposeBag)
        
        
        line.backgroundColor = R.color.seperatorColor()?.cgColor
        self.layer.addSublayer(line)
        
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        line.frame = CGRect(x: 0, y: 0, width: self.width, height: 1)
        
        tvContentView.frame = CGRect(x: 16, y: 8, width: self.width - 32, height: 32)
        
        tv.frame = CGRect(x: 8, y: 0, width: tvContentView.width - 16, height: 32)
        
        sendButton.frame = CGRect(x: self.width - 16, y: 8, width: 48, height: 32)
    
    }

}

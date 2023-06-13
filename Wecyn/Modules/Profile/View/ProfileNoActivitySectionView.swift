//
//  ProfileActivitySectionView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

class ProfileNoActivitySectionView: UIView {

    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = R.color.textColor52()!
        $0.text = "Activity"
    }
    private let createPostBtn = UIButton().then { btn in
        btn.titleForNormal = "Create a post"
        btn.backgroundColor = R.color.theamColor()!
        btn.titleLabel?.font = UIFont.sk.pingFangSemibold(12)
    }
    private let msgLabel1 = UILabel().then {
        $0.font = UIFont.sk.pingFangRegular(13)
        $0.text = "You have not posted lately"
        $0.textColor = R.color.textColor52()!
    }
    private let msgLabel2 = UILabel().then {
        $0.font = UIFont.sk.pingFangRegular(11)
        $0.text = "Recent posts you share or comment on will be displayed here"
        $0.textColor = R.color.textColor52()!
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(createPostBtn)
        addSubview(msgLabel1)
        addSubview(msgLabel2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(21)
        }
        createPostBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(16)
            make.width.equalTo(86)
            make.height.equalTo(26)
        }
        createPostBtn.addShadow(cornerRadius: 6)
        
        msgLabel1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        msgLabel2.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.top.equalTo(msgLabel1.snp.bottom).offset(2)
        }
    }
}

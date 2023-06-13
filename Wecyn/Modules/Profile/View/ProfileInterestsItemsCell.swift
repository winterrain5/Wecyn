//
//  ProfileInterestsItemsCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class ProfileInterestsItemsCell: UITableViewCell {
    
    private let imgView = UIImageView().then { img in
        img.image = R.image.placeholder()
    }
    private let companyLabel = UILabel().then { label in
        label.text = "Company1234"
        label.textColor = R.color.textColor52()
        label.font = UIFont.sk.pingFangSemibold(16)
    }
    private let followersLabel =  UILabel().then { label in
        label.text = "3,000followers"
        label.textColor = R.color.textColor52()
        label.font = UIFont.sk.pingFangRegular(13)
    }
    private let followBtn = UIButton().then { btn in
        btn.titleForNormal = "Following"
        btn.backgroundColor = R.color.theamColor()!
        btn.titleLabel?.font = UIFont.sk.pingFangSemibold(12)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(companyLabel)
        contentView.addSubview(followersLabel)
        contentView.addSubview(followBtn)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        companyLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalToSuperview().offset(15)
        }
        
        followersLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalTo(companyLabel.snp.bottom).offset(2)
        }
        
        followBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.width.equalTo(68)
            make.height.equalTo(26)
            make.centerY.equalToSuperview()
        }
        followBtn.addShadow(cornerRadius: 6)
    }

}

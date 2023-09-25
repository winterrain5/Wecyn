//
//  ProfileExperienceItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class ProfileExperienceItemCell: UITableViewCell {

    private let imgView = UIImageView().then { img in
        img.image = R.image.placeholder()
    }
    private let jobLabel = UILabel().then { label in
        label.text = "UI/UX Designer"
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangSemibold(16)
    }
    private let companyLabel =  UILabel().then { label in
        label.text = "Company1234  |  Full-time"
        label.numberOfLines = 2
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(13)
    }
    private let timeLabel =  UILabel().then { label in
        label.text = "Aug 2020 - Oct 2020"
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
    }
    private let descLabel =  UILabel().then { label in
        label.text = "Job Description"
        label.numberOfLines = 0
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(jobLabel)
        contentView.addSubview(companyLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
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
        
        jobLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(16)
        }
        
        companyLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalTo(jobLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalTo(companyLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }

}
    

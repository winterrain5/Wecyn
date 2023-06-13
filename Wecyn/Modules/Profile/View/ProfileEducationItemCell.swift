//
//  ProfileEducationItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class ProfileEducationItemCell: UITableViewCell {

    private let imgView = UIImageView().then { img in
        img.image = R.image.placeholder()
    }
    private let schoolLabel = UILabel().then { label in
        label.text = "Nanyang Polytechnic"
        label.textColor = R.color.textColor52()
        label.font = UIFont.sk.pingFangSemibold(16)
    }
    private let majorLabel =  UILabel().then { label in
        label.text = "High School Diploma, \nInteraction Design"
        label.numberOfLines = 2
        label.textColor = R.color.textColor52()
        label.font = UIFont.sk.pingFangRegular(13)
    }
    private let timeLabel =  UILabel().then { label in
        label.text = "2016-2019"
        label.textColor = R.color.textColor52()
        label.font = UIFont.sk.pingFangRegular(12)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(schoolLabel)
        contentView.addSubview(majorLabel)
        contentView.addSubview(timeLabel)
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
        
        schoolLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(16)
        }
        
        majorLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalTo(schoolLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.top.equalTo(majorLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
        }
    }

}

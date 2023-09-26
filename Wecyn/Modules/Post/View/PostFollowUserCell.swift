//
//  PostFollowUserCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/26.
//

import UIKit

class PostFollowUserCell: UITableViewCell {

    var avatar = UIImageView()
    var nameLabel = UILabel()
    var headlineLabel = UILabel()
    var followButton = UIButton()
    var model:FriendUserInfoModel? {
        didSet {
            guard let model = model else { return }
            
            avatar.kf.setImage(with: model.avatar.url)
            nameLabel.text = model.full_name
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(headlineLabel)
        contentView.addSubview(followButton)

        
        avatar.backgroundColor = R.color.backgroundColor()!
        avatar.cornerRadius = 20
        
        nameLabel.textColor = R.color.textColor22()!
        nameLabel.font = UIFont.sk.pingFangMedium(15)
        
        headlineLabel.textColor = R.color.textColor77()!
        headlineLabel.font = UIFont.sk.pingFangRegular(14)
        headlineLabel.textAlignment = .left
        
        followButton.titleForNormal = "Follow"
        followButton.backgroundColor = R.color.theamColor()!
        followButton.titleLabel?.font = UIFont.sk.pingFangMedium(15)
        followButton.titleColorForNormal = .white
        followButton.cornerRadius = 18
        
        self.isSkeletonable = true
        self.contentView.isSkeletonable = true
        self.contentView.subviews.forEach({ $0.isSkeletonable = true })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.width.equalTo(40)
        }
        
        followButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(avatar)
            make.width.equalTo(90)
            make.height.equalTo(36)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.right.greaterThanOrEqualTo(followButton.snp.left).offset(-8)
            make.top.equalTo(avatar.snp.top).offset(2)
            make.height.equalTo(20)
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.right.greaterThanOrEqualTo(followButton.snp.left).offset(-16)
            make.bottom.equalTo(avatar.snp.bottom).offset(-2)
            make.height.equalTo(18)
        }
      
        
      
    }
}

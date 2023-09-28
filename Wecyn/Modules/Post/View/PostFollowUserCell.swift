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
    var model:FriendFollowModel? {
        didSet {
            guard let model = model else { return }
            
            avatar.kf.setImage(with: model.avatar.url)
            nameLabel.text = model.full_name
            headlineLabel.text = model.headline
            updateFollowStatus(model)
            
            followButton.isHidden = model.id == (UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.id.int ?? 0)
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
        headlineLabel.numberOfLines = 2
        
        followButton.titleForNormal = "Follow"
        followButton.backgroundColor = R.color.theamColor()!
        followButton.titleLabel?.font = UIFont.sk.pingFangMedium(14)
        followButton.titleColorForNormal = .white
        followButton.cornerRadius = 15
        
        self.isSkeletonable = true
        self.contentView.isSkeletonable = true
        self.contentView.subviews.forEach({ $0.isSkeletonable = true })
        
        
        followButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            self?.followAction()
            
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func followAction() {
        guard let model = self.model else { return }
        if model.is_following {
            NetworkService.cancelFollow(userId: model.id).subscribe(onNext:{
                if $0.success == 1 {
                    model.is_following = false
                    self.updateFollowStatus(model)
                }
            }).disposed(by: self.rx.disposeBag)
        } else {
            
            NetworkService.addFollow(userId: model.id).subscribe(onNext:{
                if $0.success == 1 {
                    model.is_following = true
                    self.updateFollowStatus(model)
                }
            }).disposed(by: self.rx.disposeBag)
            
        }
        
    }
    
    func updateFollowStatus(_ model:FriendFollowModel) {
        
        if model.is_following  {
            followintStatus()
        } else {
            followStatus()
        }
        
    }
    
    func followStatus() {
        followButton.backgroundColor = R.color.theamColor()!
        followButton.titleForNormal = "Follow"
        followButton.borderWidth = 0
        followButton.titleColorForNormal = .white
    }
    func followintStatus() {
        followButton.backgroundColor = .white
        followButton.borderColor = R.color.seperatorColor()!
        followButton.borderWidth = 0.5
        followButton.titleForNormal = "Following"
        followButton.titleColorForNormal = R.color.textColor22()
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
            make.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.right.greaterThanOrEqualTo(followButton.snp.left).offset(-8)
            make.top.equalTo(avatar.snp.top)
            make.height.equalTo(20)
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.right.equalTo(followButton.snp.left).offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.height.equalTo(18)
        }
      
        
      
    }
}

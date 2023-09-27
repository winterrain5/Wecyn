//
//  PostUserHeaderInfoView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/14.
//

import UIKit

class PostUserHeaderInfoView: UIView {
    
    let blurImageView = UIImageView()
    
    let avtContentView = UIView()
    let avtImgView = UIImageView()
    
    let nameLabel = UILabel()
    let subLabel =  UILabel()
    
    let followingCountLabel = UILabel()
    let followerCountLabel = UILabel()
    
    let followButton = UIButton()
    
    var model:FriendUserInfoModel? {
        didSet {
            guard let model = model else { return }
            
            hideSkeleton()
            
            avtImgView.kf.setImage(with: model.avatar.url ,placeholder: R.image.proile_user())
            blurImageView.kf.setImage(with: model.cover.url)
            nameLabel.text = model.full_name
            subLabel.text = "WID:\(model.wid)"
            
            if let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className) {
                followButton.isHidden =  user.id.int == model.id
            }
            
            followingCountLabel.text = "\(model.following_count.formatted(.number)) Following"
            followerCountLabel.text = "\(model.follower_count.formatted(.number)) Followers"
            configLabel(followingCountLabel, text: "Following")
            configLabel(followerCountLabel, text: "Followers")
            updateFollowStatus(model)
            
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isSkeletonable = true
        
        blurImageView.backgroundColor = R.color.backgroundColor()!
        addSubview(blurImageView)
        addSubview(avtContentView)
        avtContentView.addSubview(avtImgView)
        addSubview(nameLabel)
        addSubview(subLabel)
        addSubview(followButton)
        addSubview(followingCountLabel)
        addSubview(followerCountLabel)
        
        self.subviews.forEach({ $0.isSkeletonable = true })
        
        blurImageView.contentMode = .scaleAspectFill
        blurImageView.clipsToBounds = true
        
        
        avtContentView.addShadow(cornerRadius: 40)
        avtContentView.borderColor = .white
        avtContentView.borderWidth = 2
        
        avtImgView.contentMode = .scaleAspectFit
        avtImgView.cornerRadius = 40
        
        
        nameLabel.textColor = R.color.textColor22()
        nameLabel.font = UIFont.sk.pingFangSemibold(18)
        nameLabel.numberOfLines = 2
        
        subLabel.textColor = R.color.textColor77()
        subLabel.font = UIFont.sk.pingFangRegular(14)
        subLabel.numberOfLines = 1
        
     
       
      
        followingCountLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            let vc = PostFollowController(user: model,defaultIndex: 0)
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
            
        }).disposed(by: rx.disposeBag)
        
       
        followerCountLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            let vc = PostFollowController(user: model,defaultIndex: 1)
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        
        followButton.backgroundColor = R.color.theamColor()!
        followButton.cornerRadius = 18
        followButton.titleForNormal = "Follow"
        followButton.titleColorForNormal = .white
        followButton.titleLabel?.font = UIFont.sk.pingFangMedium(15)
        followButton.showsMenuAsPrimaryAction = true
        
        followButton.rx.tap.subscribe(onNext:{ [weak self] in
            
            self?.followAction()
            
        }).disposed(by: rx.disposeBag)
        showSkeleton()
        
    }
    
    func configLabel(_ label:UILabel,text:String) {
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangSemibold(12)
        label.sk.setSpecificTextColor(text, color: R.color.textColor77()!)
        label.sk.setsetSpecificTextFont(text, font: UIFont.sk.pingFangRegular(12))
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
    
    
    func updateFollowStatus(_ model:FriendUserInfoModel) {
        if model.is_following  {
            let unsubscribe = UIAction(title: "Unfollow @\(model.full_name)", image: UIImage(systemName: "person.fill.xmark")?.withTintColor(.red).withRenderingMode(.alwaysOriginal),attributes: .destructive) { _ in
                self.followAction()
            }
            
            let menuActions = [unsubscribe]
            let menu = UIMenu(
                title: "",
                children: menuActions)
            self.followButton.menu = menu
            
            followButton.backgroundColor = .white
            followButton.borderColor = R.color.seperatorColor()!
            followButton.borderWidth = 0.5
            followButton.titleForNormal = "Following"
            followButton.titleColorForNormal = R.color.textColor22()
        } else {
            followButton.backgroundColor = R.color.theamColor()!
            followButton.titleForNormal = "Follow"
            followButton.borderWidth = 0
            followButton.titleColorForNormal = .white
            self.followButton.menu = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(200)
        }
        
        avtContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
            make.bottom.equalTo(blurImageView.snp.bottom).offset(40)
        }
        
        avtImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(avtImgView.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        subLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        followButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.top.equalTo(blurImageView.snp.bottom).offset(12)
            make.height.equalTo(36)
            make.width.equalTo(90)
        }
        
        followingCountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(14)
        }
        
        followerCountLabel.snp.makeConstraints { make in
            make.left.equalTo(followingCountLabel.snp.right).offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(14)
        }
    }
    
}

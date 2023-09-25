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
            
            let unsubscribe = UIAction(title: "Unfollow @\(model.full_name)", image: UIImage(systemName: "person.fill.xmark")?.withTintColor(.red).withRenderingMode(.alwaysOriginal),attributes: .destructive) { _ in
                Toast.showSuccess(withStatus: "Unfollow")
            }
            
            
            let menuActions = [unsubscribe]
            
            let addNewMenu = UIMenu(
                title: "",
                children: menuActions)
            self.followButton.menu = addNewMenu
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
        
        subLabel.textColor = R.color.textColor22()
        subLabel.font = UIFont.sk.pingFangSemibold(15)
        subLabel.numberOfLines = 1
        
        followButton.backgroundColor = R.color.theamColor()!
        followButton.cornerRadius = 15
        followButton.titleForNormal = "Follow"
        followButton.titleColorForNormal = .white
        followButton.titleLabel?.font = UIFont.sk.pingFangMedium(15)
        followButton.showsMenuAsPrimaryAction = true
        
        
        showSkeleton()
        
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
            make.height.equalTo(30)
            make.width.equalTo(72)
        }
    }
    
}

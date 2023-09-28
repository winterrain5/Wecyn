//
//  HomePostUserInfoView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/22.
//

import UIKit

class HomePostUserInfoView: UIView {

    var avatar = UIImageView()
    var nameLabel = UILabel()
    var postTimeLabel = UILabel()
    var headlineLabel = UILabel()
    var moreButton = UIButton()
    var updatePostType:((PostListModel)->())?
    var followHandler:((PostListModel)->())?
    var deleteHandler:((PostListModel)->())?
    var postModel:PostListModel? {
        didSet {
            guard let model = postModel else { return }
            
            avatar.kf.setImage(with: model.user.avatar.url)
            nameLabel.text = model.user.full_name
            postTimeLabel.text = model.post_time
            headlineLabel.text = model.user.headline
            
            if model.is_own_post {
                let action1 = UIAction(title: "Delete post",image: UIImage.trash?.tintImage(.red),attributes: .destructive) { _ in
                    PostService.updatePostType(id: model.id, type: 0).subscribe(onNext:{
                        if $0.success == 1 {
                            Toast.showSuccess("You have deleted this post")
                            self.deleteHandler?(model)
                        } else {
                            Toast.showError($0.message)
                        }
                    }).disposed(by: self.rx.disposeBag)
                }
                
                let submenu = UIMenu(title:"Change post type",children: [
                    UIAction(title: "Public",image: model.type == 1 ? UIImage.checkmark?.tintImage(.black) : nil , handler: { _ in
                        model.type = 1
                        self.updatePostType(type: 1)
                    }),
                    UIAction(title: "Visible only to yourself",image: model.type == 2 ? UIImage.checkmark?.tintImage(.black) : nil , handler: { _ in
                        model.type = 2
                        self.updatePostType(type: 2)
                    }),
                    UIAction(title: "Visible only to followers",image: model.type == 3 ? UIImage.checkmark?.tintImage(.black) : nil , handler: { _ in
                        model.type = 3
                        self.updatePostType(type: 3)
                    })
                ])
                
                moreButton.menu = UIMenu(children: [action1,submenu])
            } else {
                let followImage = model.user.is_following ? UIImage.person_fill_xmark : UIImage.person_fill_checkmark
                let followTitle = "\(model.user.is_following ? "Unfollow" : "Follow")@\(model.user.full_name)"
                let action1 = UIAction(title:followTitle ,image: followImage) { _ in
                    if model.user.is_following {
                        self.cancelFollowUser()
                    }else {
                        self.followUser()
                    }
                }
//                let action2 = UIAction(title:"Mute @\(model.user.full_name)",image: UIImage.speaker_slash) { _ in
//                    Toast.showMessage("Function under development")
//                }
//                let action3 = UIAction(title:"Block @\(model.user.full_name)",image: UIImage.slash_circle) { _ in
//                    Toast.showMessage("Function under development")
//                }
                let action4 = UIAction(title:"Report",image: UIImage.flag) { _ in
                    let vc = PostReportController(type: 1)
                    let nav = BaseNavigationController(rootViewController: vc)
                    if let sheet = nav.sheetPresentationController{
                        sheet.detents = [.medium(), .large()]
                    }
                    UIViewController.sk.getTopVC()?.present(nav, animated: true)
                }
                moreButton.menu = UIMenu(children: [action1,action4])
            }
            
         
            
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatar)
        addSubview(nameLabel)
        addSubview(postTimeLabel)
        addSubview(headlineLabel)
        addSubview(moreButton)
        
        avatar.backgroundColor = R.color.backgroundColor()!
        avatar.cornerRadius = 20
        avatar.isUserInteractionEnabled = true
        avatar.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self,let model = self.postModel else { return }
            let vc = PostUserInfoController(userId: model.user.id)
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        nameLabel.textColor = R.color.textColor22()!
        nameLabel.font = UIFont.sk.pingFangSemibold(14)
        
        postTimeLabel.textColor = R.color.textColor77()!
        postTimeLabel.font = UIFont.sk.pingFangRegular(12)
        postTimeLabel.textAlignment = .left
        
        headlineLabel.textColor = R.color.textColor77()!
        headlineLabel.font = UIFont.sk.pingFangRegular(12)
        
        moreButton.imageForNormal = UIImage.ellipsis?.withTintColor(R.color.iconColor()!,renderingMode: .alwaysOriginal).scaled(toWidth: 18)
        moreButton.contentHorizontalAlignment = .right
        moreButton.showsMenuAsPrimaryAction  = true
        moreButton.isHiddenWhenSkeletonIsActive = true
        
        self.isSkeletonable = true
        self.subviews.forEach({ $0.isSkeletonable = true })
        nameLabel.skeletonTextLineHeight = .relativeToFont
        postTimeLabel.skeletonTextLineHeight = .relativeToFont
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
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.top.equalTo(avatar.snp.top)
            make.height.equalTo(20)
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(17)
        }
        
        postTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(4)
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.height.equalTo(17)
            make.width.greaterThanOrEqualTo(100)
        }
        
        moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.height.equalTo(30)
            make.width.equalTo(40)
        }
    }
    
    func updatePostType(type:Int){
        guard let model = postModel else { return }
        PostService.updatePostType(id: model.id, type: type).subscribe(onNext:{ _ in
            self.updatePostType?(model)
        }).disposed(by: rx.disposeBag)
    }
    
    func followUser() {
        guard let model = postModel else { return }
        NetworkService.addFollow(userId: model.user.id).subscribe(onNext:{
            if $0.success == 1 {
                model.user.is_following = true
                self.followHandler?(model)
                Toast.showSuccess( "You follow @\(model.user.full_name)")
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func cancelFollowUser() {
        guard let model = postModel else { return }
        NetworkService.addFollow(userId: model.user.id).subscribe(onNext:{
            if $0.success == 1 {
                model.user.is_following = false
                self.followHandler?(model)
            }
        }).disposed(by: rx.disposeBag)
    }
}

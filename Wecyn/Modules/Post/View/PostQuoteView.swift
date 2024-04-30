//
//  PostQuoteView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/22.
//

import UIKit

class PostQuoteView: UIView {

    var avatar = UIImageView()
    var nameLabel = UILabel()
    var postTimeLabel = UILabel()
    var contentLabel = UILabel()
    var postModel:PostListModel? {
        didSet {
            guard let model = postModel else { return }
            
            avatar.kf.setImage(with: model.user.avatar.url)
            nameLabel.text = model.user.full_name
            postTimeLabel.text = model.post_time
            contentLabel.text = model.content
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    var viewHeight:CGFloat {
        guard let model = postModel else { return 0 }
        let contentH = model.content.heightWithConstrainedWidth(width: self.width - 32, font: UIFont.sk.pingFangRegular(12))
        return (contentH < 16 ? 16 : contentH) + 44
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatar)
        addSubview(nameLabel)
        addSubview(contentLabel)
        addSubview(postTimeLabel)

        
        avatar.backgroundColor = R.color.backgroundColor()!
        avatar.cornerRadius = 10
        
        nameLabel.textColor = R.color.textColor22()!
        nameLabel.font = UIFont.sk.pingFangMedium(12)
        
        postTimeLabel.textColor = R.color.textColor77()!
        postTimeLabel.font = UIFont.sk.pingFangRegular(12)
        postTimeLabel.textAlignment = .left
        
        contentLabel.textColor = R.color.textColor33()!
        contentLabel.font = UIFont.sk.pingFangRegular(12)
        contentLabel.numberOfLines = 0
 
        
        cornerRadius = 8
        borderColor = R.color.seperatorColor()
        borderWidth = 0.5
        
        rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            guard let model = self.postModel else { return }
            let vc = PostDetailViewController(postId: model.id)
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        self.isSkeletonable = true
        self.subviews.forEach({ $0.isSkeletonable = true })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.height.width.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.centerY.equalTo(avatar.snp.centerY)
        }
        
        postTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(4)
            make.centerY.equalTo(avatar.snp.centerY)
            
        }
        guard let model = postModel else { return }
        let contentH = model.content.heightWithConstrainedWidth(width: self.width - 32, font: UIFont.sk.pingFangRegular(12))
        contentLabel.frame = CGRect(x: 16, y: avatar.frame.maxY + 8, width: self.width - 32, height: contentH < 16 ? 16 : contentH)
      
    }
    
}
